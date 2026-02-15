<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-XSLT-Flow-Schema"
                              xmlns:flo="urn:WebWorks-XSLT-Flow-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwvars="urn:WebWorks-Variables-Schema"
                              xmlns:wwnotes="urn:WebWorks-Footnote-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwimaging="urn:WebWorks-XSLT-Extension-Imaging"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwbehaviors wwvars wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />


 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="flo" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwproject-formatconfigurations-by-targetid" match="wwproject:FormatConfiguration" use="@TargetID" />
 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">
   <xsl:if test="wwprojext:GetFormatSetting('generate-project-result') = 'true'">
    <xsl:for-each select="$GlobalProject[1]">
     <xsl:variable name="VarFormatConfiguration" select="key('wwproject-formatconfigurations-by-targetid', wwprojext:GetFormatID())[1]" />
     <xsl:variable name="VarMergeSettings" select="$VarFormatConfiguration/wwproject:MergeSettings" />

     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), concat(translate($ParameterType, ':', '_'), '.xml'))" />

     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, '', '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <flo:Flows>
        <!-- Groups -->
        <!--        -->
        <xsl:variable name="VarMergeGroups" select="$VarMergeSettings//wwproject:MergeGroup" />
        <xsl:variable name="VarProgressMergeGroupsStart" select="wwprogress:Start(count($VarMergeGroups))" />
        <xsl:for-each select="$VarMergeGroups">
         <xsl:variable name="VarMergeGroup" select="." />

         <xsl:variable name="VarProgressMergeGroupStart" select="wwprogress:Start(1)" />

         <!-- Aborted? -->
         <!--          -->
         <xsl:if test="not(wwprogress:Abort())">
          <xsl:for-each select="$GlobalFiles[1]">
           <!-- Group Splits -->
           <!--              -->
           <xsl:variable name="VarFilesSplits" select="key('wwfiles-files-by-type', $ParameterDependsType)[@groupID = $VarMergeGroup/@GroupID]" />
           <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesSplits/@path)" />

           <!-- Aborted? -->
           <!--          -->
           <xsl:if test="not(wwprogress:Abort())">
            <xsl:for-each select="$GlobalFiles[1]">
             <xsl:call-template name="Flows-Flows">
              <xsl:with-param name="ParamSplits" select="$VarSplits/wwsplits:Splits/wwsplits:Split" />
             </xsl:call-template>
            </xsl:for-each>
           </xsl:if>
          </xsl:for-each>
         </xsl:if>

         <xsl:variable name="VarProgressMergeGroupEnd" select="wwprogress:End()" />
        </xsl:for-each>

        <xsl:variable name="VarProgressMergeGroupsEnd" select="wwprogress:End()" />
       </flo:Flows>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />

      <!-- Aborted? -->
      <!--          -->
      <xsl:if test="not(wwprogress:Abort())">
       <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, wwprojext:GetFormatSetting('encoding', 'utf-8'), 'xml', '1.0', 'yes')" />
      </xsl:if>
     </xsl:if>

     <!-- Aborted? -->
     <!--          -->
     <xsl:if test="not(wwprogress:Abort())">
      <!-- Record files -->
      <!--              -->
      <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}">
       <!-- Groups -->
       <!--        -->
       <xsl:variable name="VarMergeGroups" select="$VarMergeSettings//wwproject:MergeGroup" />
       <xsl:for-each select="$VarMergeGroups">
        <xsl:variable name="VarMergeGroup" select="." />

        <xsl:for-each select="$GlobalFiles[1]">
         <!-- Group Splits -->
         <!--              -->
         <xsl:variable name="VarFilesSplits" select="key('wwfiles-files-by-type', $ParameterDependsType)[@groupID = $VarMergeGroup/@GroupID]" />
         <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesSplits/@path)" />

         <xsl:for-each select="$VarSplits/wwsplits:Splits/wwsplits:Split">
          <wwfiles:Depends path="{$VarFilesSplits/@path}" checksum="{$VarFilesSplits/@checksum}" groupID="{$VarFilesSplits/@groupID}" documentID="{$VarFilesSplits/@documentID}" />
         </xsl:for-each>
        </xsl:for-each>
       </xsl:for-each>
      </wwfiles:File>
     </xsl:if>
    </xsl:for-each>
   </xsl:if>
  </wwfiles:Files>
 </xsl:template>

 <xsl:template name="Flows-Flows">
  <xsl:param name="ParamSplits" />

  <xsl:for-each select="$ParamSplits">
   <xsl:variable name="VarSplit" select="." />

   <xsl:variable name="VarPageOutputPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), $VarSplit/@groupID, $VarSplit/@documentID, concat('page_project_output_', $VarSplit/@position, '.xml'))" />
   <flo:Flow page-path="{$VarPageOutputPath}">
    <xsl:copy-of select="$VarSplit/@*" />
   </flo:Flow>
  </xsl:for-each>
 </xsl:template>
</xsl:stylesheet>
