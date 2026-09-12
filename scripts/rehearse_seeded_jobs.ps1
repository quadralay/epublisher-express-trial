[CmdletBinding()]
param(
    [string]$Drive = 'Q',
    [string]$ScratchRoot = (Join-Path $env:TEMP 'seeded-jobs-rehearsal'),
    [string]$SkillRoot = (Get-ChildItem -LiteralPath (Join-Path $env:USERPROFILE '.claude\plugins\cache\webworks-agent-skills\webworks-agent-skills') -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^\d+(\.\d+)+$' } | Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1 | ForEach-Object { Join-Path $_.FullName 'skills' }),
    [string]$AutomapExe = $(if (-not [string]::IsNullOrEmpty($env:AUTOMAP_EXE_PATH)) { $env:AUTOMAP_EXE_PATH } else { Get-ChildItem -LiteralPath 'C:\Program Files\WebWorks\ePublisher' -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^\d+(\.\d+)+$' } | Sort-Object { [version]$_.Name } -Descending | Select-Object -First 1 | ForEach-Object { Join-Path $_.FullName 'ePublisher AutoMap\WebWorks.Automap.exe' } }),
    [string]$ChromePath = 'C:\Program Files\Google\Chrome\Application\chrome.exe',
    [string]$EvidenceDir = '',
    [string]$RealStagingPath = (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'WebWorks ePublisher AutoMap\Staging'),
    [switch]$KeepDrive,
    [switch]$SkipBrowser,
    [switch]$NoRealStagingCleanup
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$script:Failures = New-Object System.Collections.ArrayList
$script:DriveCreated = $false
$script:StopRequested = $false
$script:RealStagingBeforeNames = @()
$script:RealStagingAfterNames = @()
$script:ScratchRootResolved = $null
$script:EvidenceDirResolved = $null
$script:ProductFolder = $null
$script:TranscriptPath = $null
$script:TranscriptStarted = $false
$script:StartTime = Get-Date
$RepoRoot = Split-Path -Parent $PSScriptRoot
$script:JobNames = @('Quantum Sync Help', 'Quantum Sync Release Notes', 'Quantum Sync Site Shell')
$script:BuildOrder = @('Quantum Sync Site Shell', 'Quantum Sync Help', 'Quantum Sync Release Notes')
$script:SourceRoot = Join-Path $RepoRoot 'latest\local-trial-projects\WebWorks ePublisher AutoMap'
$script:CompositionName = 'Quantum Sync Site'

function Write-Info {
    param([string]$Message)
    Write-Host $Message
}

function Add-Failure {
    param([string]$Message)
    [void]$script:Failures.Add($Message)
}

function Invoke-Step {
    param([int]$Number, [string]$Name, [scriptblock]$Action, [switch]$AllowAfterFailure)
    if ($script:StopRequested -and -not $AllowAfterFailure) {
        Write-Info ("STEP {0}: {1} -- FAIL" -f $Number, $Name)
        Add-Failure ("STEP {0}: {1} was skipped after an earlier failure" -f $Number, $Name)
        return
    }
    try {
        & $Action
        Write-Info ("STEP {0}: {1} -- PASS" -f $Number, $Name)
    }
    catch {
        $message = $_.Exception.Message
        Write-Info ("STEP {0}: {1} -- FAIL" -f $Number, $Name)
        Write-Info ("  Failure: {0}" -f $message)
        Add-Failure ("STEP {0}: {1}: {2}" -f $Number, $Name, $message)
        $script:StopRequested = $true
    }
}

function ConvertTo-ArgumentString { param([string[]]$Arguments)
    return (($Arguments | ForEach-Object { if ($_ -match '[\s"]') { '"{0}"' -f $_.Replace('"', '\"') } else { $_ } }) -join ' ')
}
function Invoke-NativeCaptured {
    param([string]$FilePath, [string[]]$Arguments)
    [void](Get-Command -Name $FilePath -ErrorAction Stop)
    $stdoutPath = [IO.Path]::GetTempFileName(); $stderrPath = [IO.Path]::GetTempFileName()
    try {
        $startArguments = @{ FilePath = $FilePath; Wait = $true; NoNewWindow = $true; PassThru = $true; RedirectStandardOutput = $stdoutPath; RedirectStandardError = $stderrPath }
        if ($Arguments.Count -gt 0) { $startArguments.ArgumentList = ConvertTo-ArgumentString $Arguments; Write-Info ("Native arguments: {0}" -f $startArguments.ArgumentList) }
        $process = Start-Process @startArguments -ErrorAction Stop
        $stdout = @(); $stderr = @()
        if ((Get-Item -LiteralPath $stdoutPath).Length -gt 0) { $stdout = @(Get-Content -LiteralPath $stdoutPath) }
        if ((Get-Item -LiteralPath $stderrPath).Length -gt 0) { $stderr = @(Get-Content -LiteralPath $stderrPath) }
        return [pscustomobject]@{ ExitCode = [int]$process.ExitCode; Stdout = $stdout; Stderr = $stderr }
    }
    finally { Remove-Item -LiteralPath $stdoutPath, $stderrPath -Force -ErrorAction SilentlyContinue }
}
function Write-NativeStreams { param($Result)
    foreach ($line in @($Result.Stdout)) { Write-Info ([string]$line) }
    foreach ($line in @($Result.Stderr)) { Write-Info ([string]$line) }
}
function Invoke-CapturedPython { param([string[]]$Arguments, [string]$Label)
    $result = Invoke-NativeCaptured -FilePath 'python' -Arguments $Arguments
    Write-Info ("{0} exit code: {1}" -f $Label, $result.ExitCode)
    Write-NativeStreams $result
    return $result.ExitCode
}
function Invoke-BrowserTest { param([string]$Url, [string]$Label, [switch]$Detailed)
    $arguments = @((Join-Path $SkillRoot 'reverb2\scripts\browser-test.js'), $ChromePath, $Url, '--vanilla')
    $result = Invoke-NativeCaptured -FilePath 'node' -Arguments $arguments
    Write-Info ("{0} exit code: {1}" -f $Label, $result.ExitCode)
    foreach ($line in @($result.Stderr)) { Write-Info ([string]$line) }
    $jsonText = $result.Stdout -join [Environment]::NewLine
    try {
        $json = $jsonText | ConvertFrom-Json
        Write-Info ("{0} metrics: loadTime={1}ms; TOC itemCount={2}; parcelsLoadedAll={3}; errorCount={4}; warningCount={5}" -f $Label, $json.loadTime, $json.components.toc.itemCount, $json.parcelsLoadedAll, $json.errorCount, $json.warningCount)
        $hardPassed = $result.ExitCode -eq 0 -and $json.success -eq $true -and [int]$json.errorCount -eq 0; if ($Detailed) { return [pscustomobject]@{ HardPassed = $hardPassed; ParcelsLoadedAll = ($json.parcelsLoadedAll -eq $true); JsonText = $jsonText } }
        return $hardPassed
    } catch {
        Write-Info ("{0} JSON parse/validation failure: {1}" -f $Label, $_.Exception.Message)
        foreach ($line in @($result.Stdout)) { Write-Info ([string]$line) }
        if ($Detailed) { return [pscustomobject]@{ HardPassed = $false; ParcelsLoadedAll = $false; JsonText = $jsonText } } else { return $false }
    }
}

function Get-JobPath {
    param([string]$Name)
    return ("{0}\Jobs\{1}\{1}.waj" -f $script:ProductFolder, $Name)
}

function Get-JobLogPath {
    param([string]$Name)
    return ("{0}\Jobs\{1}\{1}-log.txt" -f $script:ProductFolder, $Name)
}

function Get-JobOutputPath {
    param([string]$Name)
    return ("{0}\Output\{1}" -f $script:ProductFolder, $Name)
}

function Capture-RealStagingListing {
    param([string]$Path, [string]$OutputFile, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        $message = "{0}: folder does not exist: {1}" -f $Label, $Path
        Write-Info $message
        $message | Set-Content -LiteralPath $OutputFile -Encoding UTF8
        return @()
    }
    $names = @(Get-ChildItem -LiteralPath $Path -Directory | Select-Object -ExpandProperty Name | Sort-Object)
    if ($names.Count -eq 0) { @('(none)') | Set-Content -LiteralPath $OutputFile -Encoding UTF8 }
    else { $names | Set-Content -LiteralPath $OutputFile -Encoding UTF8 }
    Write-Info ("{0}: {1}" -f $Label, $Path)
    if ($names.Count -eq 0) { Write-Info '  (none)' }
    else { foreach ($name in $names) { Write-Info ("  {0}" -f $name) } }
    return $names
}

function Print-LogEvidence {
    param([string]$Name, [string]$LogPath)
    if (-not (Test-Path -LiteralPath $LogPath -PathType Leaf)) {
        throw ("Expected log is missing: {0}" -f $LogPath)
    }
    $lines = @(Get-Content -LiteralPath $LogPath)
    $matches = @($lines | Where-Object { $_ -match '(?i)deploy|warn|error' })
    Write-Info ("{0} deploy/warn/error log lines:" -f $Name)
    if ($matches.Count -eq 0) { Write-Info '  (none)' }
    else { foreach ($line in $matches) { Write-Info ("  `"{0}`"" -f $line) } }
    $warningLines = @($lines | Where-Object { $_ -match '(?i)warn' })
    $errorLines = @($lines | Where-Object { $_ -match '(?i)error' })
    Write-Info ("{0} warning line count: {1}" -f $Name, $warningLines.Count)
    Write-Info ("{0} error line count: {1}" -f $Name, $errorLines.Count)
    $pdfEvidence = @($lines | Where-Object {
        ($_ -match '(?i)pdf') -and ($_ -match '(?i)not.?built|skip|disabled|false|no build|not selected')
    })
    Write-Info ("{0} PDF not-built log evidence:" -f $Name)
    if ($pdfEvidence.Count -eq 0) { Write-Info '  (no matching PDF not-built line found)' }
    else { foreach ($line in $pdfEvidence) { Write-Info ("  `"{0}`"" -f $line) } }
    return $lines
}

function Print-LogTail {
    param([string]$LogPath)
    if (Test-Path -LiteralPath $LogPath -PathType Leaf) {
        Write-Info ("Log tail (last 40 lines or fewer): {0}" -f $LogPath)
        foreach ($line in @(Get-Content -LiteralPath $LogPath | Select-Object -Last 40)) { Write-Info ([string]$line) }
    }
    else { Write-Info ("No log tail available; log is missing: {0}" -f $LogPath) }
}

function Invoke-AutomapBuild {
    param([string]$Name, [string]$JobPath, [string]$StagingArgument)
    $logPath = Get-JobLogPath $Name
    $outputPath = Get-JobOutputPath $Name
    $started = Get-Date
    Write-Info ("BUILD {0}: {1}" -f $Name, $JobPath)
    $native = Invoke-NativeCaptured -FilePath $AutomapExe -Arguments @($StagingArgument, $JobPath)
    $code = $native.ExitCode
    $automapOutput = @($native.Stdout) + @($native.Stderr)
    Write-Info ("{0} top-level output listing:" -f $Name)
    Get-TopLevelListing $outputPath
    $seconds = [math]::Round(((Get-Date) - $started).TotalSeconds, 1)
    Write-Info ("{0} build exit code: {1}; wall-clock seconds: {2}" -f $Name, $code, $seconds)
    if ($automapOutput.Count -gt 0) {
        Write-Info ("{0} AutoMap stdout/stderr:" -f $Name)
        foreach ($line in $automapOutput) { Write-Info ([string]$line) }
    }
    try { $logLines = @(Print-LogEvidence $Name $logPath) }
    catch { if ($code -ne 0) { Print-LogTail $logPath }; throw }
    $pdfMentions = @($logLines | Where-Object { $_ -match '(?i)pdf' })
    $firstPdfMention = 'none'
    if ($pdfMentions.Count -gt 0) { $firstPdfMention = [string]$pdfMentions[0] }
    Write-Info ("PDF target: not built (no pdf in output; log mentions of PDF = {0}, e.g. {1})" -f $pdfMentions.Count, $firstPdfMention)
    $indexPath = Join-Path $outputPath 'index.html'
    $pdfFiles = @()
    $recursivePdfFiles = @()
    if (Test-Path -LiteralPath $outputPath -PathType Container) {
        $pdfFiles = @(Get-ChildItem -LiteralPath $outputPath -Filter '*.pdf' -File -ErrorAction SilentlyContinue)
        $recursivePdfFiles = @(Get-ChildItem -LiteralPath $outputPath -Recurse -Filter '*.pdf' -File -ErrorAction SilentlyContinue)
    }
    Write-Info ("{0} index.html exists: {1} ({2})" -f $Name, (Test-Path -LiteralPath $indexPath -PathType Leaf), $indexPath)
    Write-Info ("{0} top-level PDF files: {1}" -f $Name, $pdfFiles.Count)
    foreach ($pdf in $pdfFiles) { Write-Info ("  {0}" -f $pdf.FullName) }
    if ($code -ne 0) { Print-LogTail $logPath; throw ("{0} AutoMap build returned exit code {1}" -f $Name, $code) }
    if (-not (Test-Path -LiteralPath $indexPath -PathType Leaf)) { throw ("{0} output index.html is missing" -f $Name) }
    if ($pdfFiles.Count -ne 0) { throw ("{0} unexpectedly produced top-level PDF files" -f $Name) }
    if ($recursivePdfFiles.Count -ne 0) { throw ("{0} unexpectedly produced PDF files under the output tree" -f $Name) }
    $summaryPattern = '(?i)(\d+)\s+warning\(s\),\s+(\d+)\s+error\(s\)\s+reported'
    $summaryMatch = $null
    $summaryLines = @($logLines) + @($automapOutput)
    foreach ($line in $summaryLines) {
        $candidate = [regex]::Match([string]$line, $summaryPattern)
        if ($candidate.Success) { $summaryMatch = $candidate; break }
    }
    if ($null -eq $summaryMatch) { throw ("{0} AutoMap warning/error summary line was not found" -f $Name) }
    $warningCount = [int]$summaryMatch.Groups[1].Value
    $errorCount = [int]$summaryMatch.Groups[2].Value
    Write-Info ("warnings={0} errors={1}" -f $warningCount, $errorCount)
    if ($warningCount -gt 0 -or $errorCount -gt 0) { throw ("{0} AutoMap reported warnings or errors" -f $Name) }
}

function Get-TopLevelListing {
    param([string]$Path)
    $entries = @(Get-ChildItem -LiteralPath $Path -Force | Sort-Object Name)
    if ($entries.Count -eq 0) { Write-Info '  (none)' }
    else {
        foreach ($entry in $entries) {
            if ($entry.PSIsContainer) { Write-Info ("  [DIR]  {0}" -f $entry.Name) }
            else { Write-Info ("  [FILE] {0}" -f $entry.Name) }
        }
    }
}

function Invoke-Composition {
    param([string]$CompositionPath, [string]$StagingArgument, [string]$LogPath)
    $started = Get-Date
    $native = Invoke-NativeCaptured -FilePath $AutomapExe -Arguments @($StagingArgument, $CompositionPath)
    $code = $native.ExitCode
    $automapOutput = @($native.Stdout) + @($native.Stderr)
    $seconds = [math]::Round(((Get-Date) - $started).TotalSeconds, 1)
    Write-Info ("Composition exit code: {0}; wall-clock seconds: {1}" -f $code, $seconds)
    if ($automapOutput.Count -gt 0) {
        Write-Info 'Composition AutoMap stdout/stderr:'
        foreach ($line in $automapOutput) { Write-Info ([string]$line) }
    }
    if (Test-Path -LiteralPath $LogPath -PathType Leaf) {
        $logLines = @(Get-Content -LiteralPath $LogPath)
        $selected = @($logLines | Where-Object { $_ -match '(?i)member|role|shell|parcel|merge|deploy|warn|error' })
        Write-Info ("{0} composition log excerpt:" -f $script:CompositionName)
        if ($selected.Count -eq 0) { Write-Info '  (none)' }
        else {
            $limit = [math]::Min(80, $selected.Count)
            for ($i = 0; $i -lt $limit; $i++) { Write-Info ("  `"{0}`"" -f $selected[$i]) }
            if ($selected.Count -gt 80) { Write-Info ("  [excerpt capped at 80 lines; {0} matching lines total]" -f $selected.Count) }
        }
    }
    else { Write-Info ("Composition log is missing: {0}" -f $LogPath) }
    return $code
}

function Find-TocEvidence {
    param([string]$OutputPath, [string]$IndexText)
    Write-Info 'TOC/manifest grep evidence (root and one level down):'
    $files = @()
    $files += @(Get-ChildItem -LiteralPath $OutputPath -File | Where-Object { $_.Extension -match '(?i)^\.(js|html)$' })
    foreach ($directory in @(Get-ChildItem -LiteralPath $OutputPath -Directory)) {
        $files += @(Get-ChildItem -LiteralPath $directory.FullName -File | Where-Object { $_.Extension -match '(?i)^\.(js|html)$' })
    }
    $matchingFiles = @()
    foreach ($file in @($files | Sort-Object FullName -Unique)) {
        $content = Get-Content -LiteralPath $file.FullName -Raw
        $matchCount = [regex]::Matches([string]$content, 'Release Notes|Help').Count
        if ($matchCount -gt 0) { $matchingFiles += [pscustomobject]@{ Path = $file.FullName; MatchCount = $matchCount } }
    }
    $limit = [math]::Min(40, $matchingFiles.Count)
    for ($i = 0; $i -lt $limit; $i++) { Write-Info ("  {0}: {1} matches" -f $matchingFiles[$i].Path, $matchingFiles[$i].MatchCount) }
    if ($matchingFiles.Count -gt 40) { Write-Info ("  [excerpt capped at 40 files; {0} matching files total]" -f $matchingFiles.Count) }
    $helpPosition = $IndexText.IndexOf('Help', [System.StringComparison]::OrdinalIgnoreCase)
    $releasePosition = $IndexText.IndexOf('Release Notes', [System.StringComparison]::OrdinalIgnoreCase)
    if ($helpPosition -lt 0 -or $releasePosition -lt 0) { throw 'Composed index.html does not contain both Help and Release Notes' }
    if ($helpPosition -ge $releasePosition) { throw 'Composed TOC order is not Help before Release Notes' }
    Write-Info ("  ORDER PROOF: index.html contains Help at character {0} before Release Notes at character {1}" -f $helpPosition, $releasePosition)
}

function Find-ParcelNames {
    param([string]$OutputPath)
    $indexPath = Join-Path $OutputPath 'index.html'
    if (-not (Test-Path -LiteralPath $indexPath -PathType Leaf)) { throw 'Composed index.html is missing for TOC evidence' }
    $indexText = Get-Content -LiteralPath $indexPath -Raw
    $liPattern = '(?is)<li\b(?=[^>]*\bid\s*=\s*"group:[^"]*")(?=[^>]*\bdata-group-title\s*=\s*"([^"]*)")[^>]*>'
    $names = @(); $hrefs = @()
    foreach ($m in [regex]::Matches($indexText, $liPattern)) {
        $names += [System.Net.WebUtility]::HtmlDecode($m.Groups[1].Value)
        $tail = $indexText.Substring($m.Index + $m.Length)
        $h = [regex]::Match($tail, '(?is)\bhref\s*=\s*"([^"]*)"')
        if ($h.Success) { $hrefs += $h.Groups[1].Value } else { $hrefs += '(none)' }
    }
    for ($i = 0; $i -lt $names.Count; $i++) {
        Write-Info ("Parcel: {0}  href={1}" -f $names[$i], $hrefs[$i])
    }
    foreach ($name in $names) {
        $htmlExists = Test-Path -LiteralPath (Join-Path $OutputPath ("{0}.html" -f $name)) -PathType Leaf -ErrorAction SilentlyContinue
        $directoryExists = Test-Path -LiteralPath (Join-Path $OutputPath $name) -PathType Container -ErrorAction SilentlyContinue
        $ixExists = Test-Path -LiteralPath (Join-Path $OutputPath ("{0}_ix.html" -f $name)) -PathType Leaf -ErrorAction SilentlyContinue
        $lxExists = Test-Path -LiteralPath (Join-Path $OutputPath ("{0}_lx.js" -f $name)) -PathType Leaf -ErrorAction SilentlyContinue
        $sxExists = Test-Path -LiteralPath (Join-Path $OutputPath ("{0}_sx.js" -f $name)) -PathType Leaf -ErrorAction SilentlyContinue
        Write-Info ("Deploy units for {0}: {0}.html={1} {0}\={2} {0}_ix.html={3} {0}_lx.js={4} {0}_sx.js={5}" -f $name, $htmlExists, $directoryExists, $ixExists, $lxExists, $sxExists)
    }
    Write-Info 'Parcel names found from composed index.html manifest:'
    if ($names.Count -eq 0) { Write-Info '  (none)' }
    else { foreach ($name in $names) { Write-Info ("  {0}" -f $name) } }
    return [pscustomobject]@{ Names = @($names); IndexText = $indexText }
}
function Write-CompositionFile {
    param([string]$Path, [bool]$ExplicitTarget)
    $content = @"
<?xml version="1.0" encoding="utf-8"?>
<CompositionJob name="Quantum Sync Site" version="1.0">
  <Jobs>
    <Job path="..\Quantum Sync Site Shell\Quantum Sync Site Shell.waj" role="shell" build="true" />
    <Job path="..\Quantum Sync Help\Quantum Sync Help.waj" role="parcel" build="true" />
    <Job path="..\Quantum Sync Release Notes\Quantum Sync Release Notes.waj" role="parcel" build="true" />
  </Jobs>
  <Destination name="Quantum Sync Site">
    <DeploySettings>
      <DeploySetting Name="Quantum Sync Site" Action="file">
        <Configuration Value="<Drive>:\WebWorks ePublisher AutoMap\Output\Quantum Sync Site" />
      </DeploySetting>
    </DeploySettings>
  </Destination>
</CompositionJob>
"@
    if ($ExplicitTarget) { $content = $content -replace '<Jobs>', '<Jobs target="Web Help">' }
    $content = $content.Replace('<Drive>', $Drive.TrimEnd(':'))
    $content = [regex]::Replace($content, "`r?`n", "`r`n")
    [System.IO.File]::WriteAllText($Path, $content, (New-Object System.Text.UTF8Encoding($true)))
}

try {
    if ([string]::IsNullOrWhiteSpace($EvidenceDir)) { $EvidenceDir = '{0}-evidence' -f $ScratchRoot }
    $script:ScratchRootResolved = [IO.Path]::GetFullPath($ScratchRoot)
    $script:EvidenceDirResolved = [IO.Path]::GetFullPath($EvidenceDir)
    $script:ProductFolder = "{0}:\WebWorks ePublisher AutoMap" -f $Drive.TrimEnd(':')
    $script:StagingArgument = '--stagingdir={0}' -f ([System.IO.Path]::Combine($script:ProductFolder, 'Staging'))
    $script:TranscriptPath = Join-Path $script:EvidenceDirResolved 'rehearsal-transcript.txt'
    New-Item -ItemType Directory -Path $script:EvidenceDirResolved -Force | Out-Null
    if (Test-Path -LiteralPath $script:TranscriptPath -PathType Leaf) { Remove-Item -LiteralPath $script:TranscriptPath -Force }
    Start-Transcript -LiteralPath $script:TranscriptPath -Force | Out-Null
    $script:TranscriptStarted = $true
    Write-Info 'Seeded AutoMap jobs rehearsal'
    Write-Info ("Drive: {0}" -f $Drive)
    Write-Info ("Scratch root: {0}" -f $script:ScratchRootResolved)
    Write-Info ("Evidence directory: {0}" -f $script:EvidenceDirResolved)

    Invoke-Step 1 'Preflight' {
        $driveLetter = $Drive.TrimEnd(':')
        if ($driveLetter -notmatch '^[A-Za-z]$') { throw ("-Drive must be one drive letter, got: {0}" -f $Drive) }
        $substResult = Invoke-NativeCaptured -FilePath 'subst.exe' -Arguments @()
        if ($substResult.ExitCode -ne 0) { throw ("subst listing failed with exit code {0}" -f $substResult.ExitCode) }
        $substOutput = @($substResult.Stdout) + @($substResult.Stderr)
        $driveSubstLines = @($substOutput | Where-Object { $_ -match ("(?i){0}:" -f [regex]::Escape($driveLetter)) })
        if ($driveSubstLines.Count -gt 0 -or (Test-Path -LiteralPath ("{0}:\" -f $driveLetter))) {
            Write-Info 'Existing subst/Test-Path evidence:'
            foreach ($line in $driveSubstLines) { Write-Info ([string]$line) }
            throw ("Drive {0}: is already in use" -f $driveLetter)
        }
        $requiredFiles = @(
            @{ Path = $AutomapExe; Label = 'AutoMap executable' },
            @{ Path = (Join-Path $SkillRoot 'automap\scripts\validate-job.py'); Label = 'validate-job.py' },
            @{ Path = (Join-Path $SkillRoot 'automap\scripts\list-job-targets.py'); Label = 'list-job-targets.py' },
            @{ Path = (Join-Path $SkillRoot 'reverb2\scripts\lint-output.py'); Label = 'lint-output.py' },
            @{ Path = (Join-Path $SkillRoot 'reverb2\scripts\browser-test.js'); Label = 'browser-test.js' }
        )
        foreach ($required in $requiredFiles) { if (-not (Test-Path -LiteralPath $required.Path -PathType Leaf)) { throw ("Missing {0}: {1}" -f $required.Label, $required.Path) } }
        foreach ($name in $script:JobNames) {
            $sourceJob = Join-Path $script:SourceRoot ("Jobs\{0}\{0}.waj" -f $name)
            if (-not (Test-Path -LiteralPath $sourceJob -PathType Leaf)) { throw ("Missing seeded job: {0}" -f $sourceJob) }
        }
        $version = (Get-Item -LiteralPath $AutomapExe).VersionInfo.FileVersion
        Write-Info ("AutoMap executable version: {0}" -f $version)
        Write-Info ("AutoMap executable: {0}" -f $AutomapExe)
        Write-Info ("Skill root: {0}" -f $SkillRoot)
        Write-Info ("Real Staging path: {0}" -f $RealStagingPath)
    }

    Invoke-Step 2 'Stage' {
        if (Test-Path -LiteralPath $script:ScratchRootResolved) {
            $scratchItem = Get-Item -LiteralPath $script:ScratchRootResolved
            if (-not $scratchItem.PSIsContainer -or [IO.Path]::GetPathRoot($scratchItem.FullName) -eq $scratchItem.FullName) { throw ("ScratchRoot is not a safe non-root directory: {0}" -f $scratchItem.FullName) }
            Get-ChildItem -LiteralPath $script:ScratchRootResolved -Force | Remove-Item -Recurse -Force
        }
        else { New-Item -ItemType Directory -Path $script:ScratchRootResolved -Force | Out-Null }
        $substResult = Invoke-NativeCaptured -FilePath 'subst.exe' -Arguments @(("{0}:" -f $Drive.TrimEnd(':')), $script:ScratchRootResolved)
        $substCode = $substResult.ExitCode
        Write-NativeStreams $substResult
        if ($substCode -ne 0) { throw ("subst failed with exit code {0}" -f $substCode) }
        $script:DriveCreated = $true
        New-Item -ItemType Directory -Path (Join-Path $script:ProductFolder 'Jobs') -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $script:ProductFolder 'Staging') -Force | Out-Null
        New-Item -ItemType Directory -Path (Join-Path $script:ProductFolder 'Output') -Force | Out-Null
        $robocopyResult = Invoke-NativeCaptured -FilePath 'robocopy.exe' -Arguments @((Join-Path $script:SourceRoot 'Evaluation'), (Join-Path $script:ProductFolder 'Evaluation'), '/E', '/NFL', '/NDL', '/NJH', '/NJS')
        $robocopyCode = $robocopyResult.ExitCode
        Write-NativeStreams $robocopyResult
        Write-Info ("robocopy exit code: {0} (< 8 is success)" -f $robocopyCode)
        if ($robocopyCode -ge 8) { throw ("Evaluation copy failed with robocopy exit code {0}" -f $robocopyCode) }
        $stageCode = Invoke-CapturedPython @((Join-Path $RepoRoot 'scripts\stage_seeded_jobs.py'), $script:ProductFolder) 'stage_seeded_jobs.py'
        if ($stageCode -ne 0) { throw ("stage_seeded_jobs.py returned exit code {0}" -f $stageCode) }
    }

    Invoke-Step 3 'Static validation of staged jobs' {
        $validateScript = Join-Path $SkillRoot 'automap\scripts\validate-job.py'
        $listTargetsScript = Join-Path $SkillRoot 'automap\scripts\list-job-targets.py'
        foreach ($name in $script:JobNames) {
            $jobPath = Get-JobPath $name
            $validateCode = Invoke-CapturedPython @($validateScript, '--check-documents', '--check-stationery', $jobPath) ("validate-job.py {0}" -f $name)
            if ($validateCode -ne 0) { throw ("Static validation failed for {0}" -f $name) }
            $targetCode = Invoke-CapturedPython @($listTargetsScript, '--detailed', $jobPath) ("list-job-targets.py {0}" -f $name)
            if ($targetCode -ne 0) { throw ("Target listing failed for {0}" -f $name) }
        }
    }

    Invoke-Step 4 'Build seeded jobs' {
        $script:RealStagingBeforeNames = @(Capture-RealStagingListing $RealStagingPath (Join-Path $script:ScratchRootResolved 'real-staging-before.txt') 'Real-Staging BEFORE builds')
        foreach ($name in $script:BuildOrder) { Invoke-AutomapBuild $name (Get-JobPath $name) $script:StagingArgument }
    }

    Invoke-Step 5 'Composition' {
        $compositionDirectory = Join-Path $script:ProductFolder ("Jobs\{0}" -f $script:CompositionName)
        $compositionPath = Join-Path $compositionDirectory ("{0}.wacj" -f $script:CompositionName)
        New-Item -ItemType Directory -Path $compositionDirectory -Force | Out-Null
        Write-CompositionFile $compositionPath $false
        Write-Info ("Composition job written UTF-8 BOM/CRLF: {0}" -f $compositionPath)
        $validateScript = Join-Path $SkillRoot 'automap\scripts\validate-job.py'
        $listTargetsScript = Join-Path $SkillRoot 'automap\scripts\list-job-targets.py'
        $validateCode = Invoke-CapturedPython @($validateScript, '--check-members', $compositionPath) 'validate-job.py composition'
        if ($validateCode -ne 0) { throw 'Composition member validation failed' }
        $targetCode = Invoke-CapturedPython @($listTargetsScript, '--detailed', $compositionPath) 'list-job-targets.py composition'
        if ($targetCode -ne 0) { throw 'Composition target listing failed' }
        $compositionLogPath = Join-Path $compositionDirectory ("{0}-log.txt" -f $script:CompositionName)
        $composeCode = Invoke-Composition $compositionPath $script:StagingArgument $compositionLogPath
        if ($composeCode -ne 0) {
            $composeLogText = ''
            if (Test-Path -LiteralPath $compositionLogPath -PathType Leaf) { $composeLogText = Get-Content -LiteralPath $compositionLogPath -Raw }
            $targetFailure = ($composeLogText -match '(?i)auto[- ]?detect') -or ($composeLogText -match '(?i)(target).*(not found|unable|fail|could not|select)') -or ($composeLogText -match '(?i)(no target|unable).*(select|target)')
            if (-not $targetFailure) { throw ("Composition returned exit code {0}; no target-selection failure was evidenced" -f $composeCode) }
            Write-Info 'Auto-detect failed to pick a target; re-running once with <Jobs target="Web Help">.'
            Write-CompositionFile $compositionPath $true
            $composeCode = Invoke-Composition $compositionPath $script:StagingArgument $compositionLogPath
            if ($composeCode -ne 0) { Print-LogTail $compositionLogPath; throw ("Composition with explicit target returned exit code {0}" -f $composeCode) }
            Write-Info 'Explicit target was required: Web Help.'
        }
    }

    Invoke-Step 6 'Real-Staging guard' -AllowAfterFailure {
        $script:RealStagingAfterNames = @(Capture-RealStagingListing $RealStagingPath (Join-Path $script:ScratchRootResolved 'real-staging-after.txt') 'Real-Staging AFTER composition')
        $beforeSet = @($script:RealStagingBeforeNames | Where-Object { $_ -ne '(none)' })
        $afterSet = @($script:RealStagingAfterNames | Where-Object { $_ -ne '(none)' })
        $newNames = @($afterSet | Where-Object { $beforeSet -notcontains $_ })
        $removedNames = @($beforeSet | Where-Object { $afterSet -notcontains $_ })
        Write-Info 'Real-Staging difference:'
        if ($newNames.Count -eq 0 -and $removedNames.Count -eq 0) { Write-Info '  (no folder-name difference)' }
        else {
            foreach ($name in $newNames) { $item = Get-Item -LiteralPath (Join-Path $RealStagingPath $name); Write-Info ("  NEW: {0} | CreationTime: {1}" -f $item.FullName, $item.CreationTime.ToString('o')) }
            foreach ($name in $removedNames) { Write-Info ("  REMOVED FROM AFTER LISTING: {0}" -f (Join-Path $RealStagingPath $name)) }
        }
        Write-Info 'Member builds spawned by a composition do not inherit --stagingdir and stage under the product-default Staging folder; folders this run itself created there are cleaned up automatically unless -NoRealStagingCleanup is set.'
        $cleanupNames = @($script:JobNames) + @($script:CompositionName)
        foreach ($name in $newNames) {
            $candidatePath = Join-Path $RealStagingPath $name
            $item = Get-Item -LiteralPath $candidatePath
            if ($cleanupNames -contains $name -and $item.CreationTime -gt $script:StartTime) {
                if ($NoRealStagingCleanup) {
                    Write-Info ("WOULD CLEAN (NoRealStagingCleanup set): {0} (created {1})" -f $item.FullName, $item.CreationTime.ToString('o'))
                }
                else {
                    Remove-Item -LiteralPath $candidatePath -Recurse -Force
                    Write-Info ("CLEANED: {0} (created {1})" -f $item.FullName, $item.CreationTime.ToString('o'))
                }
            }
            else {
                Write-Info ("NOT CLEANED (does not match cleanup criteria): {0}" -f $candidatePath)
            }
        }
    }

    Invoke-Step 7 'Composed-output checks' {
        $composedPath = Join-Path $script:ProductFolder ("Output\{0}" -f $script:CompositionName)
        $composedOutputExists = Test-Path -LiteralPath $composedPath -PathType Container
        Write-Info 'Composed output top-level listing:'
        if ($composedOutputExists) { Get-TopLevelListing $composedPath }
        else { Write-Info ("  (missing: {0})" -f $composedPath) }
        if (-not $composedOutputExists) { throw ("Composed output is missing: {0}" -f $composedPath) }
        $parcelEvidence = Find-ParcelNames $composedPath
        $parcelNames = @($parcelEvidence.Names)
        if ($parcelNames.Count -ne 2 -or $parcelNames[0] -ne 'Help' -or $parcelNames[1] -ne 'Release Notes') { throw ("Expected exactly the content parcels Help and Release Notes, found: {0}" -f ($parcelNames -join ', ')) }
        Write-Info 'Parcel expectation: shell contributes chrome; content parcels are exactly Help, Release Notes.'
        $shellOutputPath = Get-JobOutputPath $script:BuildOrder[0]
        $composedShellPath = Join-Path $composedPath 'wwcomposition-shell.xml'
        if (-not (Test-Path -LiteralPath $composedShellPath -PathType Leaf)) { throw ("Composed chrome file is missing: {0}" -f $composedShellPath) }
        $shellShellPath = Join-Path $shellOutputPath 'wwcomposition-shell.xml'
        if (-not (Test-Path -LiteralPath $shellShellPath -PathType Leaf)) { throw ("Chrome provenance check failed: Site Shell output is missing wwcomposition-shell.xml") }
        $composedShellText = [System.IO.File]::ReadAllText($composedShellPath)
        $shellShellText = [System.IO.File]::ReadAllText($shellShellPath)
        $generationHashPattern = 'generationHash="[0-9a-fA-F]+"'
        $normalizedComposedShellText = [regex]::Replace($composedShellText, $generationHashPattern, 'generationHash=""')
        $normalizedShellShellText = [regex]::Replace($shellShellText, $generationHashPattern, 'generationHash=""')
        if ($normalizedComposedShellText -cne $normalizedShellShellText) { throw ("Chrome provenance check failed: composed file does not match Site Shell output for wwcomposition-shell.xml apart from generationHash") }
        $getSha256Hex = {
            param([string]$Path)
            $bytes = [System.IO.File]::ReadAllBytes($Path)
            $sha256 = [System.Security.Cryptography.SHA256]::Create()
            try {
                $hashBytes = $sha256.ComputeHash($bytes)
            }
            finally {
                $sha256.Dispose()
            }
            return [BitConverter]::ToString($hashBytes)
        }
        $composedCssPath = Join-Path $composedPath 'css'
        $shellCssPath = Join-Path $shellOutputPath 'css'
        $composedCssFiles = @()
        if (Test-Path -LiteralPath $composedCssPath -PathType Container) { $composedCssFiles = @(Get-ChildItem -LiteralPath $composedCssPath -Recurse -File) }
        $shellCssFiles = @()
        if (Test-Path -LiteralPath $shellCssPath -PathType Container) { $shellCssFiles = @(Get-ChildItem -LiteralPath $shellCssPath -Recurse -File) }
        foreach ($composedCssFile in $composedCssFiles) {
            $cssRelativePath = $composedCssFile.FullName.Substring($composedCssPath.Length).TrimStart([char[]]@('\', '/'))
            $shellCssFilePath = Join-Path $shellCssPath $cssRelativePath
            $displayPath = Join-Path 'css' $cssRelativePath
            if (-not (Test-Path -LiteralPath $shellCssFilePath -PathType Leaf)) { throw ("Chrome provenance check failed: Site Shell output is missing {0}" -f $displayPath) }
            $composedHash = & $getSha256Hex $composedCssFile.FullName
            $shellHash = & $getSha256Hex $shellCssFilePath
            if ($composedHash -cne $shellHash) { throw ("Chrome provenance check failed: composed file does not match Site Shell output for {0}" -f $displayPath) }
        }
        foreach ($shellCssFile in $shellCssFiles) {
            $cssRelativePath = $shellCssFile.FullName.Substring($shellCssPath.Length).TrimStart([char[]]@('\', '/'))
            $composedCssFilePath = Join-Path $composedCssPath $cssRelativePath
            $displayPath = Join-Path 'css' $cssRelativePath
            if (-not (Test-Path -LiteralPath $composedCssFilePath -PathType Leaf)) { throw ("Chrome provenance check failed: composed output is missing {0}" -f $displayPath) }
        }
        Write-Info ("Chrome provenance: PASS ({0} css files byte-identical; wwcomposition-shell.xml identical apart from generationHash)" -f $composedCssFiles.Count)
        $compositionLogPath = Join-Path $script:ProductFolder ("Jobs\{0}\{0}-log.txt" -f $script:CompositionName)
        $scopeRoleLines = @()
        if (Test-Path -LiteralPath $compositionLogPath -PathType Leaf) { $scopeRoleLines = @(Get-Content -LiteralPath $compositionLogPath | Where-Object { $_ -match '(?i)scope|role' }) }
        Write-Info ("{0} scope/role log evidence:" -f $script:CompositionName)
        if ($scopeRoleLines.Count -eq 0) { Write-Info '  (none)' }
        else { foreach ($line in $scopeRoleLines) { Write-Info ("  {0}" -f $line) } }
        Find-TocEvidence $composedPath $parcelEvidence.IndexText
        $lintScript = Join-Path $SkillRoot 'reverb2\scripts\lint-output.py'
        $lintResult = Invoke-NativeCaptured -FilePath 'python' -Arguments @($lintScript, $composedPath)
        $lintCode = $lintResult.ExitCode
        $lintOutput = @($lintResult.Stdout) + @($lintResult.Stderr)
        Write-Info 'lint-output.py full summary:'
        foreach ($line in $lintOutput) { Write-Info ([string]$line) }
        Write-Info ("lint-output.py exit code: {0}" -f $lintCode)
        if ($lintCode -ne 0) { throw ("lint-output.py reported findings or could not run; exit code {0}" -f $lintCode) }
    }

    Invoke-Step 8 'Browser over file://' {
        $composedUrl = 'file:///{0}:/WebWorks%20ePublisher%20AutoMap/Output/{1}/index.html' -f $Drive.TrimEnd(':'), ([uri]::EscapeDataString($script:CompositionName))
        $helpUrl = 'file:///{0}:/WebWorks%20ePublisher%20AutoMap/Output/{1}/index.html' -f $Drive.TrimEnd(':'), ([uri]::EscapeDataString($script:JobNames[0]))
        if ($SkipBrowser) { Write-Info 'Browser check skipped by -SkipBrowser.'; return }
        if (-not (Test-Path -LiteralPath $ChromePath -PathType Leaf)) { throw ("Chrome is missing: {0}" -f $ChromePath) }
        $browserChecksPassed = $true
        if ($null -ne (Get-Command node -ErrorAction SilentlyContinue)) {
            $timeoutWasSet = Test-Path Env:TIMEOUT; $previousTimeout = $env:TIMEOUT; try {
                $env:TIMEOUT = '30000'; Write-Info 'Using browser-test.js TIMEOUT=30000ms.'
                $composedAttempts = @()
                $composedPassed = $false
                for ($attemptNumber = 1; $attemptNumber -le 3; $attemptNumber++) {
                    if ($attemptNumber -gt 1) { Start-Sleep -Seconds 3 }
                    $attempt = Invoke-BrowserTest $composedUrl ("browser-test composed attempt {0}" -f $attemptNumber) -Detailed
                    $composedAttempts += [pscustomobject]@{ Number = $attemptNumber; Result = $attempt }
                    if (-not $attempt.HardPassed) {
                        Write-Info ("browser-test composed attempt {0} full JSON:" -f $attemptNumber); Write-Info ([string]$attempt.JsonText)
                        throw ("Browser test hard gate failed for the composed site on attempt {0}" -f $attemptNumber)
                    }
                    if ($attempt.ParcelsLoadedAll) { $composedPassed = $true; break }
                    if ($attemptNumber -lt 3) { Write-Info ("browser-test composed attempt {0} did not load all parcels; retrying in 3 seconds." -f $attemptNumber) }
                }
                if (-not $composedPassed) {
                    foreach ($attemptRecord in $composedAttempts) {
                        Write-Info ("browser-test composed attempt {0} full JSON:" -f $attemptRecord.Number); Write-Info ([string]$attemptRecord.Result.JsonText)
                    }
                    throw 'Browser test full gate failed for the composed site after 3 attempts'
                }
                $helpPassed = Invoke-BrowserTest $helpUrl 'browser-test single Help'; $browserChecksPassed = $helpPassed
            }
            finally {
                if ($timeoutWasSet) { $env:TIMEOUT = $previousTimeout } else { Remove-Item Env:TIMEOUT -ErrorAction SilentlyContinue }
            }
        }
        else {
            Write-Info 'node is missing; using Chrome --dump-dom fallback.'
            $composedDomResult = Invoke-NativeCaptured -FilePath $ChromePath -Arguments @('--headless=new', '--disable-gpu', '--dump-dom', $composedUrl)
            $helpDomResult = Invoke-NativeCaptured -FilePath $ChromePath -Arguments @('--headless=new', '--disable-gpu', '--dump-dom', $helpUrl)
            $composedDomLines = @($composedDomResult.Stdout); $helpDomLines = @($helpDomResult.Stdout)
            ($composedDomLines -join [Environment]::NewLine) | Set-Content -LiteralPath (Join-Path $script:EvidenceDirResolved 'dom-composed.html') -Encoding UTF8
            ($helpDomLines -join [Environment]::NewLine) | Set-Content -LiteralPath (Join-Path $script:EvidenceDirResolved 'dom-help.html') -Encoding UTF8
            Write-Info ("Chrome composed DOM exit code: {0}" -f $composedDomResult.ExitCode)
            Write-Info ("Chrome Help DOM exit code: {0}" -f $helpDomResult.ExitCode)
            $composedDom = $composedDomLines -join [Environment]::NewLine
            $helpDom = $helpDomLines -join [Environment]::NewLine
            $composedHasParcels = $composedDom -match '(?i)Help' -and $composedDom -match '(?i)Release Notes'
            $helpHasGroup = $helpDom -match '(?i)Help'
            Write-Info ("Composed DOM contains both parcel names: {0}" -f $composedHasParcels)
            Write-Info ("Help DOM contains group name Help: {0}" -f $helpHasGroup)
            $browserChecksPassed = $composedDomResult.ExitCode -eq 0 -and $helpDomResult.ExitCode -eq 0 -and $composedHasParcels -and $helpHasGroup
        }
        $screenshotPath = Join-Path $script:EvidenceDirResolved 'composed.png'
        if (Test-Path -LiteralPath $screenshotPath -PathType Leaf) { Remove-Item -LiteralPath $screenshotPath -Force }
        $screenshotResult = Invoke-NativeCaptured -FilePath $ChromePath -Arguments @('--headless=new', '--disable-gpu', ("--screenshot={0}" -f $screenshotPath), '--window-size=1400,900', $composedUrl)
        Write-NativeStreams $screenshotResult
        Write-Info ("Chrome composed screenshot exit code: {0}" -f $screenshotResult.ExitCode)
        $screenshotSize = 0
        if (Test-Path -LiteralPath $screenshotPath -PathType Leaf) { $screenshotSize = (Get-Item -LiteralPath $screenshotPath).Length }
        Write-Info ("Composed screenshot: {0} ({1} bytes)" -f $screenshotPath, $screenshotSize)
        if ($screenshotResult.ExitCode -ne 0 -or $screenshotSize -le 10KB) { throw 'Chrome composed screenshot failed or was not over 10 KB' }
        if (-not $browserChecksPassed) { throw 'Browser test failed for the composed site or single Help job' }
    }

    Invoke-Step 9 'Evidence copy' -AllowAfterFailure {
        $compositionDirectory = Join-Path $script:ProductFolder ("Jobs\{0}" -f $script:CompositionName)
        $compositionPath = Join-Path $compositionDirectory ("{0}.wacj" -f $script:CompositionName)
        $filesToCopy = @(
            foreach ($name in $script:BuildOrder) { Get-JobLogPath $name }
            Join-Path $compositionDirectory ("{0}-log.txt" -f $script:CompositionName)
            $compositionPath
            foreach ($name in $script:BuildOrder) { Get-JobPath $name }
            Join-Path $script:ScratchRootResolved 'real-staging-before.txt'
            Join-Path $script:ScratchRootResolved 'real-staging-after.txt'
        )
        foreach ($file in $filesToCopy) {
            if (Test-Path -LiteralPath $file -PathType Leaf) { Copy-Item -LiteralPath $file -Destination $script:EvidenceDirResolved -Force }
            else {
                Write-Info ("Evidence source missing; not copied: {0}" -f $file)
            }
        }
        Write-Info 'Evidence directory listing:'
        foreach ($entry in @(Get-ChildItem -LiteralPath $script:EvidenceDirResolved -Force | Sort-Object Name)) {
            if ($entry.PSIsContainer) { Write-Info ("  [DIR]  {0}" -f $entry.Name) }
            else { Write-Info ("  [FILE] {0} ({1} bytes)" -f $entry.Name, $entry.Length) }
        }
    }
}
catch {
    $message = $_.Exception.Message
    Write-Info ("UNHANDLED FAILURE: {0}" -f $message)
    Add-Failure ("Unhandled script failure: {0}" -f $message)
    $script:StopRequested = $true
}
finally {
    if ($script:StopRequested -and $script:Failures.Count -gt 0) {
        Write-Info 'Failure summary:'
        foreach ($failure in $script:Failures) { Write-Info ("  {0}" -f $failure) }
    }
    if ($script:DriveCreated -and -not $KeepDrive) {
        try {
            $teardownResult = Invoke-NativeCaptured -FilePath 'subst.exe' -Arguments @(("{0}:" -f $Drive.TrimEnd(':')), '/D')
            $teardownCode = $teardownResult.ExitCode
            Write-NativeStreams $teardownResult
            if ($teardownCode -eq 0) { Write-Info 'STEP 10: Teardown -- PASS' }
            else { Write-Info ("STEP 10: Teardown -- FAIL (subst exit code {0})" -f $teardownCode); Add-Failure ("STEP 10: Teardown returned exit code {0}" -f $teardownCode) }
        }
        catch { Write-Info 'STEP 10: Teardown -- FAIL'; Write-Info ("  Failure: {0}" -f $_.Exception.Message); Add-Failure ("STEP 10: Teardown: {0}" -f $_.Exception.Message) }
    }
    elseif ($script:DriveCreated -and $KeepDrive) { Write-Info 'STEP 10: Teardown -- PASS'; Write-Info '  KeepDrive requested; subst drive left mounted.' }
    else { Write-Info 'STEP 10: Teardown -- PASS'; Write-Info '  No scratch subst drive was created.' }
    if ($script:Failures.Count -eq 0) { Write-Info 'REHEARSAL EXIT: PASS (exit code 0)' }
    else { Write-Info ("REHEARSAL EXIT: FAIL (exit code 1); failed step(s): {0}" -f ($script:Failures -join '; ')) }
    if ($script:TranscriptStarted) { Stop-Transcript | Out-Null }
}

if ($script:Failures.Count -eq 0) { exit 0 }
exit 1
