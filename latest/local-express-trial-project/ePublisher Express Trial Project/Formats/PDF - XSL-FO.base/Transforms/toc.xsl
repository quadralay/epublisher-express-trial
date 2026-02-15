<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Format"
                              xmlns:fo="http://www.w3.org/1999/XSL/Format"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
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
                              exclude-result-prefixes="xsl msxsl wwtoc wwlinks wwmode wwfiles wwdoc wwbehaviors wwsplits wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterLinksType" />
 <xsl:param name="ParameterLocaleType" />
 <xsl:param name="ParameterType" />


 <xsl:output encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="fo" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwlinks-files-by-path" match="wwlinks:File" use="@path" />
 <xsl:key name="wwproject-rules-by-key" match="wwproject:Rule" use="@Key" />

 <xsl:include href="wwtransform:common/project/properties.xsl" />
 <xsl:include href="wwtransform:fo/fo_properties.xsl" />
 
 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
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

   <!-- Iterate input documents -->
   <!--                         -->
   <xsl:for-each select="$GlobalFiles[1]">
    <xsl:variable name="VarLinksPath" select="key('wwfiles-files-by-type', $ParameterLinksType)/@path" />
    <xsl:variable name="VarLinks" select="wwexsldoc:LoadXMLWithoutResolver($VarLinksPath)" />

    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:variable name="VarFilesDocumentsStartProgress" select="wwprogress:Start(count($VarFilesByType))" />

    <xsl:for-each select="$VarFilesByType">
     <xsl:variable name="VarFilesDocumentStartProgress" select="wwprogress:Start(1)" />

     <xsl:variable name="VarFilesDocument" select="." />

     <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFilesDocument/@path), concat(translate($ParameterType, ':', '_'),'.xml'))" />

     <!-- Transform -->
     <!--           -->
     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, '', $VarFilesDocument/@groupID, $VarFilesDocument/@documentID, $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:variable name="VarResultAsXML">
       <!-- Load document -->
       <!--               -->
       <xsl:variable name="VarTOC" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesDocument/@path)" />

       <xsl:call-template name="TableOfContents">
        <xsl:with-param name="ParamTOC" select="$VarTOC" />
        <xsl:with-param name="ParamLinks" select="$VarLinks" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
      <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, wwprojext:GetFormatSetting('encoding', 'utf-8'), 'xml', '1.0', 'yes')" />
     </xsl:if>

     <!-- Report Files -->
     <!--              -->
     <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" actionchecksum="{$GlobalActionChecksum}">
      <wwfiles:Depends path="{$VarFilesDocument/@path}" checksum="{$VarFilesDocument/@checksum}" groupID="{$VarFilesDocument/@groupID}" documentID="{$VarFilesDocument/@documentID}" />
     </wwfiles:File>

     <xsl:variable name="VarFilesDocumentEndProgress" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarFilesDocumentsEndProgress" select="wwprogress:End()" />
   </xsl:for-each>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="TableOfContents">
  <xsl:param name="ParamTOC" />
  <xsl:param name="ParamLinks" />

  <fo:root>
   <!-- Table of contents? -->
   <!--                    -->
   <xsl:if test="wwprojext:GetFormatSetting('toc-generate', 'true') = 'true'">
    <fo:block>
     <xsl:variable name="VarStylePrefix" select="wwprojext:GetFormatSetting('toc-style-prefix')" />

     <xsl:call-template name="Entries">
      <xsl:with-param name="ParamParent" select="$ParamTOC/wwtoc:TableOfContents" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamLevel" select="1" />
      <xsl:with-param name="ParamStylePrefix" select="$VarStylePrefix" />
     </xsl:call-template>

     <!-- Emit index title? -->
     <!--                   -->
     <xsl:if test="wwprojext:GetFormatSetting('index-generate') = 'true'">
      <xsl:variable name="VarLocalizedIndexTitle" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'IXTitle']/@value" />

      <fo:block text-align-last="justify">
       <!-- Styling -->
       <!--         -->
       <xsl:call-template name="TOC-EmitStyleAttributes">
        <xsl:with-param name="ParamEntry" select="/" />
        <xsl:with-param name="ParamTOCRuleName" select="concat($VarStylePrefix, '1')" />
        <xsl:with-param name="ParamLevel" select="1" />
       </xsl:call-template>

       <fo:basic-link internal-destination="index-title">
        <xsl:value-of select="$VarLocalizedIndexTitle" />
        <fo:leader leader-pattern="dots" />
        <fo:page-number-citation ref-id="index-title"/>
       </fo:basic-link>
      </fo:block>
     </xsl:if>
    </fo:block>
   </xsl:if>

   <!-- Bookmark tree? -->
   <!--                -->
   <xsl:if test="wwprojext:GetFormatSetting('generate-bookmarks') = 'true'">
    <xsl:variable name="VarLocalizedTOCTitle" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'TOCTitle']/@value" />

    <fo:bookmark-tree>
     <xsl:if test="wwprojext:GetFormatSetting('toc-generate', 'true') = 'true'">
      <fo:bookmark internal-destination="toc-title">
       <fo:bookmark-title>
        <xsl:value-of select="$VarLocalizedTOCTitle" />
       </fo:bookmark-title>
      </fo:bookmark>
     </xsl:if>

     <xsl:call-template name="Bookmarks">
      <xsl:with-param name="ParamParent" select="$ParamTOC/wwtoc:TableOfContents" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamLevel" select="1" />
     </xsl:call-template>

     <xsl:if test="wwprojext:GetFormatSetting('index-generate') = 'true'">
      <xsl:variable name="VarLocalizedIndexTitle" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'IXTitle']/@value" />

      <fo:bookmark internal-destination="index-title">
       <fo:bookmark-title><xsl:value-of select="$VarLocalizedIndexTitle" /></fo:bookmark-title>
      </fo:bookmark>
     </xsl:if>
    </fo:bookmark-tree>
   </xsl:if>
  </fo:root>
 </xsl:template>


 <xsl:template name="Entries">
  <xsl:param name="ParamParent" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamLevel" />
  <xsl:param name="ParamStylePrefix" />

  <xsl:variable name="VarTOCRuleName" select="concat($ParamStylePrefix, $ParamLevel)" />

  <xsl:variable name="VarSubEntries" select="$ParamParent/wwtoc:Entry" />

  <xsl:for-each select="$VarSubEntries[1]">

   <xsl:for-each select="$VarSubEntries">
    <xsl:variable name="VarEntry" select="." />
    <fo:block>

     <!-- Styling -->
     <!--         -->
     <xsl:call-template name="TOC-EmitStyleAttributes">
      <xsl:with-param name="ParamEntry" select="$VarEntry" />
      <xsl:with-param name="ParamTOCRuleName" select="$VarTOCRuleName" />
      <xsl:with-param name="ParamLevel" select="$ParamLevel" />
     </xsl:call-template>

     <!-- Get link -->
     <!--          -->
     <xsl:variable name="VarLinkTarget">
      <xsl:for-each select="$ParamLinks[1]">
       <xsl:variable name="VarLinkGroupID" select="key('wwlinks-files-by-path', $VarEntry/@path)[1]/@groupID" />

       <xsl:text>w</xsl:text>
       <xsl:value-of select="$VarLinkGroupID" />
       <xsl:text>_</xsl:text>
       <xsl:value-of select="$VarEntry/@documentID" />
       <xsl:text>_</xsl:text>
       <xsl:value-of select="$VarEntry/@linkid" />
      </xsl:for-each>
     </xsl:variable>

     <xsl:if test="string-length($VarLinkTarget) &gt; 1">
      <xsl:attribute name="text-align-last">
       <xsl:text>justify</xsl:text>
      </xsl:attribute>
     </xsl:if>
     
     <xsl:choose>
      <xsl:when test="string-length($VarLinkTarget) &gt; 1">
       <fo:basic-link>
         <xsl:attribute name="internal-destination">
          <xsl:value-of select="$VarLinkTarget" />
         </xsl:attribute>

        <xsl:call-template name="Paragraph">
         <xsl:with-param name="ParamParagraph" select="$VarEntry/wwdoc:Paragraph" />
        </xsl:call-template>

         <fo:leader leader-pattern="dots" />
         <fo:page-number-citation ref-id="{$VarLinkTarget}"/>
       </fo:basic-link>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="Paragraph">
         <xsl:with-param name="ParamParagraph" select="$VarEntry/wwdoc:Paragraph" />
        </xsl:call-template>
      </xsl:otherwise>
     </xsl:choose>
    </fo:block>

    <xsl:call-template name="Entries">
     <xsl:with-param name="ParamParent" select="$VarEntry" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamLevel" select="$ParamLevel + 1" />
     <xsl:with-param name="ParamStylePrefix" select="$ParamStylePrefix" />
    </xsl:call-template>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Bookmarks">
  <xsl:param name="ParamParent" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamLevel" />

  <xsl:variable name="VarSubEntries" select="$ParamParent/wwtoc:Entry" />

  <xsl:for-each select="$VarSubEntries[1]">

   <xsl:for-each select="$VarSubEntries">
    <xsl:variable name="VarEntry" select="." />

    <fo:bookmark>
     <!-- Get link -->
     <!--          -->
     <xsl:variable name="VarLinkTarget">
      <xsl:for-each select="$ParamLinks[1]">
       <xsl:variable name="VarLinkGroupID" select="key('wwlinks-files-by-path', $VarEntry/@path)[1]/@groupID" />

       <xsl:text>w</xsl:text>
       <xsl:value-of select="$VarLinkGroupID" />
       <xsl:text>_</xsl:text>
       <xsl:value-of select="$VarEntry/@documentID" />
       <xsl:text>_</xsl:text>
       <xsl:value-of select="$VarEntry/@linkid" />
      </xsl:for-each>
     </xsl:variable>

     <xsl:if test="string-length($VarLinkTarget) &gt; 1">
      <xsl:attribute name="internal-destination">
       <xsl:value-of select="$VarLinkTarget" />
      </xsl:attribute>
     </xsl:if>

     <fo:bookmark-title>
      <xsl:call-template name="Paragraph">
       <xsl:with-param name="ParamParagraph" select="$VarEntry/wwdoc:Paragraph" />
      </xsl:call-template>
     </fo:bookmark-title>

     <xsl:call-template name="Bookmarks">
      <xsl:with-param name="ParamParent" select="$VarEntry" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamLevel" select="$ParamLevel + 1" />
     </xsl:call-template>
    </fo:bookmark>

   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Paragraph">
  <xsl:param name="ParamParagraph" />

  <xsl:variable name="VarText">
   <xsl:for-each select="$ParamParagraph/wwdoc:Number/wwdoc:Text | $ParamParagraph//wwdoc:TextRun/wwdoc:Text">
    <xsl:value-of select="@value" />
   </xsl:for-each>
  </xsl:variable>
  <xsl:value-of select="normalize-space($VarText)" />
 </xsl:template>


 <xsl:template name="TOC-EmitStyleAttributes">
  <xsl:param name="ParamEntry" />
  <xsl:param name="ParamTOCRuleName" />
  <xsl:param name="ParamLevel" />

  <!-- TOC Rule Exists? -->
  <!--                  -->
  <xsl:variable name="VarTOCRuleExists">
   <xsl:for-each select="$GlobalProject[1]">
    <xsl:variable name="VarTOCRuleHint" select="key('wwproject-rules-by-key', $ParamTOCRuleName)[1]" />

    <xsl:choose>
     <xsl:when test="count($VarTOCRuleHint) = 1">
      <xsl:text>true</xsl:text>
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>false</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:for-each>
  </xsl:variable>

  <xsl:choose>
   <xsl:when test="$VarTOCRuleExists = 'true'">
    <xsl:variable name="VarTOCRule" select="wwprojext:GetRule('Paragraph', $ParamTOCRuleName)" />

    <xsl:variable name="VarResolvedRulePropertiesAsXML">
     <xsl:call-template name="Properties-ResolveRule">
      <xsl:with-param name="ParamDocumentContext" select="$ParamEntry/wwdoc:NoContext" />
      <xsl:with-param name="ParamProperties" select="$VarTOCRule/wwproject:Properties/wwproject:Property" />
      <xsl:with-param name="ParamStyleName" select="$ParamTOCRuleName" />
      <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarResolvedRuleProperties" select="msxsl:node-set($VarResolvedRulePropertiesAsXML)/wwproject:Property" />

    <!-- FO properties -->
    <!--               -->
    <xsl:variable name="VarFOPropertiesAsXML">
     <xsl:call-template name="FO-TranslateProjectProperties">
      <xsl:with-param name="ParamProperties" select="$VarResolvedRuleProperties" />
      <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarFOProperties" select="msxsl:node-set($VarFOPropertiesAsXML)/wwproject:Property" />

    <xsl:for-each select="$VarFOProperties">
     <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
    </xsl:for-each>
   </xsl:when>

   <xsl:otherwise>
    <xsl:variable name="VarMarginLeft" select="concat(string(number($ParamLevel) * 12), 'pt')" />

    <!-- Suitable defaults -->
    <!--                   -->
    <xsl:attribute name="margin-left"><xsl:value-of select="$VarMarginLeft" /></xsl:attribute>
    <xsl:attribute name="font-size">smaller</xsl:attribute>
    <xsl:attribute name="space-after">0.1in</xsl:attribute>
    <xsl:attribute name="space-before">0.15in</xsl:attribute>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>
