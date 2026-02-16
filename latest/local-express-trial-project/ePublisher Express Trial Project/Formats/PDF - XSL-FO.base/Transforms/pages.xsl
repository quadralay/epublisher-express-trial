<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Format"
                              xmlns:fo="http://www.w3.org/1999/XSL/Format"
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
                              exclude-result-prefixes="flo xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwbehaviors wwvars wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterGenerateSetting" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterSegmentsType" select="''" />
 <xsl:param name="ParameterLinksType" />
 <xsl:param name="ParameterLocaleType" />
 <xsl:param name="ParameterFlowsType" />
 <xsl:param name="ParameterSplitsType" />
 <xsl:param name="ParameterBehaviorsType" />
 <xsl:param name="ParameterProjectVariablesType" />
 <xsl:param name="ParameterTOCDataType" />
 <xsl:param name="ParameterAllowBaggage" />
 <xsl:param name="ParameterAllowGroupToGroup" />
 <xsl:param name="ParameterAllowURL" />
 <xsl:param name="ParameterBaggageSplitFileType" />
 <xsl:param name="ParameterGroupSplitFileType" />
 <xsl:param name="ParameterMode" />
 <xsl:param name="ParameterType" />


 <xsl:variable name="GlobalDefaultNamespace" select="'http://www.w3.org/1999/XSL/Format'" />


 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="fo" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwsplits-split-by-documentid" match="wwsplits:Split" use="@documentID" />
 <xsl:key name="wwsplits-files-by-type" match="wwsplits:File" use="@type" />
 <xsl:key name="wwtoc-entry-by-documentid" match="wwtoc:Entry" use="@documentID" />


 <xsl:include href="wwtransform:common/accessibility/images.xsl"/>
 <xsl:include href="wwtransform:common/behaviors/options.xsl"/>
 <xsl:include href="wwtransform:common/images/utilities.xsl" />
 <xsl:include href="wwtransform:common/links/resolve.xsl" />
 <xsl:include href="wwtransform:common/pages/pages.xsl" />
 <xsl:include href="wwtransform:common/project/conditions.xsl" />
 <xsl:include href="wwtransform:common/project/properties.xsl" />
 <xsl:include href="wwtransform:common/tables/tables.xsl" />
 <xsl:include href="wwtransform:common/variables/variables.xsl" />
 <xsl:include href="wwtransform:common/files/utils.xsl" />
 <xsl:include href="wwtransform:fo/fo_properties.xsl" />
 <xsl:include href="wwtransform:uri/uri.xsl" />
 <xsl:include href="wwformat:Transforms/content.xsl" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/accessibility/images.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/accessibility/images.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/behaviors/options.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/behaviors/options.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/images/utilities.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/images/utilities.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/links/resolve.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/links/resolve.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/pages/pages.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/pages/pages.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/project/conditions.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/project/conditions.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/project/properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/project/properties.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/tables/tables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/tables/tables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/variables/variables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/variables/variables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:fo/fo_properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:fo/fo_properties.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:uri/uri.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:uri/uri.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/content.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/content.xsl')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <!-- Locale -->
 <!--        -->
 <xsl:variable name="GlobalLocalePath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterLocaleType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalLocale" select="wwexsldoc:LoadXMLWithoutResolver($GlobalLocalePath)" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:if test="wwprojext:GetFormatSetting($ParameterGenerateSetting) = 'true'">
    <xsl:call-template name="DocumentsPages">
     <xsl:with-param name="ParamInput" select="$GlobalInput" />
     <xsl:with-param name="ParamProject" select="$GlobalProject" />
     <xsl:with-param name="ParamFiles" select="$GlobalFiles" />
     <xsl:with-param name="ParamLinksType" select="$ParameterLinksType" />
     <xsl:with-param name="ParamDependsType" select="$ParameterDependsType" />
     <xsl:with-param name="ParamSegmentsType" select="$ParameterSegmentsType" />
     <xsl:with-param name="ParamSplitsType" select="$ParameterSplitsType" />
     <xsl:with-param name="ParamBehaviorsType" select="$ParameterBehaviorsType" />
     <xsl:with-param name="ParamTOCDataType" select="$ParameterTOCDataType" />
    </xsl:call-template>
   </xsl:if>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Page">
  <xsl:param name="ParamFilesSplits" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamBehaviorsFile" />
  <xsl:param name="ParamBehaviors" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamBreadcrumbTOCEntry" />
  <xsl:param name="ParamFilesDocumentNode" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamDocument" />
  <xsl:param name="ParamContent" />

  <!-- Output -->
  <!--        -->
  <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetGroupDataDirectoryPath($ParamSplit/@groupID), $ParamSplit/@documentID, concat(translate($ParameterType, ':', '_'), '_', $ParamSplit/@position, '.xml'))" />
  <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $ParamSplit/@groupID, $ParamSplit/@documentID, $GlobalActionChecksum)" />
  <xsl:if test="not($VarUpToDate)">
   <!-- Notes -->
   <!--       -->
   <xsl:variable name="VarNotes" select="$ParamContent//wwdoc:Note[not(ancestor::wwdoc:Table) and not(ancestor::wwdoc:Frame)]" />

   <!-- Note numbering -->
   <!--                -->
   <xsl:variable name="VarNoteNumberingAsXML">
    <xsl:call-template name="Notes-Number">
     <xsl:with-param name="ParamNotes" select="$VarNotes" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarNoteNumbering" select="msxsl:node-set($VarNoteNumberingAsXML)" />

   <!-- Cargo -->
   <!--       -->
   <xsl:variable name="VarCargo" select="$ParamBehaviors | $VarNoteNumbering" />

   <!-- Flow Name -->
   <!--           -->
   <xsl:variable name="VarFlowName">
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarFilesFlows" select="key('wwfiles-files-by-type', $ParameterFlowsType)" />

     <xsl:choose>
      <xsl:when test="$ParameterMode = 'document'">
       <xsl:variable name="VarFilesFlow" select="$VarFilesFlows[@documentID = $ParamSplit/@documentID][1]" />
       <xsl:variable name="VarFlow" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesFlow/@path)" />
       <xsl:variable name="VarFlowSplit" select="$VarFlow//wwsplits:Split[@id = $ParamSplit/@id][1]" />
       <xsl:value-of select="$VarFlowSplit/parent::flo:Flow[1]/@name" />
      </xsl:when>

      <xsl:when test="$ParameterMode = 'group'">
       <xsl:variable name="VarFilesFlow" select="$VarFilesFlows[@groupID = $ParamSplit/@groupID][1]" />
       <xsl:variable name="VarFlow" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesFlow/@path)" />
       <xsl:variable name="VarFlowSplit" select="$VarFlow//wwsplits:Split[@documentID = $ParamSplit/@documentID][@id = $ParamSplit/@id][1]" />
       <xsl:value-of select="$VarFlowSplit/parent::flo:Flow[1]/@name" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:variable name="VarFilesFlow" select="$VarFilesFlows[1]" />
       <xsl:variable name="VarFlow" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesFlow/@path)" />
       <xsl:variable name="VarFlowSplit" select="$VarFlow//wwsplits:Split[@groupID = $ParamSplit/@groupID][@documentID = $ParamSplit/@documentID][@id = $ParamSplit/@id][1]" />
       <xsl:value-of select="$VarFlowSplit/parent::flo:Flow[1]/@name" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:for-each>
   </xsl:variable>

   <xsl:variable name="VarResult">
    <fo:root flow="{$VarFlowName}" sid="{$ParamSplit/@id}">
     <!-- Content -->
     <!--         -->
     <xsl:call-template name="Content-Content">
      <xsl:with-param name="ParamContent" select="$ParamContent" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$VarCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     </xsl:call-template>
    </fo:root>
   </xsl:variable>

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
   <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$ParamSplit/@groupID}" documentID="{$ParamSplit/@documentID}" actionchecksum="{$GlobalActionChecksum}">
    <wwfiles:Depends path="{$GlobalLocalePath}" checksum="{wwfilesystem:GetChecksum($GlobalLocalePath)}" groupID="" documentID="" />
    <wwfiles:Depends path="{$ParamFilesDocumentNode/@path}" checksum="{$ParamFilesDocumentNode/@checksum}" groupID="{$ParamFilesDocumentNode/@groupID}" documentID="{$ParamFilesDocumentNode/@documentID}" />
    <wwfiles:Depends path="{$ParamFilesSplits/@path}" checksum="{$ParamFilesSplits/@checksum}" groupID="{$ParamFilesSplits/@groupID}" documentID="{$ParamFilesSplits/@documentID}" />
    <wwfiles:Depends path="{$ParamBehaviorsFile/@path}" checksum="{$ParamBehaviorsFile/@checksum}" groupID="{$ParamBehaviorsFile/@groupID}" documentID="{$ParamBehaviorsFile/@documentID}" />
   </wwfiles:File>
  </xsl:if>
 </xsl:template>
</xsl:stylesheet>
