<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwbaggage="urn:WebWorks-Baggage-Schema"
                              xmlns:wwpage="urn:WebWorks-Page-Template-Schema"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              exclude-result-prefixes="xsl msxsl wwtoc wwlinks wwmode wwfiles wwdoc wwsplits wwproject wwbaggage wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterDocumentType" />
 <xsl:param name="ParameterBaggageType" />
 <xsl:param name="ParameterLocaleType" />
 <xsl:param name="ParameterPageTemplateURI" />
 <xsl:param name="ParameterCopySplitFileType" />
 <xsl:param name="ParameterBaggageSplitFileType" />
 <xsl:param name="ParameterTOCSplitFileType" />
 <xsl:param name="ParameterIndexSplitFileType" />
 <xsl:param name="ParameterDocumentFOPDFSplitFileType" />
 <xsl:param name="ParameterGroupFOPDFSplitFileType" />


 <xsl:output encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="wwsplits" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwtransform:common/files/filter.xsl" />
 <xsl:include href="wwtransform:common/files/format.xsl" />
 <xsl:include href="wwtransform:common/files/utils.xsl" />
 <xsl:include href="wwtransform:common/variables/variables.xsl" />
 <xsl:include href="wwtransform:common/pages/pagetemplate.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwproject-group-by-groupid" match="wwproject:Group" use="@GroupID" />
 <xsl:key name="wwproject-formatconfigurations-by-targetid" match="wwproject:FormatConfiguration" use="@TargetID" />
 <xsl:key name="wwsplits-splits-by-documentid" match="wwsplits:Split" use="@documentID" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath($ParameterPageTemplateURI), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath($ParameterPageTemplateURI)))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/filter.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/filter.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/format.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/format.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/variables/variables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/variables/variables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <!-- Page Template -->
 <!--               -->
 <xsl:variable name="GlobalPageTemplatePath" select="wwuri:AsFilePath($ParameterPageTemplateURI)" />
 <xsl:variable name="GlobalPageTemplate" select="wwexsldoc:LoadXMLWithoutResolver($GlobalPageTemplatePath)" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Iterate input documents -->
   <!--                         -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:value-of select="wwprogress:Start(count($VarFilesByType))" />

    <!-- Load locale -->
    <!--             -->
    <xsl:variable name="VarFilesLocale" select="key('wwfiles-files-by-type', $ParameterLocaleType)" />
    <xsl:variable name="VarLocale" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesLocale/@path)" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:value-of select="wwprogress:Start(1)" />

     <xsl:variable name="VarFilesDocument" select="." />

     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFilesDocument/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <!-- Get format files -->
     <!--                  -->
     <xsl:variable name="VarFormatFilesAsXML">
      <xsl:call-template name="Files-Format-GetRelativeFiles">
       <xsl:with-param name="ParamRelativeURIPath" select="'Files'" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarFormatFiles" select="msxsl:node-set($VarFormatFilesAsXML)" />
     <xsl:variable name="VarFormatFilesPaths">
      <xsl:for-each select="$VarFormatFiles/wwfiles:Files/wwfiles:File">
       <xsl:value-of select="@path" />
       <xsl:value-of select="':'" />
      </xsl:for-each>
     </xsl:variable>
     <xsl:variable name="VarFormatFilesChecksum" select="wwstring:MD5Checksum($VarFormatFilesPaths)" />

     <!-- Get page template files -->
     <!--                         -->
     <xsl:variable name="VarPageTemplateFilesAsXML">
      <xsl:apply-templates select="$GlobalPageTemplate" mode="wwmode:pagetemplate-files" />
     </xsl:variable>
     <xsl:variable name="VarPageTemplateFiles" select="msxsl:node-set($VarPageTemplateFilesAsXML)" />
     <xsl:variable name="VarPageTemplateFilesPaths">
      <xsl:for-each select="$VarPageTemplateFiles/wwpage:File">
       <xsl:value-of select="@path" />
       <xsl:value-of select="':'" />
      </xsl:for-each>
     </xsl:variable>
     <xsl:variable name="VarPageTemplateFilesChecksum" select="wwstring:MD5Checksum($VarPageTemplateFilesPaths)" />

     <!-- Get project files -->
     <!--                   -->
     <xsl:variable name="VarProjectFiles" select="wwfilesystem:GetFiles(wwprojext:GetProjectFilesDirectoryPath())" />
     <xsl:variable name="VarProjectFilesPaths">
      <xsl:for-each select="$VarProjectFiles/wwfiles:Files/wwfiles:File">
       <xsl:value-of select="@path" />
       <xsl:value-of select="':'" />
      </xsl:for-each>
     </xsl:variable>
     <xsl:variable name="VarProjectFilesChecksum" select="wwstring:MD5Checksum($VarProjectFilesPaths)" />

     <!-- Get baggage files -->
     <!--                   -->
     <xsl:variable name="VarBaggageFilesFile" select="key('wwfiles-files-by-type', $ParameterBaggageType)[@groupID = $VarFilesDocument/@groupID][1]" />

     <!-- Determine group name -->
     <!--                      -->
     <xsl:variable name="VarGroupName">
      <xsl:for-each select="$GlobalProject[1]">
       <xsl:value-of select="key('wwproject-group-by-groupid', $VarFilesDocument/@groupID)/@Name" />
      </xsl:for-each>
     </xsl:variable>

     <!-- Determine group output directory path -->
     <!--                                       -->
     <xsl:variable name="VarReplacedGroupName">
      <xsl:call-template name="ReplaceGroupNameSpacesWith">
       <xsl:with-param name="ParamText" select="$VarGroupName" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarGroupOutputDirectoryPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'))" />

     <!-- Transform -->
     <!--           -->
     <xsl:variable name="VarProjectChecksum" select="concat($GlobalProject/wwproject:Project/@ChangeID, ':', $VarFormatFilesChecksum, ':', $VarPageTemplateFilesChecksum, ':', $VarProjectFilesChecksum)" />
     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $VarProjectChecksum, $VarFilesDocument/@groupID, '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <!-- Load document -->
       <!--               -->
       <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesDocument/@path)" />

       <!-- Add files -->
       <!--           -->
       <xsl:call-template name="Files">
        <xsl:with-param name="ParamLocale" select="$VarLocale" />
        <xsl:with-param name="ParamGroupID" select="$VarFilesDocument/@groupID" />
        <xsl:with-param name="ParamGroupOutputDirectoryPath" select="$VarGroupOutputDirectoryPath" />
        <xsl:with-param name="ParamFormatFiles" select="$VarFormatFiles" />
        <xsl:with-param name="ParamProjectFiles" select="$VarProjectFiles" />
        <xsl:with-param name="ParamPageTemplateFiles" select="$VarPageTemplateFiles" />
        <xsl:with-param name="ParamSplits" select="$VarSplits" />
        <xsl:with-param name="ParamBaggageFiles" select="wwexsldoc:LoadXMLWithoutResolver($VarBaggageFilesFile/@path)/wwbaggage:Baggage/wwbaggage:File" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, 'utf-8', 'xml', '1.0', 'yes')" />
     </xsl:if>

     <!-- Report Files -->
     <!--              -->
     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$VarProjectChecksum}" groupID="{$VarFilesDocument/@groupID}" documentID="" actionchecksum="{$GlobalActionChecksum}" category="" use="">
      <wwfiles:Depends path="{$VarFilesLocale/@path}" checksum="{$VarFilesLocale/@checksum}" groupID="{$VarFilesLocale/@groupID}" documentID="{$VarFilesLocale/@documentID}" />
      <wwfiles:Depends path="{$VarFilesDocument/@path}" checksum="{$VarFilesDocument/@checksum}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" />
      <wwfiles:Depends path="{$VarBaggageFilesFile/@path}" checksum="{$VarBaggageFilesFile/@checksum}" groupID="{$VarBaggageFilesFile/@groupID}" documentID="{$VarBaggageFilesFile/@documentID}" />
      <wwfiles:Depends path="{$GlobalPageTemplatePath}" checksum="{wwfilesystem:GetChecksum($GlobalPageTemplatePath)}" groupID="" documentID="" />
     </wwfiles:File>

     <xsl:value-of select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:value-of select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>

 <xsl:template name="Files">
  <xsl:param name="ParamLocale" />
  <xsl:param name="ParamGroupID" />
  <xsl:param name="ParamGroupOutputDirectoryPath" />
  <xsl:param name="ParamFormatFiles" />
  <xsl:param name="ParamProjectFiles" />
  <xsl:param name="ParamPageTemplateFiles" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBaggageFiles" />

  <!-- Copy splits with new file entries added -->
  <!--                                         -->
  <wwsplits:Splits>
   <xsl:copy-of select="$ParamSplits/wwsplits:Splits/@*" />

   <!-- Format Files -->
   <!--              -->
   <xsl:for-each select="$ParamFormatFiles/wwfiles:Files/wwfiles:File">
    <xsl:variable name="VarFormatFile" select="." />

    <xsl:variable name="VarFormatFilePath" select="wwfilesystem:Combine($ParamGroupOutputDirectoryPath, $VarFormatFile/@path)" />

    <!-- Allow? -->
    <!--        -->
    <xsl:variable name="VarAllow">
     <xsl:call-template name="Files-Filter-Allow">
      <xsl:with-param name="ParamPath" select="$VarFormatFilePath" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:if test="$VarAllow = 'true'">
     <!-- Emit -->
     <!--      -->
     <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterCopySplitFileType}" source="{wwuri:MakeAbsolute('wwformat:Files/', $VarFormatFile/@path)}" path="{$VarFormatFilePath}" title="" />
    </xsl:if>
   </xsl:for-each>

   <!-- Page Template Files -->
   <!--                     -->
   <xsl:for-each select="$ParamPageTemplateFiles/wwpage:File">
    <xsl:variable name="VarPageTemplateFile" select="." />

    <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterCopySplitFileType}" source="{concat('wwformat:Pages/', $VarPageTemplateFile/@path)}" path="{wwfilesystem:Combine($ParamGroupOutputDirectoryPath, $VarPageTemplateFile/@path)}" title="" />
   </xsl:for-each>

   <!-- Group result path -->
   <!--                   -->
   <xsl:variable name="VarGroupTitle">
    <xsl:for-each select="$GlobalProject[1]">
     <xsl:variable name="VarFormatConfiguration" select="key('wwproject-formatconfigurations-by-targetid', wwprojext:GetFormatID())[1]" />
     <xsl:variable name="VarMergeSettings" select="$VarFormatConfiguration/wwproject:MergeSettings" />

     <xsl:variable name="VarMergeGroupTitle" select="$VarMergeSettings/wwproject:MergeGroup[@GroupID = $ParamGroupID][1]/@Title" />
     <xsl:choose>
      <xsl:when test="string-length($VarMergeGroupTitle) &gt; 0">
       <xsl:value-of select="$VarMergeGroupTitle" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="wwprojext:GetGroupName($ParamGroupID)" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:for-each>
   </xsl:variable>

   <xsl:variable name="VarReplacedGroupName">
    <xsl:call-template name="ReplaceGroupNameSpacesWith">
     <xsl:with-param name="ParamText" select="wwprojext:GetGroupName($ParamGroupID)" />
    </xsl:call-template>
   </xsl:variable>
   <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterGroupFOPDFSplitFileType}" source="" path="{wwfilesystem:Combine($ParamGroupOutputDirectoryPath, concat(wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'), '.pdf'))}" title="{$VarGroupTitle}" />

   <!-- Document result paths -->
   <!--                       -->
   <xsl:for-each select="$GlobalProject[1]">
    <xsl:variable name="VarProjectGroup" select="key('wwproject-group-by-groupid', $ParamGroupID)" />
    <xsl:for-each select="$VarProjectGroup//wwproject:Document">
     <xsl:variable name="VarProjectDocument" select="." />

     <xsl:variable name="VarDocumentTitle">
      <xsl:for-each select="$ParamSplits[1]">
       <xsl:variable name="VarSplit" select="key('wwsplits-splits-by-documentid', $VarProjectDocument/@DocumentID)[1]" />

       <xsl:value-of select="$VarSplit/@title" />
      </xsl:for-each>
     </xsl:variable>

     <xsl:variable name="VarFileNameWithoutExtension">
      <xsl:call-template name="ConvertNameTo">
       <xsl:with-param name="ParamText" select="wwfilesystem:GetFileNameWithoutExtension($VarProjectDocument/@Path)" />
      </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="VarReplacedFileNameWithoutExtension">
      <xsl:call-template name="ReplaceFileNameSpacesWith">
       <xsl:with-param name="ParamText" select="$VarFileNameWithoutExtension" />
      </xsl:call-template>
     </xsl:variable>
     <wwsplits:File groupID="{$ParamGroupID}" documentID="{$VarProjectDocument/@DocumentID}" id="" type="{$ParameterDocumentFOPDFSplitFileType}" source="" path="{wwfilesystem:Combine($ParamGroupOutputDirectoryPath, concat(wwstring:ReplaceWithExpression($VarReplacedFileNameWithoutExtension, $GlobalInvalidPathCharactersExpression, '_'), '.pdf'))}" title="{$VarDocumentTitle}" />
    </xsl:for-each>
   </xsl:for-each>

   <!-- Reprocess existing split entries -->
   <!--                                  -->
   <xsl:apply-templates select="$ParamSplits/wwsplits:Splits/wwsplits:*" mode="wwmode:reprocess-splits" />

   <!-- Baggage -->
   <!--         -->
   <xsl:for-each select="$ParamBaggageFiles">
    <xsl:variable name="VarBaggageFile" select="." />
    
    <xsl:variable name="VarPath" select="wwfilesystem:Combine($ParamGroupOutputDirectoryPath, 'baggage', wwstring:ReplaceWithExpression(wwfilesystem:GetFileName($VarBaggageFile/@path), $GlobalInvalidPathCharactersExpression, '_'))" />

    <wwsplits:File groupID="{$ParamGroupID}" documentID="" id="" type="{$ParameterBaggageSplitFileType}" source="{$VarBaggageFile/@path}" path="{$VarPath}" title="" />
   </xsl:for-each>
  </wwsplits:Splits>
 </xsl:template>


 <!-- wwmode:reprocess-splits -->
 <!--                         -->

 <xsl:template match="/" mode="wwmode:reprocess-splits">
  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:reprocess-splits" />
 </xsl:template>

 <xsl:template match="*" mode="wwmode:reprocess-splits">
  <!-- Preserve as is -->
  <!--                -->
  <xsl:copy>
   <xsl:copy-of select="@*" />

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:reprocess-splits" />
  </xsl:copy>
 </xsl:template>

 <xsl:template match="wwsplits:Frame | wwsplits:Thumbnail" mode="wwmode:reprocess-splits">
  <xsl:param name="ParamSplitsEntry" select="." />

  <!-- Reset output path -->
  <!--                   -->
  <xsl:variable name="VarSplit" select="$ParamSplitsEntry/ancestor::wwsplits:Split[1]" />
  <xsl:variable name="VarOutputPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), $VarSplit/@groupID, $VarSplit/@documentID, wwfilesystem:GetFileName($ParamSplitsEntry/@path))" />

  <!-- Emit element with updated path -->
  <!--                                -->
  <xsl:copy>
   <xsl:copy-of select="$ParamSplitsEntry/@*[local-name() != 'path']" />
   <xsl:attribute name="path">
    <xsl:value-of select="$VarOutputPath" />
   </xsl:attribute>

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:reprocess-splits" />
  </xsl:copy>
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:reprocess-splits">
  <!-- Ignore -->
  <!--        -->
 </xsl:template>
</xsl:stylesheet>
