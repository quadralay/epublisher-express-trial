<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Format"
                              xmlns:fo="http://www.w3.org/1999/XSL/Format"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwindex="urn:WebWorks-Index-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwvars="urn:WebWorks-Variables-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
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
                              exclude-result-prefixes="xsl msxsl wwindex wwlinks wwmode wwfiles wwdoc wwsplits wwvars wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterPagesType" />
 <xsl:param name="ParameterTOCType" />
 <xsl:param name="ParameterIndexType" />
 <xsl:param name="ParameterFlowsType" />
 <xsl:param name="ParameterSplitsType" />
 <xsl:param name="ParameterLocaleType" />
 <xsl:param name="ParameterProjectVariablesType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterPageTemplateType" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:output encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="fo" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:include href="wwtransform:common/companyinfo/companyinfo_content.xsl" />
 <xsl:include href="wwtransform:fo/fo_properties.xsl" />
 <xsl:include href="wwtransform:common/variables/variables.xsl" />
 <xsl:include href="wwtransform:common/pages/pagetemplate.xsl" />
 <xsl:include href="wwtransform:common/project/properties.xsl" />
 <xsl:include href="wwtransform:uri/uri.xsl" />
 <xsl:include href="wwformat:Transforms/stitch.xsl" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwsplits-files-by-type" match="wwsplits:File" use="@type" />
 <xsl:key name="wwproject-formatconfigurations-by-targetid" match="wwproject:FormatConfiguration" use="@TargetID" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/companyinfo/companyinfo_content.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/companyinfo/companyinfo_content.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:html/css_properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:html/css_properties.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/variables/variables.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/variables/variables.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/pages/pagetemplate.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/project/properties.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/project/properties.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:uri/uri.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:uri/uri.xsl')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwformat:Transforms/stitch.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwformat:Transforms/stitch.xsl')))" />
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


 <!-- Mapping Entry Sets -->
 <!--                    -->
 <xsl:variable name="GlobalMapEntrySetsPath" select="wwuri:AsFilePath('wwtransform:fo/mapentrysets.xml')" />
 <xsl:variable name="GlobalMapEntrySets" select="wwexsldoc:LoadXMLWithoutResolver($GlobalMapEntrySetsPath)" />


 <!-- Project variables -->
 <!--                   -->
 <xsl:variable name="GlobalProjectVariablesPath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterProjectVariablesType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalProjectVariables" select="wwexsldoc:LoadXMLWithoutResolver($GlobalProjectVariablesPath)" />


 <xsl:template match="/">
  <wwfiles:Files version="1.0">
   <!-- Project level stitch file -->
   <!--                           -->
   <xsl:if test="wwprojext:GetFormatSetting('generate-project-result') = 'true'">
    <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwprojext:GetTargetDataDirectoryPath(), concat(translate($ParameterType, ':', '_'), '.fo'))" />

    <xsl:for-each select="$GlobalInput[1]">
     <xsl:variable name="VarPagesFiles" select="key('wwfiles-files-by-type', $ParameterPagesType)" />

     <xsl:for-each select="$GlobalFiles[1]">
      <!-- Project TOC file -->
      <!--                  -->
      <xsl:variable name="VarTOCFile" select="key('wwfiles-files-by-type', $ParameterTOCType)[1]" />
      <xsl:variable name="VarTOC" select="wwexsldoc:LoadXMLWithoutResolver($VarTOCFile/@path)" />

      <!-- Project Index file -->
      <!--                    -->
      <xsl:variable name="VarIndexFile" select="key('wwfiles-files-by-type', $ParameterIndexType)[1]" />
      <xsl:variable name="VarIndex" select="wwexsldoc:LoadXMLWithoutResolver($VarIndexFile/@path)" />

      <!-- Page template -->
      <!--               -->
      <xsl:variable name="VarPageTemplateFile" select="key('wwfiles-files-by-type', $ParameterPageTemplateType)[1]" />
      <xsl:variable name="VarPageTemplate" select="wwexsldoc:LoadXMLWithoutResolver($VarPageTemplateFile/@path)" />

      <!-- Flows -->
      <!--       -->
      <xsl:variable name="VarFlowsFile" select="key('wwfiles-files-by-type', $ParameterFlowsType)[1]" />
      <xsl:variable name="VarFlows" select="wwexsldoc:LoadXMLWithoutResolver($VarFlowsFile/@path)" />

      <!-- Project Splits -->
      <!--                -->
      <xsl:variable name="VarSplitsFile" select="key('wwfiles-files-by-type', $ParameterSplitsType)[1]" />
      <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarSplitsFile/@path)" />

      <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarPagesFiles)), $GlobalProject/wwproject:Project/@GroupID, '', $GlobalActionChecksum)" />
      <xsl:if test="not($VarUpToDate)">
       <xsl:variable name="VarResultAsXML">
        <!-- Title -->
        <!--       -->
        <xsl:variable name="VarTitle">
         <xsl:for-each select="$GlobalProject[1]">
          <xsl:variable name="VarFormatConfiguration" select="key('wwproject-formatconfigurations-by-targetid', wwprojext:GetFormatID())[1]" />
          <xsl:variable name="VarMergeSettings" select="$VarFormatConfiguration/wwproject:MergeSettings" />

          <xsl:choose>
           <xsl:when test="string-length($VarMergeSettings/@Title) &gt; 0">
            <xsl:value-of select="$VarMergeSettings/@Title" />
           </xsl:when>

           <xsl:otherwise>
            <xsl:value-of select="wwprojext:GetFormatName()" />
           </xsl:otherwise>
          </xsl:choose>
         </xsl:for-each>
        </xsl:variable>

        <!-- Pass to call template for processing -->
        <!--                                      -->
        <xsl:call-template name="Stitch">
         <xsl:with-param name="ParamSplits" select="$VarSplits" />
         <xsl:with-param name="ParamTOC" select="$VarTOC" />
         <xsl:with-param name="ParamIndex" select="$VarIndex" />
         <xsl:with-param name="ParamPagesFiles" select="$VarPagesFiles" />
         <xsl:with-param name="ParamFlows" select="$VarFlows" />
         <xsl:with-param name="ParamGroupID" select="''" />
         <xsl:with-param name="ParamDocumentID" select="''" />
         <xsl:with-param name="ParamPath" select="$VarPath" />
         <xsl:with-param name="ParamTitle" select="$VarTitle" />
         <xsl:with-param name="ParamPageTemplate" select="$VarPageTemplate" />
        </xsl:call-template>
       </xsl:variable>
       <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />

       <!-- Aborted? -->
       <!--          -->
       <xsl:if test="not(wwprogress:Abort())">
        <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, wwprojext:GetFormatSetting('encoding', 'utf-8'), 'xml', '1.0', 'no')" />
       </xsl:if>
      </xsl:if>

      <!-- Aborted? -->
      <!--          -->
      <xsl:if test="not(wwprogress:Abort())">
       <!-- Report Files -->
       <!--              -->
       <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{concat($GlobalProject/wwproject:Project/@ChangeID, ':', count($VarPagesFiles))}" groupID="{$GlobalProject/wwproject:Project/@GroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}" category="merge" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
        <wwfiles:Depends path="{$GlobalLocalePath}" checksum="{wwfilesystem:GetChecksum($GlobalLocalePath)}" groupID="" documentID="" />
        <wwfiles:Depends path="{$GlobalMapEntrySetsPath}" checksum="{wwfilesystem:GetChecksum($GlobalMapEntrySetsPath)}" groupID="" documentID="" />
        <wwfiles:Depends path="{$GlobalProjectVariablesPath}" checksum="{wwfilesystem:GetChecksum($GlobalProjectVariablesPath)}" groupID="" documentID="" />
        <wwfiles:Depends path="{$VarTOCFile/@path}" checksum="{wwfilesystem:GetChecksum($VarTOCFile/@path)}" groupID="{$VarTOCFile/@groupID}" documentID="{$VarTOCFile/@documentID}" />
        <wwfiles:Depends path="{$VarIndexFile/@path}" checksum="{wwfilesystem:GetChecksum($VarIndexFile/@path)}" groupID="{$VarIndexFile/@groupID}" documentID="{$VarIndexFile/@documentID}" />
        <wwfiles:Depends path="{$VarPageTemplateFile/@path}" checksum="{wwfilesystem:GetChecksum($VarPageTemplateFile/@path)}" groupID="{$VarPageTemplateFile/@groupID}" documentID="{$VarPageTemplateFile/@documentID}" />

        <!-- Pages dependencies -->
        <!--                    -->
        <xsl:for-each select="$VarPagesFiles">
         <wwfiles:Depends path="{@path}" checksum="{wwfilesystem:GetChecksum(@path)}" groupID="{@groupID}" documentID="{@documentID}" />
        </xsl:for-each>
       </wwfiles:File>
      </xsl:if>
     </xsl:for-each>
    </xsl:for-each>
   </xsl:if>

  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>
