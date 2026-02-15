<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Format"
                              xmlns:fo="http://www.w3.org/1999/XSL/Format"
                              xmlns:flo="urn:WebWorks-XSLT-Flow-Schema"
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
                              xmlns:wwmultisere="urn:WebWorks-XSLT-Extension-MultiSearchReplace"
                              xmlns:wwdatetime="urn:WebWorks-XSLT-Extension-DateTimeUtilities"
                              exclude-result-prefixes="flo xsl msxsl wwindex wwlinks wwmode wwfiles wwdoc wwsplits wwvars wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc wwmultisere"
>

 <xsl:template name="Stitch">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamTOC" />
  <xsl:param name="ParamIndex" />
  <xsl:param name="ParamPagesFiles" />
  <xsl:param name="ParamFlows" />
  <xsl:param name="ParamGroupID" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamPath" />
  <xsl:param name="ParamTitle" />
  <xsl:param name="ParamPageTemplate" />

  <!-- Publish Date (Formatted) -->
  <!--                          -->
  <xsl:variable name= "VarPublishDateFormat" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PublishDateFormat']/@value"/>
  <xsl:variable name= "VarPublishDate" select="wwdatetime:GetGenerateStart($VarPublishDateFormat)"/>
  <xsl:variable name= "VarPublishDateLabel" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'PublishDateLabel']/@value"/>
  <xsl:variable name= "VarFormattedPublishDate" select="wwstring:Format($VarPublishDateLabel, $VarPublishDate)"/>

  <!-- Project Variables -->
  <!--                   -->
  <xsl:variable name="VarProjectVariablesAsXML" select="$GlobalProject/wwproject:Project/wwproject:FormatConfigurations/wwproject:FormatConfiguration[@TargetID=wwprojext:GetFormatID()]/wwproject:Variables/wwproject:Variable"/>

  <!-- Scope Variables -->
  <!--                 -->
  <xsl:variable name="VarScopeVariablesAsXML">
   <xsl:call-template name="Variables-Globals-For-Scope">
    <xsl:with-param name="ParamProjectVariables" select="$GlobalProjectVariables" />
    <xsl:with-param name="ParamGroupID" select="$ParamGroupID" />
    <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarScopeVariables" select="msxsl:node-set($VarScopeVariablesAsXML)/wwvars:Variable" />

  <!-- Stitch Macros -->
  <!--               -->
  <xsl:variable name="VarStitchMacrosAsXML">
   <!-- Duplicate macro names at end take precedence -->
   <!--                                              -->

   <wwmultisere:Entry match="$PublishDate;" replacement="{$VarPublishDate}" />

   <xsl:for-each select="$VarProjectVariablesAsXML">
    <wwmultisere:Entry match="${./@Name};" replacement="{./@Value}" />
   </xsl:for-each>

   <xsl:for-each select="$VarScopeVariables">
    <xsl:variable name="VarVariable" select="." />
    <xsl:variable name="VarReplacement">
     <xsl:apply-templates select="$VarVariable" mode="wwmode:variable-string-value" />
    </xsl:variable>
    <wwmultisere:Entry match="${$VarVariable/@name};" replacement="{$VarReplacement}" />
   </xsl:for-each>

  </xsl:variable>
  <xsl:variable name="VarStitchMacros" select="msxsl:node-set($VarStitchMacrosAsXML)/wwmultisere:Entry" />

  <!-- Title Page Rule -->
  <!--                 -->
  <xsl:variable name="VarTitlePageStyle" select="wwprojext:GetFormatSetting('title-page-style')" />
  <xsl:variable name="VarTitlePageRule" select="wwprojext:GetRule('Page', $VarTitlePageStyle)" />

  <!-- TOC Rule -->
  <!--           -->
  <xsl:variable name="VarTOCPageStyle" select="wwprojext:GetFormatSetting('toc-page-style')" />
  <xsl:variable name="VarTOCPageRule" select="wwprojext:GetRule('Page', $VarTOCPageStyle)" />

  <!-- Index Rule -->
  <!--            -->
  <xsl:variable name="VarIndexPageStyle" select="wwprojext:GetFormatSetting('index-page-style')" />
  <xsl:variable name="VarIndexPageRule" select="wwprojext:GetRule('Page', $VarIndexPageStyle)" />

  <!-- Title page title -->
  <!--                  -->
  <xsl:variable name="VarTitlePageTitle">
   <xsl:variable name="VarTitlePageTitleHint" select="wwprojext:GetFormatSetting('title-page-title')" />

   <xsl:if test="(string-length($VarTitlePageTitleHint) &gt; 0) and ($VarTitlePageTitleHint != 'none')">
    <xsl:call-template name="Stitch-Text">
     <xsl:with-param name="ParamText" select="$VarTitlePageTitleHint"/>
     <xsl:with-param name="ParamTitle" select="$ParamTitle"/>
     <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros"/>
    </xsl:call-template>
   </xsl:if>
  </xsl:variable>

  <!-- Title page sub-title -->
  <!--                      -->
  <xsl:variable name="VarTitlePageSubTitle">
   <xsl:variable name="VarTitlePageSubTitleHint" select="wwprojext:GetFormatSetting('title-page-subtitle')" />

   <xsl:if test="(string-length($VarTitlePageSubTitleHint) &gt; 0) and ($VarTitlePageSubTitleHint != 'none')">
    <xsl:call-template name="Stitch-Text">
     <xsl:with-param name="ParamText" select="$VarTitlePageSubTitleHint"/>
     <xsl:with-param name="ParamTitle" select="$ParamTitle"/>
     <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros"/>
    </xsl:call-template>
   </xsl:if>
  </xsl:variable>

  <!-- Title and TOC and Index -->
  <!--                         -->
  <xsl:variable name="VarGenerateTitlePage" select="((wwprojext:GetFormatSetting('generate-title-page') = 'true') and ((string-length($VarTitlePageTitle) &gt; 0) or (string-length($VarTitlePageSubTitle) &gt; 0)))" />
  <xsl:variable name="VarGenerateTOC" select="wwprojext:GetFormatSetting('toc-generate') = 'true'" />
  <xsl:variable name="VarGenerateIndex" select="wwprojext:GetFormatSetting('index-generate') = 'true'" />
  <xsl:variable name="VarGenerateBookmarks" select="wwprojext:GetFormatSetting('generate-bookmarks') = 'true'" />


  <xsl:variable name="VarConditionsAsXML">
   <!-- Project Variables -->
   <!--                   -->
   <xsl:for-each select="$VarProjectVariablesAsXML">
    <wwpage:Condition name="projvars:{./@Name}"/>
   </xsl:for-each>

   <!-- Scope Variables -->
   <!--                 -->
   <xsl:call-template name="Variables-Page-Conditions">
    <xsl:with-param name="ParamVariables" select="$VarScopeVariables" />
   </xsl:call-template>

   <!-- Generate title page -->
   <!--                     -->
   <xsl:if test="$VarGenerateTitlePage">
    <wwpage:Condition name="generate-title-page" />
    <wwpage:Condition name="title-exists" />
   </xsl:if>

   <!-- Generate TOC -->
   <!--              -->
   <xsl:if test="$VarGenerateTOC">
    <wwpage:Condition name="toc-exists" />
   </xsl:if>

   <!-- Generate Index -->
   <!--                -->
   <xsl:if test="$VarGenerateIndex">
    <wwpage:Condition name="index-exists" />
   </xsl:if>

   <!-- Title First Page -->
   <!--                  -->
   <xsl:variable name="VarTitleFirstMasterPageOption" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'first-master-page']/@Value" />
   <xsl:if test="$VarTitleFirstMasterPageOption = 'true'">
    <wwpage:Condition name="title-first-master-page" />
   </xsl:if>

   <!-- Title Last Page -->
   <!--                 -->
   <xsl:variable name="VarTitleLastMasterPageOption" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'last-master-page']/@Value" />
   <xsl:if test="$VarTitleLastMasterPageOption = 'true'">
    <wwpage:Condition name="title-last-master-page" />
   </xsl:if>

   <!-- Title First Header -->
   <!--                    -->
   <xsl:variable name="VarTitleFirstHeaderString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'first-header-string']/@Value" />
   <xsl:if test="string-length($VarTitleFirstHeaderString) &gt; 0 and $VarTitleFirstHeaderString != 'none'">
    <wwpage:Condition  name="title-first-header-exists" />
   </xsl:if>

   <!-- Title Last Header -->
   <!--                   -->
   <xsl:variable name="VarTitleLastHeaderString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'last-header-string']/@Value" />
   <xsl:if test="string-length($VarTitleLastHeaderString) &gt; 0 and $VarTitleLastHeaderString != 'none'">
    <wwpage:Condition  name="title-last-header-exists" />
   </xsl:if>

   <!-- Title Even Header -->
   <!--                   -->
   <xsl:variable name="VarTitleEvenHeaderString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'even-header-string']/@Value" />
   <xsl:if test="string-length($VarTitleEvenHeaderString) &gt; 0 and $VarTitleEvenHeaderString != 'none'">
    <wwpage:Condition  name="title-even-header-exists" />
   </xsl:if>

   <!-- Title Odd Header -->
   <!--                  -->
   <xsl:variable name="VarTitleOddHeaderString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'odd-header-string']/@Value" />
   <xsl:if test="string-length($VarTitleOddHeaderString) &gt; 0 and $VarTitleOddHeaderString != 'none'">
    <wwpage:Condition  name="title-odd-header-exists" />
   </xsl:if>

   <!-- Title First Footer -->
   <!--                    -->
   <xsl:variable name="VarTitleFirstFooterString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'first-footer-string']/@Value" />
   <xsl:if test="string-length($VarTitleFirstFooterString) &gt; 0 and $VarTitleFirstFooterString != 'none'">
    <wwpage:Condition  name="title-first-footer-exists" />
   </xsl:if>

   <!-- Title Last Footer -->
   <!--                   -->
   <xsl:variable name="VarTitleLastFooterString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'last-footer-string']/@Value" />
   <xsl:if test="string-length($VarTitleLastFooterString) &gt; 0 and $VarTitleLastFooterString != 'none'">
    <wwpage:Condition  name="title-last-footer-exists" />
   </xsl:if>

   <!-- Title Even Footer -->
   <!--                   -->
   <xsl:variable name="VarTitleEvenFooterString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'even-footer-string']/@Value" />
   <xsl:if test="string-length($VarTitleEvenFooterString) &gt; 0 and $VarTitleEvenFooterString != 'none'">
    <wwpage:Condition  name="title-even-footer-exists" />
   </xsl:if>

   <!-- Title Odd Footer -->
   <!--                  -->
   <xsl:variable name="VarTitleOddFooterString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'odd-footer-string']/@Value" />
   <xsl:if test="string-length($VarTitleOddFooterString) &gt; 0 and $VarTitleOddFooterString != 'none'">
    <wwpage:Condition  name="title-odd-footer-exists" />
   </xsl:if>

   <!-- TOC First Page -->
   <!--                -->
   <xsl:variable name="VarTOCFirstMasterPageOption" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'first-master-page']/@Value" />
   <xsl:if test="$VarTOCFirstMasterPageOption = 'true'">
    <wwpage:Condition name="toc-first-master-page" />
   </xsl:if>

   <!-- TOC Last Page -->
   <!--               -->
   <xsl:variable name="VarTOCLastMasterPageOption" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'last-master-page']/@Value" />
   <xsl:if test="$VarTOCLastMasterPageOption = 'true'">
    <wwpage:Condition name="toc-last-master-page" />
   </xsl:if>

   <!-- TOC First Header -->
   <!--                  -->
   <xsl:variable name="VarTOCFirstHeaderString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'first-header-string']/@Value" />
   <xsl:if test="string-length($VarTOCFirstHeaderString) &gt; 0 and $VarTOCFirstHeaderString != 'none'">
    <wwpage:Condition  name="toc-first-header-exists" />
   </xsl:if>

   <!-- TOC Last Header -->
   <!--                 -->
   <xsl:variable name="VarTOCLastHeaderString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'last-header-string']/@Value" />
   <xsl:if test="string-length($VarTOCLastHeaderString) &gt; 0 and $VarTOCLastHeaderString != 'none'">
    <wwpage:Condition  name="toc-last-header-exists" />
   </xsl:if>

   <!-- TOC Even Header -->
   <!--                 -->
   <xsl:variable name="VarTOCEvenHeaderString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'even-header-string']/@Value" />
   <xsl:if test="string-length($VarTOCEvenHeaderString) &gt; 0 and $VarTOCEvenHeaderString != 'none'">
    <wwpage:Condition  name="toc-even-header-exists" />
   </xsl:if>

   <!-- TOC Odd Header -->
   <!--                -->
   <xsl:variable name="VarTOCOddHeaderString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-header-string']/@Value" />
   <xsl:if test="string-length($VarTOCOddHeaderString) &gt; 0 and $VarTOCOddHeaderString != 'none'">
    <wwpage:Condition  name="toc-odd-header-exists" />
   </xsl:if>

   <!-- TOC First Footer -->
   <!--                  -->
   <xsl:variable name="VarTOCFirstFooterString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'first-footer-string']/@Value" />
   <xsl:if test="string-length($VarTOCFirstFooterString) &gt; 0 and $VarTOCFirstFooterString != 'none'">
    <wwpage:Condition  name="toc-first-footer-exists" />
   </xsl:if>

   <!-- TOC Last Footer -->
   <!--                 -->
   <xsl:variable name="VarTOCLastFooterString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'last-footer-string']/@Value" />
   <xsl:if test="string-length($VarTOCLastFooterString) &gt; 0 and $VarTOCLastFooterString != 'none'">
    <wwpage:Condition  name="toc-last-footer-exists" />
   </xsl:if>

   <!-- TOC Even Footer -->
   <!--                 -->
   <xsl:variable name="VarTOCEvenFooterString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'even-footer-string']/@Value" />
   <xsl:if test="string-length($VarTOCEvenFooterString) &gt; 0 and $VarTOCEvenFooterString != 'none'">
    <wwpage:Condition  name="toc-even-footer-exists" />
   </xsl:if>

   <!-- TOC Odd Footer -->
   <!--                -->
   <xsl:variable name="VarTOCOddFooterString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-footer-string']/@Value" />
   <xsl:if test="string-length($VarTOCOddFooterString) &gt; 0 and $VarTOCOddFooterString != 'none'">
    <wwpage:Condition  name="toc-odd-footer-exists" />
   </xsl:if>

   <!-- Bookmarks -->
   <!--           -->
   <xsl:if test="$VarGenerateBookmarks">
    <wwpage:Condition name="bookmarks-exist" />
   </xsl:if>

   <!-- Index First Page -->
   <!--                  -->
   <xsl:variable name="VarIndexFirstMasterPageOption" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'first-master-page']/@Value" />
   <xsl:if test="$VarIndexFirstMasterPageOption = 'true'">
    <wwpage:Condition name="index-first-master-page" />
   </xsl:if>

   <!-- Index Last Page -->
   <!--                 -->
   <xsl:variable name="VarIndexLastMasterPageOption" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'last-master-page']/@Value" />
   <xsl:if test="$VarIndexLastMasterPageOption = 'true'">
    <wwpage:Condition name="index-last-master-page" />
   </xsl:if>

   <!-- Index First Header -->
   <!--                    -->
   <xsl:variable name="VarIndexFirstHeaderString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'first-header-string']/@Value" />
   <xsl:if test="string-length($VarIndexFirstHeaderString) &gt; 0 and $VarIndexFirstHeaderString != 'none'">
    <wwpage:Condition  name="index-first-header-exists" />
   </xsl:if>

   <!-- Index Last Header -->
   <!--                   -->
   <xsl:variable name="VarIndexLastHeaderString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'last-header-string']/@Value" />
   <xsl:if test="string-length($VarIndexLastHeaderString) &gt; 0 and $VarIndexLastHeaderString != 'none'">
    <wwpage:Condition  name="index-last-header-exists" />
   </xsl:if>

   <!-- Index Even Header -->
   <!--                   -->
   <xsl:variable name="VarIndexEvenHeaderString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'even-header-string']/@Value" />
   <xsl:if test="string-length($VarIndexEvenHeaderString) &gt; 0 and $VarIndexEvenHeaderString != 'none'">
    <wwpage:Condition  name="index-even-header-exists" />
   </xsl:if>

   <!-- Index Odd Header -->
   <!--                  -->
   <xsl:variable name="VarIndexOddHeaderString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-header-string']/@Value" />
   <xsl:if test="string-length($VarIndexOddHeaderString) &gt; 0 and $VarIndexOddHeaderString != 'none'">
    <wwpage:Condition  name="index-odd-header-exists" />
   </xsl:if>

   <!-- Index First Footer -->
   <!--                    -->
   <xsl:variable name="VarIndexFirstFooterString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'first-footer-string']/@Value" />
   <xsl:if test="string-length($VarIndexFirstFooterString) &gt; 0 and $VarIndexFirstFooterString != 'none'">
    <wwpage:Condition  name="index-first-footer-exists" />
   </xsl:if>

   <!-- Index Last Footer -->
   <!--                   -->
   <xsl:variable name="VarIndexLastFooterString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'last-footer-string']/@Value" />
   <xsl:if test="string-length($VarIndexLastFooterString) &gt; 0 and $VarIndexLastFooterString != 'none'">
    <wwpage:Condition  name="index-last-footer-exists" />
   </xsl:if>

   <!-- Index Even Footer -->
   <!--                   -->
   <xsl:variable name="VarIndexEvenFooterString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'even-footer-string']/@Value" />
   <xsl:if test="string-length($VarIndexEvenFooterString) &gt; 0 and $VarIndexEvenFooterString != 'none'">
    <wwpage:Condition  name="index-even-footer-exists" />
   </xsl:if>

   <!-- Index Odd Footer -->
   <!--                  -->
   <xsl:variable name="VarIndexOddFooterString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-footer-string']/@Value" />
   <xsl:if test="string-length($VarIndexOddFooterString) &gt; 0 and $VarIndexOddFooterString != 'none'">
    <wwpage:Condition  name="index-odd-footer-exists" />
   </xsl:if>

   <!-- Title Page Title -->
   <!--                  -->
   <xsl:if test="string-length($VarTitlePageTitle) &gt; 0">
    <wwpage:Condition name="display-title-page-title" />
   </xsl:if>

   <!-- Title Page Subtitle -->
   <!--                     -->
   <xsl:if test="string-length($VarTitlePageSubTitle) &gt; 0">
    <wwpage:Condition name="display-title-page-subtitle" />
   </xsl:if>

   <!-- Title Page Publish Date -->
   <!--                         -->
   <xsl:if test="wwprojext:GetFormatSetting('title-page-publish-date') = 'true'">
    <wwpage:Condition name="display-title-page-publish-date" />
   </xsl:if>

   <!-- Emit master pages for all flows -->
   <!--                                 -->
   <xsl:for-each select="$ParamFlows/flo:Flows/flo:Flow">
    <xsl:variable name="VarFlow" select="." />

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <!-- Page Rule -->
     <!--           -->
     <xsl:variable name="VarPageRule" select="wwprojext:GetRule('Page', $VarFlow/@stylename)" />

     <!-- Content First Page -->
     <!--                    -->
     <xsl:variable name="VarContentFirstMasterPageOption" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'first-master-page']/@Value" />
     <xsl:if test="$VarContentFirstMasterPageOption = 'true'">
      <wwpage:Condition name="{$VarFlow/@name}-first-master-page" />
     </xsl:if>

     <!-- Content Last Page -->
     <!--                   -->
     <xsl:variable name="VarContentLastMasterPageOption" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'last-master-page']/@Value" />
     <xsl:if test="$VarContentLastMasterPageOption = 'true'">
      <wwpage:Condition name="{$VarFlow/@name}-last-master-page" />
     </xsl:if>

     <!-- Content First Header -->
     <!--                      -->
     <xsl:variable name="VarContentFirstHeaderString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'first-header-string']/@Value" />
     <xsl:if test="string-length($VarContentFirstHeaderString) &gt; 0 and $VarContentFirstHeaderString != 'none'">
      <wwpage:Condition  name="{$VarFlow/@name}-first-header-exists" />
     </xsl:if>

     <!-- Content Last Header -->
     <!--                     -->
     <xsl:variable name="VarContentLastHeaderString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'last-header-string']/@Value" />
     <xsl:if test="string-length($VarContentLastHeaderString) &gt; 0 and $VarContentLastHeaderString != 'none'">
      <wwpage:Condition  name="{$VarFlow/@name}-last-header-exists" />
     </xsl:if>

     <!-- Content Even Header -->
     <!--                     -->
     <xsl:variable name="VarContentEvenHeaderString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'even-header-string']/@Value" />
     <xsl:if test="string-length($VarContentEvenHeaderString) &gt; 0 and $VarContentEvenHeaderString != 'none'">
      <wwpage:Condition  name="{$VarFlow/@name}-even-header-exists" />
     </xsl:if>

     <!-- Content Odd Header -->
     <!--                    -->
     <xsl:variable name="VarContentOddHeaderString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-header-string']/@Value" />
     <xsl:if test="string-length($VarContentOddHeaderString) &gt; 0 and $VarContentOddHeaderString != 'none'">
      <wwpage:Condition  name="{$VarFlow/@name}-odd-header-exists" />
     </xsl:if>

     <!-- Content First Footer -->
     <!--                      -->
     <xsl:variable name="VarContentFirstFooterString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'first-footer-string']/@Value" />
     <xsl:if test="string-length($VarContentFirstFooterString) &gt; 0 and $VarContentFirstFooterString != 'none'">
      <wwpage:Condition  name="{$VarFlow/@name}-first-footer-exists" />
     </xsl:if>

     <!-- Content Last Footer -->
     <!--                     -->
     <xsl:variable name="VarContentLastFooterString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'last-footer-string']/@Value" />
     <xsl:if test="string-length($VarContentLastFooterString) &gt; 0 and $VarContentLastFooterString != 'none'">
      <wwpage:Condition  name="{$VarFlow/@name}-last-footer-exists" />
     </xsl:if>

     <!-- Content Even Footer -->
     <!--                     -->
     <xsl:variable name="VarContentEvenFooterString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'even-footer-string']/@Value" />
     <xsl:if test="string-length($VarContentEvenFooterString) &gt; 0 and $VarContentEvenFooterString != 'none'">
      <wwpage:Condition  name="{$VarFlow/@name}-even-footer-exists" />
     </xsl:if>

     <!-- Content Odd Footer -->
     <!--                    -->
     <xsl:variable name="VarContentOddFooterString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-footer-string']/@Value" />
     <xsl:if test="string-length($VarContentOddFooterString) &gt; 0 and $VarContentOddFooterString != 'none'">
      <wwpage:Condition  name="{$VarFlow/@name}-odd-footer-exists" />
     </xsl:if>
    </xsl:if>
   </xsl:for-each>

  </xsl:variable>
  <xsl:variable name="VarConditions" select="msxsl:node-set($VarConditionsAsXML)" />

  <!-- Replacements -->
  <!--              -->
  <xsl:variable name="VarReplacementsAsXML">
   <!-- Project Variables -->
   <!--                   -->
   <xsl:for-each select="$VarProjectVariablesAsXML">
    <wwpage:Replacement name="projvars:{./@Name}" value="{./@Value}"/>
   </xsl:for-each>

   <!-- Title Page Title -->
   <!--                  -->
   <wwpage:Replacement name="title-page-title-string" value="{$VarTitlePageTitle}" />
   <wwpage:Replacement name="title-page-title">
    <xsl:if test="string-length($VarTitlePageTitle) &gt; 0">
     <xsl:variable name="VarStyleName" select="wwprojext:GetFormatSetting('title-page-title-style')" />

     <!-- Suitable defaults -->
     <!--                   -->
     <xsl:variable name="VarDefaultPropertiesAsXML">
      <wwproject:Property Name="font-size" Value="larger" />
      <wwproject:Property Name="font-weight" Value="bold" />
      <wwproject:Property Name="margin-top" Value="3in" />
      <wwproject:Property Name="text-align" Value="center" />
     </xsl:variable>
     <xsl:variable name="VarDefaultProperties" select="msxsl:node-set($VarDefaultPropertiesAsXML)" />

     <xsl:variable name="VarContentAsXML">
      <xsl:value-of select="$VarTitlePageTitle" />
     </xsl:variable>
     <xsl:variable name="VarContent" select="msxsl:node-set($VarContentAsXML)" />

     <xsl:call-template name="Stitch-Block">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
      <xsl:with-param name="ParamDefaultProperties" select="$VarDefaultProperties" />
      <xsl:with-param name="ParamBlockID" select="'title-page-title'" />
      <xsl:with-param name="ParamContent" select="$VarContent" />
     </xsl:call-template>
    </xsl:if>
   </wwpage:Replacement>

   <!-- Title Page Subtitle -->
   <!--                     -->
   <wwpage:Replacement name="title-page-subtitle-string" value="{$VarTitlePageSubTitle}" />
   <wwpage:Replacement name="title-page-subtitle">
    <xsl:if test="string-length($VarTitlePageSubTitle) &gt; 0">
     <xsl:variable name="VarStyleName" select="wwprojext:GetFormatSetting('title-page-subtitle-style')" />

     <!-- Suitable defaults -->
     <!--                   -->
     <xsl:variable name="VarDefaultPropertiesAsXML">
      <wwproject:Property Name="font-size" Value="medium" />
      <wwproject:Property Name="font-style" Value="italic" />
      <wwproject:Property Name="text-align" Value="center" />
     </xsl:variable>
     <xsl:variable name="VarDefaultProperties" select="msxsl:node-set($VarDefaultPropertiesAsXML)" />

     <xsl:variable name="VarContentAsXML">
      <xsl:value-of select="$VarTitlePageSubTitle" />
     </xsl:variable>
     <xsl:variable name="VarContent" select="msxsl:node-set($VarContentAsXML)" />

     <xsl:call-template name="Stitch-Block">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
      <xsl:with-param name="ParamDefaultProperties" select="$VarDefaultProperties" />
      <xsl:with-param name="ParamBlockID" select="'title-page-subtitle'" />
      <xsl:with-param name="ParamContent" select="$VarContent" />
     </xsl:call-template>
    </xsl:if>
   </wwpage:Replacement>

   <!-- Title Page Publish Date -->
   <!--                         -->
   <wwpage:Replacement name="publish-date-string" value="{$VarFormattedPublishDate}" />
   <wwpage:Replacement name="publish-date">
    <xsl:if test="wwprojext:GetFormatSetting('title-page-publish-date') = 'true'">
     <xsl:variable name="VarStyleName" select="wwprojext:GetFormatSetting('title-page-publish-date-style')" />

     <!-- Suitable defaults -->
     <!--                   -->
     <xsl:variable name="VarDefaultPropertiesAsXML">
      <wwproject:Property Name="font-size" Value="small" />
      <wwproject:Property Name="margin-top" Value="10px" />
      <wwproject:Property Name="text-align" Value="center" />
     </xsl:variable>
     <xsl:variable name="VarDefaultProperties" select="msxsl:node-set($VarDefaultPropertiesAsXML)" />

     <xsl:variable name="VarContentAsXML">
      <xsl:value-of select="$VarFormattedPublishDate" />
     </xsl:variable>
     <xsl:variable name="VarContent" select="msxsl:node-set($VarContentAsXML)" />

     <xsl:call-template name="Stitch-Block">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
      <xsl:with-param name="ParamDefaultProperties" select="$VarDefaultProperties" />
      <xsl:with-param name="ParamBlockID" select="'title-page-publish-date'" />
      <xsl:with-param name="ParamContent" select="$VarContent" />
     </xsl:call-template>
    </xsl:if>
   </wwpage:Replacement>

   <xsl:variable name="VarLocalizedTOCTitle" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'TOCTitle']/@value" />
   <xsl:variable name="VarLocalizedIndexTitle" select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'IXTitle']/@value" />

   <!-- TOC Title -->
   <!--           -->
   <wwpage:Replacement name="toc-title-string" value="{$VarLocalizedTOCTitle}" />
   <wwpage:Replacement name="toc-title">
    <fo:block id="toc-title">
     <xsl:variable name="VarStyleName" select="wwprojext:GetFormatSetting('toc-title-style')" />

     <xsl:choose>
      <xsl:when test="string-length($VarStyleName) &gt; 0">
       <!-- Process style rule -->
       <!--                    -->
       <xsl:call-template name="Stitch-BlockStyle">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
       </xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
       <!-- Suitable defaults -->
       <!--                   -->
       <xsl:attribute name="text-align">center</xsl:attribute>
       <xsl:attribute name="font-weight">bold</xsl:attribute>
       <xsl:attribute name="font-size">larger</xsl:attribute>
      </xsl:otherwise>
     </xsl:choose>

     <xsl:call-template name="Stitch-BlockText">
      <xsl:with-param name="ParamBlockText" select="$VarLocalizedTOCTitle" />
      <xsl:with-param name="ParamTitle" select="$VarLocalizedTOCTitle" />
      <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
     </xsl:call-template>
    </fo:block>
   </wwpage:Replacement>

   <!-- Index Title -->
   <!--             -->
   <wwpage:Replacement name="index-title-string" value="{$VarLocalizedIndexTitle}" />
   <wwpage:Replacement name="index-title">
    <fo:block id="index-title">
     <xsl:variable name="VarStyleName" select="wwprojext:GetFormatSetting('index-title-style')" />

     <xsl:choose>
      <xsl:when test="string-length($VarStyleName) &gt; 0">
       <!-- Process style rule -->
       <!--                    -->
       <xsl:call-template name="Stitch-BlockStyle">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
       </xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
       <!-- Suitable defaults -->
       <!--                   -->
       <xsl:attribute name="text-align">center</xsl:attribute>
       <xsl:attribute name="font-weight">bold</xsl:attribute>
       <xsl:attribute name="font-size">larger</xsl:attribute>
      </xsl:otherwise>
     </xsl:choose>

     <xsl:call-template name="Stitch-BlockText">
      <xsl:with-param name="ParamBlockText" select="$VarLocalizedIndexTitle" />
      <xsl:with-param name="ParamTitle" select="$VarLocalizedTOCTitle" />
      <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
     </xsl:call-template>
    </fo:block>
   </wwpage:Replacement>

   <!-- Master pages -->
   <!--              -->

   <!-- Title Master Pages -->
   <!--                    -->
   <xsl:if test="$VarGenerateTitlePage">
    <!-- Title Pagination -->
    <!--                  -->
    <wwpage:Replacement name="title-force-page-count">
     <xsl:value-of select="$VarTitlePageRule/wwproject:Properties/wwproject:Property[@Name = 'force-page-count']/@Value" />
    </wwpage:Replacement>
    <wwpage:Replacement name="title-initial-page-number">
     <xsl:value-of select="$VarTitlePageRule/wwproject:Properties/wwproject:Property[@Name = 'initial-page-number']/@Value" />
    </wwpage:Replacement>
    <wwpage:Replacement name="title-page-sequence-format">
     <xsl:value-of select="$VarTitlePageRule/wwproject:Properties/wwproject:Property[@Name = 'page-sequence-format']/@Value" />
    </wwpage:Replacement>
    <wwpage:Replacement name="title-page-sequence-letter-value">
     <xsl:value-of select="$VarTitlePageRule/wwproject:Properties/wwproject:Property[@Name = 'page-sequence-letter-value']/@Value" />
    </wwpage:Replacement>

    <!-- Title First Master Page -->
    <!--                         -->
    <wwpage:Replacement name="title-first-master-page">
     <xsl:call-template name="Stitch-MasterPage">
      <xsl:with-param name="ParamPageRule" select="$VarTitlePageRule" />
      <xsl:with-param name="ParamPageName" select="'first'" />
      <xsl:with-param name="ParamMode" select="'title'" />
     </xsl:call-template>
    </wwpage:Replacement>

    <!-- Title Last Master Page -->
    <!--                        -->
    <wwpage:Replacement name="title-last-master-page">
     <xsl:call-template name="Stitch-MasterPage">
      <xsl:with-param name="ParamPageRule" select="$VarTitlePageRule" />
      <xsl:with-param name="ParamPageName" select="'last'" />
      <xsl:with-param name="ParamMode" select="'title'" />
     </xsl:call-template>
    </wwpage:Replacement>

    <!-- Title Even Master Page -->
    <!--                        -->
    <wwpage:Replacement name="title-even-master-page">
     <xsl:call-template name="Stitch-MasterPage">
      <xsl:with-param name="ParamPageRule" select="$VarTitlePageRule" />
      <xsl:with-param name="ParamPageName" select="'even'" />
      <xsl:with-param name="ParamMode" select="'title'" />
     </xsl:call-template>
    </wwpage:Replacement>

    <!-- Title Odd Master Page -->
    <!--                       -->
    <wwpage:Replacement name="title-odd-master-page">
     <xsl:call-template name="Stitch-MasterPage">
      <xsl:with-param name="ParamPageRule" select="$VarTitlePageRule" />
      <xsl:with-param name="ParamPageName" select="'odd'" />
      <xsl:with-param name="ParamMode" select="'title'" />
     </xsl:call-template>
    </wwpage:Replacement>
   </xsl:if>

   <!-- TOC Master Pages -->
   <!--                  -->
   <xsl:if test="$VarGenerateTOC">
    <!-- TOC Pagination -->
    <!--                -->
    <wwpage:Replacement name="toc-force-page-count">
     <xsl:value-of select="$VarTOCPageRule/wwproject:Properties/wwproject:Property[@Name = 'force-page-count']/@Value" />
    </wwpage:Replacement>
    <wwpage:Replacement name="toc-initial-page-number">
     <xsl:value-of select="$VarTOCPageRule/wwproject:Properties/wwproject:Property[@Name = 'initial-page-number']/@Value" />
    </wwpage:Replacement>
    <wwpage:Replacement name="toc-page-sequence-format">
     <xsl:value-of select="$VarTOCPageRule/wwproject:Properties/wwproject:Property[@Name = 'page-sequence-format']/@Value" />
    </wwpage:Replacement>
    <wwpage:Replacement name="toc-page-sequence-letter-value">
     <xsl:value-of select="$VarTOCPageRule/wwproject:Properties/wwproject:Property[@Name = 'page-sequence-letter-value']/@Value" />
    </wwpage:Replacement>

    <!-- TOC First Master Page -->
    <!--                       -->
    <wwpage:Replacement name="toc-first-master-page">
     <xsl:call-template name="Stitch-MasterPage">
      <xsl:with-param name="ParamPageRule" select="$VarTOCPageRule" />
      <xsl:with-param name="ParamPageName" select="'first'" />
      <xsl:with-param name="ParamMode" select="'toc'" />
     </xsl:call-template>
    </wwpage:Replacement>

    <!-- TOC Last Master Page -->
    <!--                      -->
    <wwpage:Replacement name="toc-last-master-page">
     <xsl:call-template name="Stitch-MasterPage">
      <xsl:with-param name="ParamPageRule" select="$VarTOCPageRule" />
      <xsl:with-param name="ParamPageName" select="'last'" />
      <xsl:with-param name="ParamMode" select="'toc'" />
     </xsl:call-template>
    </wwpage:Replacement>

    <!-- TOC Even Master Page -->
    <!--                      -->
    <wwpage:Replacement name="toc-even-master-page">
     <xsl:call-template name="Stitch-MasterPage">
      <xsl:with-param name="ParamPageRule" select="$VarTOCPageRule" />
      <xsl:with-param name="ParamPageName" select="'even'" />
      <xsl:with-param name="ParamMode" select="'toc'" />
     </xsl:call-template>
    </wwpage:Replacement>

    <!-- TOC Odd Master Page -->
    <!--                     -->
    <wwpage:Replacement name="toc-odd-master-page">
     <xsl:call-template name="Stitch-MasterPage">
      <xsl:with-param name="ParamPageRule" select="$VarTOCPageRule" />
      <xsl:with-param name="ParamPageName" select="'odd'" />
      <xsl:with-param name="ParamMode" select="'toc'" />
     </xsl:call-template>
    </wwpage:Replacement>
   </xsl:if>

   <!-- Index Master Pages -->
   <!--                    -->
   <xsl:if test="$VarGenerateIndex">
    <!-- Index Pagination -->
    <!--                  -->
    <wwpage:Replacement name="index-force-page-count">
     <xsl:value-of select="$VarIndexPageRule/wwproject:Properties/wwproject:Property[@Name = 'force-page-count']/@Value" />
    </wwpage:Replacement>
    <wwpage:Replacement name="index-initial-page-number">
     <xsl:value-of select="$VarIndexPageRule/wwproject:Properties/wwproject:Property[@Name = 'initial-page-number']/@Value" />
    </wwpage:Replacement>
    <wwpage:Replacement name="index-page-sequence-format">
     <xsl:value-of select="$VarIndexPageRule/wwproject:Properties/wwproject:Property[@Name = 'page-sequence-format']/@Value" />
    </wwpage:Replacement>
    <wwpage:Replacement name="index-page-sequence-letter-value">
     <xsl:value-of select="$VarIndexPageRule/wwproject:Properties/wwproject:Property[@Name = 'page-sequence-letter-value']/@Value" />
    </wwpage:Replacement>

    <!-- Index First Master Page -->
    <!--                         -->
    <wwpage:Replacement name="index-first-master-page">
     <xsl:call-template name="Stitch-MasterPage">
      <xsl:with-param name="ParamPageRule" select="$VarIndexPageRule" />
      <xsl:with-param name="ParamPageName" select="'first'" />
      <xsl:with-param name="ParamMode" select="'index'" />
     </xsl:call-template>
    </wwpage:Replacement>

    <!-- Index Last Master Page -->
    <!--                        -->
    <wwpage:Replacement name="index-last-master-page">
     <xsl:call-template name="Stitch-MasterPage">
      <xsl:with-param name="ParamPageRule" select="$VarIndexPageRule" />
      <xsl:with-param name="ParamPageName" select="'last'" />
      <xsl:with-param name="ParamMode" select="'index'" />
     </xsl:call-template>
    </wwpage:Replacement>

    <!-- Index Even Master Page -->
    <!--                        -->
    <wwpage:Replacement name="index-even-master-page">
     <xsl:call-template name="Stitch-MasterPage">
      <xsl:with-param name="ParamPageRule" select="$VarIndexPageRule" />
      <xsl:with-param name="ParamPageName" select="'even'" />
      <xsl:with-param name="ParamMode" select="'index'" />
     </xsl:call-template>
    </wwpage:Replacement>

    <!-- Index Odd Master Page -->
    <!--                       -->
    <wwpage:Replacement name="index-odd-master-page">
     <xsl:call-template name="Stitch-MasterPage">
      <xsl:with-param name="ParamPageRule" select="$VarIndexPageRule" />
      <xsl:with-param name="ParamPageName" select="'odd'" />
      <xsl:with-param name="ParamMode" select="'index'" />
     </xsl:call-template>
    </wwpage:Replacement>
   </xsl:if>

   <!-- Emit master pages for all flows -->
   <!--                                 -->
   <xsl:for-each select="$ParamFlows/flo:Flows/flo:Flow">
    <xsl:variable name="VarFlow" select="." />

    <!-- Aborted? -->
    <!--          -->
    <xsl:if test="not(wwprogress:Abort())">
     <!-- Page Rule -->
     <!--           -->
     <xsl:variable name="VarPageRule" select="wwprojext:GetRule('Page', $VarFlow/@stylename)" />

     <!-- Pagination -->
     <!--            -->
     <wwpage:Replacement name="{$VarFlow/@name}-force-page-count">
      <xsl:value-of select="$VarPageRule/wwproject:Properties/wwproject:Property[@Name = 'force-page-count']/@Value" />
     </wwpage:Replacement>
     <wwpage:Replacement name="{$VarFlow/@name}-initial-page-number">
      <xsl:choose>
       <!-- First Body page-sequence without 'initial-page-number' property? -->
       <!--                                                                  -->
       <xsl:when test="(position() = 1) and (count($VarPageRule/wwproject:Properties/wwproject:Property[@Name = 'initial-page-number']) = 0)">
        <xsl:text>1</xsl:text>
       </xsl:when>

       <xsl:otherwise>
        <xsl:value-of select="$VarPageRule/wwproject:Properties/wwproject:Property[@Name = 'initial-page-number']/@Value" />
       </xsl:otherwise>
      </xsl:choose>
     </wwpage:Replacement>
     <wwpage:Replacement name="{$VarFlow/@name}-page-sequence-format">
      <xsl:value-of select="$VarPageRule/wwproject:Properties/wwproject:Property[@Name = 'page-sequence-format']/@Value" />
     </wwpage:Replacement>
     <wwpage:Replacement name="{$VarFlow/@name}-page-sequence-letter-value">
      <xsl:value-of select="$VarPageRule/wwproject:Properties/wwproject:Property[@Name = 'page-sequence-letter-value']/@Value" />
     </wwpage:Replacement>

     <!-- First Master Page -->
     <!--                   -->
     <wwpage:Replacement name="{$VarFlow/@name}-first-master-page">
      <xsl:comment><xsl:value-of select="$VarFlow/@name" /> first master page </xsl:comment>
      <xsl:comment>     </xsl:comment>
      <xsl:call-template name="Stitch-MasterPage">
       <xsl:with-param name="ParamPageRule" select="$VarPageRule" />
       <xsl:with-param name="ParamPageName" select="'first'" />
       <xsl:with-param name="ParamMode" select="$VarFlow/@name" />
      </xsl:call-template>
     </wwpage:Replacement>

     <!-- Last Master Page -->
     <!--                  -->
     <wwpage:Replacement name="{$VarFlow/@name}-last-master-page">
      <xsl:comment><xsl:value-of select="$VarFlow/@name" /> last master page </xsl:comment>
      <xsl:comment>     </xsl:comment>
      <xsl:call-template name="Stitch-MasterPage">
       <xsl:with-param name="ParamPageRule" select="$VarPageRule" />
       <xsl:with-param name="ParamPageName" select="'last'" />
       <xsl:with-param name="ParamMode" select="$VarFlow/@name" />
      </xsl:call-template>
     </wwpage:Replacement>

     <!-- Even Master Page -->
     <!--                  -->
     <wwpage:Replacement name="{$VarFlow/@name}-even-master-page">
      <xsl:comment><xsl:value-of select="$VarFlow/@name" /> even master page </xsl:comment>
      <xsl:comment>     </xsl:comment>
      <xsl:call-template name="Stitch-MasterPage">
       <xsl:with-param name="ParamPageRule" select="$VarPageRule" />
       <xsl:with-param name="ParamPageName" select="'even'" />
       <xsl:with-param name="ParamMode" select="$VarFlow/@name" />
      </xsl:call-template>
     </wwpage:Replacement>

     <!-- Odd Master Page -->
     <!--                 -->
     <wwpage:Replacement name="{$VarFlow/@name}-odd-master-page">
      <xsl:comment><xsl:value-of select="$VarFlow/@name" /> odd master page </xsl:comment>
      <xsl:comment>     </xsl:comment>
      <xsl:call-template name="Stitch-MasterPage">
       <xsl:with-param name="ParamPageRule" select="$VarPageRule" />
       <xsl:with-param name="ParamPageName" select="'odd'" />
       <xsl:with-param name="ParamMode" select="$VarFlow/@name" />
      </xsl:call-template>
     </wwpage:Replacement>

     <!-- First header -->
     <!--              -->
     <wwpage:Replacement name="{$VarFlow/@name}-first-header">
      <xsl:variable name="VarContentFirstHeaderString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'first-header-string']/@Value" />
      <xsl:if test="string-length($VarContentFirstHeaderString) &gt; 0 and $VarContentFirstHeaderString != 'none'">
       <fo:block>
        <xsl:variable name="VarStyleName" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'first-header-style']/@Value" />

        <xsl:choose>
         <xsl:when test="string-length($VarStyleName) &gt; 0">
          <!-- Process style rule -->
          <!--                    -->
          <xsl:call-template name="Stitch-BlockStyle">
           <xsl:with-param name="ParamSplits" select="$ParamSplits" />
           <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
          </xsl:call-template>
         </xsl:when>

         <xsl:otherwise>
          <!-- Suitable defaults -->
          <!--                   -->
          <xsl:attribute name="text-align">right</xsl:attribute>
          <xsl:attribute name="font-size">8pt</xsl:attribute>
         </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="Stitch-BlockText">
         <xsl:with-param name="ParamBlockText" select="$VarContentFirstHeaderString" />
         <xsl:with-param name="ParamTitle" select="$ParamTitle" />
         <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
        </xsl:call-template>
       </fo:block>
      </xsl:if>
     </wwpage:Replacement>

     <!-- First footer -->
     <!--              -->
     <wwpage:Replacement name="{$VarFlow/@name}-first-footer">
      <xsl:variable name="VarContentFirstFooterString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'first-footer-string']/@Value" />
      <xsl:if test="string-length($VarContentFirstFooterString) &gt; 0 and $VarContentFirstFooterString != 'none'">
       <fo:block>
        <xsl:variable name="VarStyleName" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'first-footer-style']/@Value" />

        <xsl:choose>
         <xsl:when test="string-length($VarStyleName) &gt; 0">
          <!-- Process style rule -->
          <!--                    -->
          <xsl:call-template name="Stitch-BlockStyle">
           <xsl:with-param name="ParamSplits" select="$ParamSplits" />
           <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
          </xsl:call-template>
         </xsl:when>

         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:otherwise>
          <xsl:attribute name="text-align">left</xsl:attribute>
          <xsl:attribute name="font-size">8pt</xsl:attribute>
         </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="Stitch-BlockText">
         <xsl:with-param name="ParamBlockText" select="$VarContentFirstFooterString" />
         <xsl:with-param name="ParamTitle" select="$ParamTitle" />
         <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
        </xsl:call-template>
       </fo:block>
      </xsl:if>
     </wwpage:Replacement>

     <!-- Last header -->
     <!--             -->
     <wwpage:Replacement name="{$VarFlow/@name}-last-header">
      <xsl:variable name="VarContentLastHeaderString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'last-header-string']/@Value" />
      <xsl:if test="string-length($VarContentLastHeaderString) &gt; 0 and $VarContentLastHeaderString != 'none'">
       <fo:block>
        <xsl:variable name="VarStyleName" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'last-header-style']/@Value" />

        <xsl:choose>
         <xsl:when test="string-length($VarStyleName) &gt; 0">
          <!-- Process style rule -->
          <!--                    -->
          <xsl:call-template name="Stitch-BlockStyle">
           <xsl:with-param name="ParamSplits" select="$ParamSplits" />
           <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
          </xsl:call-template>
         </xsl:when>

         <xsl:otherwise>
          <!-- Suitable defaults -->
          <!--                   -->
          <xsl:attribute name="text-align">right</xsl:attribute>
          <xsl:attribute name="font-size">8pt</xsl:attribute>
         </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="Stitch-BlockText">
         <xsl:with-param name="ParamBlockText" select="$VarContentLastHeaderString" />
         <xsl:with-param name="ParamTitle" select="$ParamTitle" />
         <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
        </xsl:call-template>
       </fo:block>
      </xsl:if>
     </wwpage:Replacement>

     <!-- Last footer -->
     <!--             -->
     <wwpage:Replacement name="{$VarFlow/@name}-last-footer">
      <xsl:variable name="VarContentLastFooterString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'last-footer-string']/@Value" />
      <xsl:if test="string-length($VarContentLastFooterString) &gt; 0 and $VarContentLastFooterString != 'none'">
       <fo:block>
        <xsl:variable name="VarStyleName" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'last-footer-style']/@Value" />

        <xsl:choose>
         <xsl:when test="string-length($VarStyleName) &gt; 0">
          <!-- Process style rule -->
          <!--                    -->
          <xsl:call-template name="Stitch-BlockStyle">
           <xsl:with-param name="ParamSplits" select="$ParamSplits" />
           <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
          </xsl:call-template>
         </xsl:when>

         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:otherwise>
          <xsl:attribute name="text-align">left</xsl:attribute>
          <xsl:attribute name="font-size">8pt</xsl:attribute>
         </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="Stitch-BlockText">
         <xsl:with-param name="ParamBlockText" select="$VarContentLastFooterString" />
         <xsl:with-param name="ParamTitle" select="$ParamTitle" />
         <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
        </xsl:call-template>
       </fo:block>
      </xsl:if>
     </wwpage:Replacement>

     <!-- Even header -->
     <!--             -->
     <wwpage:Replacement name="{$VarFlow/@name}-even-header">
      <xsl:variable name="VarContentEvenHeaderString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'even-header-string']/@Value" />
      <xsl:if test="string-length($VarContentEvenHeaderString) &gt; 0 and $VarContentEvenHeaderString != 'none'">
       <fo:block>
        <xsl:variable name="VarStyleName" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'even-header-style']/@Value" />

        <xsl:choose>
         <xsl:when test="string-length($VarStyleName) &gt; 0">
          <!-- Process style rule -->
          <!--                    -->
          <xsl:call-template name="Stitch-BlockStyle">
           <xsl:with-param name="ParamSplits" select="$ParamSplits" />
           <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
          </xsl:call-template>
         </xsl:when>

         <xsl:otherwise>
          <!-- Suitable defaults -->
          <!--                   -->
          <xsl:attribute name="text-align">left</xsl:attribute>
          <xsl:attribute name="font-size">8pt</xsl:attribute>
         </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="Stitch-BlockText">
         <xsl:with-param name="ParamBlockText" select="$VarContentEvenHeaderString" />
         <xsl:with-param name="ParamTitle" select="$ParamTitle" />
         <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
        </xsl:call-template>
       </fo:block>
      </xsl:if>
     </wwpage:Replacement>

     <!-- Even footer -->
     <!--             -->
     <wwpage:Replacement name="{$VarFlow/@name}-even-footer">
      <xsl:variable name="VarContentEvenFooterString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'even-footer-string']/@Value" />
      <xsl:if test="string-length($VarContentEvenFooterString) &gt; 0 and $VarContentEvenFooterString != 'none'">
       <fo:block>
        <xsl:variable name="VarStyleName" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'even-footer-style']/@Value" />

        <xsl:choose>
         <xsl:when test="string-length($VarStyleName) &gt; 0">
          <!-- Process style rule -->
          <!--                    -->
          <xsl:call-template name="Stitch-BlockStyle">
           <xsl:with-param name="ParamSplits" select="$ParamSplits" />
           <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
          </xsl:call-template>
         </xsl:when>

         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:otherwise>
          <xsl:attribute name="text-align">left</xsl:attribute>
          <xsl:attribute name="font-size">8pt</xsl:attribute>
         </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="Stitch-BlockText">
         <xsl:with-param name="ParamBlockText" select="$VarContentEvenFooterString" />
         <xsl:with-param name="ParamTitle" select="$ParamTitle" />
         <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
        </xsl:call-template>
       </fo:block>
      </xsl:if>
     </wwpage:Replacement>

     <!-- Odd header -->
     <!--            -->
     <wwpage:Replacement name="{$VarFlow/@name}-odd-header">
      <xsl:variable name="VarContentOddHeaderString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-header-string']/@Value" />
      <xsl:if test="string-length($VarContentOddHeaderString) &gt; 0 and $VarContentOddHeaderString != 'none'">
       <fo:block>
        <xsl:variable name="VarStyleName" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-header-style']/@Value" />

        <xsl:choose>
         <xsl:when test="string-length($VarStyleName) &gt; 0">
          <!-- Process style rule -->
          <!--                    -->
          <xsl:call-template name="Stitch-BlockStyle">
           <xsl:with-param name="ParamSplits" select="$ParamSplits" />
           <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
          </xsl:call-template>
         </xsl:when>

         <xsl:otherwise>
          <!-- Suitable defaults -->
          <!--                   -->
          <xsl:attribute name="text-align">right</xsl:attribute>
          <xsl:attribute name="font-size">8pt</xsl:attribute>
         </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="Stitch-BlockText">
         <xsl:with-param name="ParamBlockText" select="$VarContentOddHeaderString" />
         <xsl:with-param name="ParamTitle" select="$ParamTitle" />
         <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
        </xsl:call-template>
       </fo:block>
      </xsl:if>
     </wwpage:Replacement>

     <!-- Odd footer -->
     <!--            -->
     <wwpage:Replacement name="{$VarFlow/@name}-odd-footer">
      <xsl:variable name="VarContentOddFooterString" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-footer-string']/@Value" />
      <xsl:if test="string-length($VarContentOddFooterString) &gt; 0 and $VarContentOddFooterString != 'none'">
       <fo:block>
        <xsl:variable name="VarStyleName" select="$VarPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-footer-style']/@Value" />

        <xsl:choose>
         <xsl:when test="string-length($VarStyleName) &gt; 0">
          <!-- Process style rule -->
          <!--                    -->
          <xsl:call-template name="Stitch-BlockStyle">
            <xsl:with-param name="ParamSplits" select="$ParamSplits" />
           <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
          </xsl:call-template>
         </xsl:when>

         <xsl:otherwise>
          <!-- Suitable defaults -->
          <!--                   -->
          <xsl:attribute name="text-align">right</xsl:attribute>
          <xsl:attribute name="font-size">8pt</xsl:attribute>
         </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="Stitch-BlockText">
         <xsl:with-param name="ParamBlockText" select="$VarContentOddFooterString" />
         <xsl:with-param name="ParamTitle" select="$ParamTitle" />
         <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
        </xsl:call-template>
       </fo:block>
      </xsl:if>
     </wwpage:Replacement>

     <!-- Content -->
     <!--         -->
     <wwpage:Replacement name="{$VarFlow/@name}">
      <xsl:for-each select="$VarFlow/wwsplits:Split">
       <xsl:variable name="VarSplit" select="." />

       <!-- Aborted? -->
       <!--          -->
       <xsl:if test="not(wwprogress:Abort())">
        <xsl:variable name="VarPagesFile" select="$ParamPagesFiles[@path = $VarSplit/@page-path][1]" />
        <xsl:variable name="VarPage" select="wwexsldoc:LoadXMLWithoutResolver($VarPagesFile/@path, true())" />

        <xsl:choose>
         <xsl:when test="count($VarPage/fo:root/*) = 0">
          <fo:block/>
         </xsl:when>

         <xsl:otherwise>
          <!-- Copy -->
          <!--      -->
          <xsl:copy-of select="$VarPage/fo:root/*" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:if>
      </xsl:for-each>
     </wwpage:Replacement>
    </xsl:if>
   </xsl:for-each>

   <!-- TOC Content -->
   <!--             -->
   <xsl:if test="$VarGenerateTOC">
    <wwpage:Replacement name="toc-content">
     <xsl:copy-of select="$ParamTOC/fo:root/fo:block[1]/*" />
    </wwpage:Replacement>
   </xsl:if>

   <!-- Bookmarks -->
   <!--           -->
   <xsl:if test="$VarGenerateBookmarks">
    <wwpage:Replacement name="bookmarks">
     <xsl:copy-of select="$ParamTOC/fo:root/fo:bookmark-tree[1]" />
    </wwpage:Replacement>
   </xsl:if>

   <!-- Index Content -->
   <!--               -->
   <xsl:if test="$VarGenerateIndex">
    <wwpage:Replacement name="index-content">
     <xsl:copy-of select="$ParamIndex/fo:root/*" />
    </wwpage:Replacement>
   </xsl:if>

   <!-- Title Headers and Footers -->
   <!--                           -->
   <xsl:if test="$VarGenerateTitlePage">
    <!-- Title First Header -->
    <!--                    -->
    <wwpage:Replacement name="title-first-header">
     <xsl:variable name="VarTitleFirstHeaderString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'first-header-string']/@Value" />
     <xsl:if test="string-length($VarTitleFirstHeaderString) &gt; 0 and $VarTitleFirstHeaderString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'first-header-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTitleFirstHeaderString" />
        <xsl:with-param name="ParamTitle" select="$ParamTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- Title Last Header -->
    <!--                   -->
    <wwpage:Replacement name="title-last-header">
     <xsl:variable name="VarTitleLastHeaderString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'last-header-string']/@Value" />
     <xsl:if test="string-length($VarTitleLastHeaderString) &gt; 0 and $VarTitleLastHeaderString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'last-header-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTitleLastHeaderString" />
        <xsl:with-param name="ParamTitle" select="$ParamTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- Title Even Header -->
    <!--                   -->
    <wwpage:Replacement name="title-even-header">
     <xsl:variable name="VarTitleEvenHeaderString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'even-header-string']/@Value" />
     <xsl:if test="string-length($VarTitleEvenHeaderString) &gt; 0 and $VarTitleEvenHeaderString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'even-header-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTitleEvenHeaderString" />
        <xsl:with-param name="ParamTitle" select="$ParamTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- Title Odd Header -->
    <!--                  -->
    <wwpage:Replacement name="title-odd-header">
     <xsl:variable name="VarTitleOddHeaderString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'odd-header-string']/@Value" />
     <xsl:if test="string-length($VarTitleOddHeaderString) &gt; 0 and $VarTitleOddHeaderString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'odd-header-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTitleOddHeaderString" />
        <xsl:with-param name="ParamTitle" select="$ParamTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- Title First Footer -->
    <!--                    -->
    <wwpage:Replacement name="title-first-footer">
     <xsl:variable name="VarTitleFirstFooterString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'first-footer-string']/@Value" />
     <xsl:if test="string-length($VarTitleFirstFooterString) &gt; 0 and $VarTitleFirstFooterString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'first-footer-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTitleFirstFooterString" />
        <xsl:with-param name="ParamTitle" select="$ParamTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- Title Last Footer -->
    <!--                   -->
    <wwpage:Replacement name="title-last-footer">
     <xsl:variable name="VarTitleLastFooterString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'last-footer-string']/@Value" />
     <xsl:if test="string-length($VarTitleLastFooterString) &gt; 0 and $VarTitleLastFooterString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'last-footer-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTitleLastFooterString" />
        <xsl:with-param name="ParamTitle" select="$ParamTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- Title Even Footer -->
    <!--                   -->
    <wwpage:Replacement name="title-even-footer">
     <xsl:variable name="VarTitleEvenFooterString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'even-footer-string']/@Value" />
     <xsl:if test="string-length($VarTitleEvenFooterString) &gt; 0 and $VarTitleEvenFooterString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'even-footer-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTitleEvenFooterString" />
        <xsl:with-param name="ParamTitle" select="$ParamTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- Title Odd Footer -->
    <!--                  -->
    <wwpage:Replacement name="title-odd-footer">
     <xsl:variable name="VarTitleOddFooterString" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'odd-footer-string']/@Value" />
     <xsl:if test="string-length($VarTitleOddFooterString) &gt; 0 and $VarTitleOddFooterString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTitlePageRule/wwproject:Options/wwproject:Option[@Name = 'odd-footer-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTitleOddFooterString" />
        <xsl:with-param name="ParamTitle" select="$ParamTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>
   </xsl:if>

   <!-- TOC Headers and Footers -->
   <!--                         -->
   <xsl:if test="$VarGenerateTOC">
    <!-- TOC First Header -->
    <!--                  -->
    <wwpage:Replacement name="toc-first-header">
     <xsl:variable name="VarTOCFirstHeaderString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'first-header-string']/@Value" />
     <xsl:if test="string-length($VarTOCFirstHeaderString) &gt; 0 and $VarTOCFirstHeaderString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'first-header-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTOCFirstHeaderString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedTOCTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- TOC Last Header -->
    <!--                 -->
    <wwpage:Replacement name="toc-last-header">
     <xsl:variable name="VarTOCLastHeaderString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'last-header-string']/@Value" />
     <xsl:if test="string-length($VarTOCLastHeaderString) &gt; 0 and $VarTOCLastHeaderString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'last-header-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTOCLastHeaderString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedTOCTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- TOC Even Header -->
    <!--                 -->
    <wwpage:Replacement name="toc-even-header">
     <xsl:variable name="VarTOCEvenHeaderString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'even-header-string']/@Value" />
     <xsl:if test="string-length($VarTOCEvenHeaderString) &gt; 0 and $VarTOCEvenHeaderString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'even-header-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTOCEvenHeaderString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedTOCTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- TOC Odd Header -->
    <!--                -->
    <wwpage:Replacement name="toc-odd-header">
     <xsl:variable name="VarTOCOddHeaderString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-header-string']/@Value" />
     <xsl:if test="string-length($VarTOCOddHeaderString) &gt; 0 and $VarTOCOddHeaderString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-header-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTOCOddHeaderString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedTOCTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- TOC First Footer -->
    <!--                  -->
    <wwpage:Replacement name="toc-first-footer">
     <xsl:variable name="VarTOCFirstFooterString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'first-footer-string']/@Value" />
     <xsl:if test="string-length($VarTOCFirstFooterString) &gt; 0 and $VarTOCFirstFooterString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'first-footer-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTOCFirstFooterString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedTOCTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- TOC Last Footer -->
    <!--                 -->
    <wwpage:Replacement name="toc-last-footer">
     <xsl:variable name="VarTOCLastFooterString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'last-footer-string']/@Value" />
     <xsl:if test="string-length($VarTOCLastFooterString) &gt; 0 and $VarTOCLastFooterString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'last-footer-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTOCLastFooterString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedTOCTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- TOC Even Footer -->
    <!--                 -->
    <wwpage:Replacement name="toc-even-footer">
     <xsl:variable name="VarTOCEvenFooterString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'even-footer-string']/@Value" />
     <xsl:if test="string-length($VarTOCEvenFooterString) &gt; 0 and $VarTOCEvenFooterString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'even-footer-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTOCEvenFooterString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedTOCTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- TOC Odd Footer -->
    <!--                -->
    <wwpage:Replacement name="toc-odd-footer">
     <xsl:variable name="VarTOCOddFooterString" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-footer-string']/@Value" />
     <xsl:if test="string-length($VarTOCOddFooterString) &gt; 0 and $VarTOCOddFooterString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarTOCPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-footer-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarTOCOddFooterString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedTOCTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>
   </xsl:if>

   <!-- Index Headers and Footers -->
   <!--                           -->
   <xsl:if test="$VarGenerateIndex">
    <!-- Index First Header -->
    <!--                    -->
    <wwpage:Replacement name="index-first-header">
     <xsl:variable name="VarIndexFirstHeaderString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'first-header-string']/@Value" />
     <xsl:if test="string-length($VarIndexFirstHeaderString) &gt; 0 and $VarIndexFirstHeaderString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'first-header-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarIndexFirstHeaderString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedIndexTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- Index Last Header -->
    <!--                   -->
    <wwpage:Replacement name="index-last-header">
     <xsl:variable name="VarIndexLastHeaderString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'last-header-string']/@Value" />
     <xsl:if test="string-length($VarIndexLastHeaderString) &gt; 0 and $VarIndexLastHeaderString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'last-header-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarIndexLastHeaderString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedIndexTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- Index Even Header -->
    <!--                   -->
    <wwpage:Replacement name="index-even-header">
     <xsl:variable name="VarIndexEvenHeaderString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'even-header-string']/@Value" />
     <xsl:if test="string-length($VarIndexEvenHeaderString) &gt; 0 and $VarIndexEvenHeaderString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'even-header-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarIndexEvenHeaderString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedIndexTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- Index Odd Header -->
    <!--                  -->
    <wwpage:Replacement name="index-odd-header">
     <xsl:variable name="VarIndexOddHeaderString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-header-string']/@Value" />
     <xsl:if test="string-length($VarIndexOddHeaderString) &gt; 0 and $VarIndexOddHeaderString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-header-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarIndexOddHeaderString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedIndexTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- Index First Footer -->
    <!--                    -->
    <wwpage:Replacement name="index-first-footer">
     <xsl:variable name="VarIndexFirstFooterString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'first-footer-string']/@Value" />
     <xsl:if test="string-length($VarIndexFirstFooterString) &gt; 0 and $VarIndexFirstFooterString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'first-footer-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarIndexFirstFooterString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedIndexTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- Index Last Footer -->
    <!--                   -->
    <wwpage:Replacement name="index-last-footer">
     <xsl:variable name="VarIndexLastFooterString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'last-footer-string']/@Value" />
     <xsl:if test="string-length($VarIndexLastFooterString) &gt; 0 and $VarIndexLastFooterString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'last-footer-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarIndexLastFooterString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedIndexTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- Index Even Footer -->
    <!--                   -->
    <wwpage:Replacement name="index-even-footer">
     <xsl:variable name="VarIndexEvenFooterString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'even-footer-string']/@Value" />
     <xsl:if test="string-length($VarIndexEvenFooterString) &gt; 0 and $VarIndexEvenFooterString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'even-footer-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarIndexEvenFooterString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedIndexTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>

    <!-- Index Odd Footer -->
    <!--                  -->
    <wwpage:Replacement name="index-odd-footer">
     <xsl:variable name="VarIndexOddFooterString" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-footer-string']/@Value" />
     <xsl:if test="string-length($VarIndexOddFooterString) &gt; 0 and $VarIndexOddFooterString != 'none'">
      <fo:block>
       <xsl:variable name="VarStyleName" select="$VarIndexPageRule/wwproject:Options/wwproject:Option[@Name = 'odd-footer-style']/@Value" />

       <xsl:choose>
        <xsl:when test="string-length($VarStyleName) &gt; 0">
         <!-- Process style rule -->
         <!--                    -->
         <xsl:call-template name="Stitch-BlockStyle">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <!-- Suitable defaults -->
         <!--                   -->
         <xsl:attribute name="text-align">outside</xsl:attribute>
         <xsl:attribute name="font-size">8pt</xsl:attribute>
        </xsl:otherwise>
       </xsl:choose>

       <xsl:call-template name="Stitch-BlockText">
        <xsl:with-param name="ParamBlockText" select="$VarIndexOddFooterString" />
        <xsl:with-param name="ParamTitle" select="$VarLocalizedIndexTitle" />
        <xsl:with-param name="ParamStitchMacros" select="$VarStitchMacros" />
       </xsl:call-template>
      </fo:block>
     </xsl:if>
    </wwpage:Replacement>
   </xsl:if>

   <!-- Variables -->
   <!--           -->
   <xsl:call-template name="Variables-Page-String-Replacements">
    <xsl:with-param name="ParamVariables" select="$VarScopeVariables" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarReplacements" select="msxsl:node-set($VarReplacementsAsXML)" />

  <!-- Map common characters -->
  <!--                       -->
  <wwexsldoc:MappingContext>
   <xsl:copy-of select="$GlobalMapEntrySets/wwexsldoc:MapEntrySets/wwexsldoc:MapEntrySet[@name = 'common']/wwexsldoc:MapEntry" />

   <!-- Invoke page template -->
   <!--                      -->
   <xsl:apply-templates select="$ParamPageTemplate" mode="wwmode:pagetemplate">
    <xsl:with-param name="ParamOutputDirectoryPath" select="wwfilesystem:GetDirectoryName($ParamPath)" />
    <xsl:with-param name="ParamOutputPath" select="$ParamPath" />
    <xsl:with-param name="ParamConditions" select="$VarConditions" />
    <xsl:with-param name="ParamReplacements" select="$VarReplacements" />
   </xsl:apply-templates>
  </wwexsldoc:MappingContext>
 </xsl:template>

 <xsl:template name="Stitch-MasterPage">
  <xsl:param name="ParamPageRule" />
  <xsl:param name="ParamPageName" />
  <xsl:param name="ParamMode" />

  <fo:simple-page-master master-name="{$ParamMode}-{$ParamPageName}-master-page">
   <!-- Page height -->
   <!--             -->
   <xsl:attribute name="page-height">
    <xsl:variable name="VarRuleHeight" select="$ParamPageRule/wwproject:Properties/wwproject:Property[@Name = concat($ParamPageName, '-master-page-height')]/@Value" />

    <xsl:choose>
     <xsl:when test="string-length($VarRuleHeight) &gt; 0">
      <xsl:value-of select="$VarRuleHeight" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:text>11in</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>

   <!-- Page width -->
   <!--            -->
   <xsl:attribute name="page-width">
    <xsl:variable name="VarRuleWidth" select="$ParamPageRule/wwproject:Properties/wwproject:Property[@Name = concat($ParamPageName, '-master-page-width')]/@Value" />

    <xsl:choose>
     <xsl:when test="string-length($VarRuleWidth) &gt; 0">
      <xsl:value-of select="$VarRuleWidth" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:text>8.5in</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>

   <!-- Margin bottom -->
   <!--               -->
   <xsl:attribute name="margin-bottom">
    <xsl:variable name="VarRuleMarginBottom" select="$ParamPageRule/wwproject:Properties/wwproject:Property[@Name = concat($ParamPageName, '-master-page-margin-bottom')]/@Value" />

    <xsl:choose>
     <xsl:when test="string-length($VarRuleMarginBottom) &gt; 0">
      <xsl:value-of select="$VarRuleMarginBottom" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:text>0.25in</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>

   <!-- Margin left -->
   <!--             -->
   <xsl:attribute name="margin-left">
    <xsl:variable name="VarRuleMarginLeft" select="$ParamPageRule/wwproject:Properties/wwproject:Property[@Name = concat($ParamPageName, '-master-page-margin-left')]/@Value" />

    <xsl:choose>
     <xsl:when test="string-length($VarRuleMarginLeft) &gt; 0">
      <xsl:value-of select="$VarRuleMarginLeft" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:text>0.25in</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>

   <!-- Margin right -->
   <!--              -->
   <xsl:attribute name="margin-right">
    <xsl:variable name="VarRuleMarginRight" select="$ParamPageRule/wwproject:Properties/wwproject:Property[@Name = concat($ParamPageName, '-master-page-margin-right')]/@Value" />

    <xsl:choose>
     <xsl:when test="string-length($VarRuleMarginRight) &gt; 0">
      <xsl:value-of select="$VarRuleMarginRight" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:text>0.25in</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>

   <!-- Margin top -->
   <!--            -->
   <xsl:attribute name="margin-top">
    <xsl:variable name="VarRuleMarginTop" select="$ParamPageRule/wwproject:Properties/wwproject:Property[@Name = concat($ParamPageName, '-master-page-margin-top')]/@Value" />

    <xsl:choose>
     <xsl:when test="string-length($VarRuleMarginTop) &gt; 0">
      <xsl:value-of select="$VarRuleMarginTop" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:text>0.25in</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:attribute>

   <!-- Body region -->
   <!--             -->
   <fo:region-body region-name="{$ParamMode}-body">
    <!-- Raw properties -->
    <!--                -->
    <xsl:variable name="VarBodyPropertiesPrefix" select="concat($ParamPageName, '-master-page-body-')" />
    <xsl:variable name="VarRawBodyProperties" select="$ParamPageRule/wwproject:Properties/wwproject:Property[starts-with(@Name, $VarBodyPropertiesPrefix)]" />

    <!-- Strip prefix from properties -->
    <!--                              -->
    <xsl:variable name="VarStrippedBodyPropertiesAsXML">
     <xsl:for-each select="$VarRawBodyProperties[not(contains(@Name, 'clip-'))]">
      <wwproject:Property Name="{substring-after(@Name, $VarBodyPropertiesPrefix)}" Value="{@Value}" />
     </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="VarStrippedBodyProperties" select="msxsl:node-set($VarStrippedBodyPropertiesAsXML)/wwproject:Property" />

    <!-- Update properties for FO -->
    <!--                          -->
    <xsl:variable name="VarBodyPropertiesAsXML">
     <xsl:call-template name="FO-TranslateProjectProperties">
      <xsl:with-param name="ParamProperties" select="$VarStrippedBodyProperties" />
      <xsl:with-param name="ParamStyleType" select="'Page'" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarBodyProperties" select="msxsl:node-set($VarBodyPropertiesAsXML)/wwproject:Property" />

    <!-- Emit properties -->
    <!--                 -->
    <xsl:for-each select="$VarBodyProperties">
     <xsl:attribute name="{@Name}">
      <xsl:value-of select="@Value" />
     </xsl:attribute>
    </xsl:for-each>

    <!-- Handle clip -->
    <!--             -->
    <xsl:call-template name="Stitch-CalculateClip">
     <xsl:with-param name="ParamProperties" select="$VarBodyProperties" />
    </xsl:call-template>

    <!-- Give sane default margins -->
    <!--                           -->
    <xsl:if test="count($VarBodyProperties[@Name = 'margin-top'][1]) = 0">
     <xsl:attribute name="margin-top">
      <xsl:text>0.75in</xsl:text>
     </xsl:attribute>
    </xsl:if>

    <xsl:if test="count($VarBodyProperties[@Name = 'margin-right'][1]) = 0">
     <xsl:attribute name="margin-right">
      <xsl:text>0.75in</xsl:text>
     </xsl:attribute>
    </xsl:if>

    <xsl:if test="count($VarBodyProperties[@Name = 'margin-bottom'][1]) = 0">
     <xsl:attribute name="margin-bottom">
      <xsl:text>0.75in</xsl:text>
     </xsl:attribute>
    </xsl:if>

    <xsl:if test="count($VarBodyProperties[@Name = 'margin-left'][1]) = 0">
     <xsl:attribute name="margin-left">
      <xsl:text>0.75in</xsl:text>
     </xsl:attribute>
    </xsl:if>
   </fo:region-body>

   <!-- Before region -->
   <!--               -->

   <!-- Raw properties -->
   <!--                -->
   <xsl:variable name="VarRegionBeforePropertiesPrefix" select="concat($ParamPageName, '-master-page-region-before-')" />
   <xsl:variable name="VarRawRegionBeforeProperties" select="$ParamPageRule/wwproject:Properties/wwproject:Property[starts-with(@Name, $VarRegionBeforePropertiesPrefix)]" />

   <!-- Strip prefix from properties -->
   <!--                              -->
   <xsl:variable name="VarStrippedRegionBeforePropertiesAsXML">
    <xsl:for-each select="$VarRawRegionBeforeProperties[not(contains(@Name, 'clip-'))]">
     <wwproject:Property Name="{substring-after(@Name, $VarRegionBeforePropertiesPrefix)}" Value="{@Value}" />
    </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="VarStrippedRegionBeforeProperties" select="msxsl:node-set($VarStrippedRegionBeforePropertiesAsXML)/wwproject:Property" />

   <!-- Update properties for FO -->
   <!--                          -->
   <xsl:variable name="VarRegionBeforePropertiesAsXML">
    <xsl:call-template name="FO-TranslateProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarStrippedRegionBeforeProperties" />
     <xsl:with-param name="ParamStyleType" select="'Page'" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarRegionBeforeProperties" select="msxsl:node-set($VarRegionBeforePropertiesAsXML)/wwproject:Property" />

   <xsl:variable name="VarHeaderText">
    <xsl:value-of select="$ParamPageRule/wwproject:Options/wwproject:Option[@Name = concat($ParamPageName, '-header-string')][1]/@Value" />
    <xsl:value-of select="$ParamPageRule/wwproject:Options/wwproject:Option[@Name = 'toc-header-string'][1]/@Value" />
    <xsl:value-of select="$ParamPageRule/wwproject:Options/wwproject:Option[@Name = 'index-header-string'][1]/@Value" />
   </xsl:variable>

   <xsl:if test="count($VarRegionBeforeProperties[1]) = 1 or string-length($VarHeaderText) &gt; 0">
    <fo:region-before region-name="{$ParamMode}-{$ParamPageName}-header">

     <!-- extent required -->
     <!--                 -->
     <xsl:attribute name="extent">
      <xsl:variable name="VarRuleExtent" select="$ParamPageRule/wwproject:Properties/wwproject:Property[@Name = concat($VarRegionBeforePropertiesPrefix, 'extent')]/@Value" />

      <xsl:choose>
       <xsl:when test="string-length($VarRuleExtent) &gt; 0">
        <xsl:value-of select="$VarRuleExtent" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:text>0.75in</xsl:text>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:attribute>

     <!-- display-align required -->
     <!--                        -->
     <xsl:attribute name="display-align">
      <xsl:variable name="VarRuleDisplayAlign" select="$ParamPageRule/wwproject:Properties/wwproject:Property[@Name = concat($VarRegionBeforePropertiesPrefix, 'display-align')]/@Value" />

      <xsl:choose>
       <xsl:when test="string-length($VarRuleDisplayAlign) &gt; 0">
        <xsl:value-of select="$VarRuleDisplayAlign" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:text>before</xsl:text>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:attribute>

     <!-- Emit properties -->
    <!--                 -->
    <xsl:for-each select="$VarRegionBeforeProperties">
     <xsl:attribute name="{@Name}">
      <xsl:value-of select="@Value" />
     </xsl:attribute>
    </xsl:for-each>

     <!-- Handle clip -->
     <!--             -->
     <xsl:call-template name="Stitch-CalculateClip">
      <xsl:with-param name="ParamProperties" select="$VarRegionBeforeProperties" />
     </xsl:call-template>
    </fo:region-before>
   </xsl:if>

   <!-- After region -->
   <!--              -->

   <!-- Raw properties -->
   <!--                -->
   <xsl:variable name="VarRegionAfterPropertiesPrefix" select="concat($ParamPageName, '-master-page-region-after-')" />
   <xsl:variable name="VarRawRegionAfterProperties" select="$ParamPageRule/wwproject:Properties/wwproject:Property[starts-with(@Name, $VarRegionAfterPropertiesPrefix)]" />

   <!-- Strip prefix from properties -->
   <!--                              -->
   <xsl:variable name="VarStrippedRegionAfterPropertiesAsXML">
    <xsl:for-each select="$VarRawRegionAfterProperties[not(contains(@Name, 'clip-'))]">
     <wwproject:Property Name="{substring-after(@Name, $VarRegionAfterPropertiesPrefix)}" Value="{@Value}" />
    </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="VarStrippedRegionAfterProperties" select="msxsl:node-set($VarStrippedRegionAfterPropertiesAsXML)/wwproject:Property" />

   <!-- Update properties for FO -->
   <!--                          -->
   <xsl:variable name="VarRegionAfterPropertiesAsXML">
    <xsl:call-template name="FO-TranslateProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarStrippedRegionAfterProperties" />
     <xsl:with-param name="ParamStyleType" select="'Page'" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarRegionAfterProperties" select="msxsl:node-set($VarRegionAfterPropertiesAsXML)/wwproject:Property" />

   <xsl:variable name="VarFooterText">
    <xsl:value-of select="$ParamPageRule/wwproject:Options/wwproject:Option[@Name = concat($ParamPageName, '-footer-string')][1]/@Value" />
    <xsl:value-of select="$ParamPageRule/wwproject:Options/wwproject:Option[@Name = 'toc-footer-string'][1]/@Value" />
    <xsl:value-of select="$ParamPageRule/wwproject:Options/wwproject:Option[@Name = 'index-footer-string'][1]/@Value" />
   </xsl:variable>

   <xsl:if test="count($VarRegionAfterProperties[1]) = 1 or string-length($VarFooterText) &gt; 0">
    <fo:region-after region-name="{$ParamMode}-{$ParamPageName}-footer">

     <!-- extent required -->
     <!--                 -->
     <xsl:attribute name="extent">
      <xsl:variable name="VarRuleExtent" select="$ParamPageRule/wwproject:Properties/wwproject:Property[@Name = concat($VarRegionAfterPropertiesPrefix, 'extent')]/@Value" />

      <xsl:choose>
       <xsl:when test="string-length($VarRuleExtent) &gt; 0">
        <xsl:value-of select="$VarRuleExtent" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:text>0.75in</xsl:text>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:attribute>

     <!-- display-align required -->
     <!--                        -->
     <xsl:attribute name="display-align">
      <xsl:variable name="VarRuleDisplayAlign" select="$ParamPageRule/wwproject:Properties/wwproject:Property[@Name = concat($VarRegionAfterPropertiesPrefix, 'display-align')]/@Value" />

      <xsl:choose>
       <xsl:when test="string-length($VarRuleDisplayAlign) &gt; 0">
        <xsl:value-of select="$VarRuleDisplayAlign" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:text>after</xsl:text>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:attribute>


     <!-- Emit properties -->
    <!--                 -->
    <xsl:for-each select="$VarRegionAfterProperties">
     <xsl:attribute name="{@Name}">
      <xsl:value-of select="@Value" />
     </xsl:attribute>
    </xsl:for-each>

     <!-- Handle clip -->
     <!--             -->
     <xsl:call-template name="Stitch-CalculateClip">
      <xsl:with-param name="ParamProperties" select="$VarRegionAfterProperties" />
     </xsl:call-template>
    </fo:region-after>
   </xsl:if>

   <!-- Start region -->
   <!--              -->

   <!-- Raw properties -->
   <!--                -->
   <xsl:variable name="VarRegionStartPropertiesPrefix" select="concat($ParamPageName, '-master-page-region-start-')" />
   <xsl:variable name="VarRawRegionStartProperties" select="$ParamPageRule/wwproject:Properties/wwproject:Property[starts-with(@Name, $VarRegionStartPropertiesPrefix)]" />

   <!-- Strip prefix from properties -->
   <!--                              -->
   <xsl:variable name="VarStrippedRegionStartPropertiesAsXML">
    <xsl:for-each select="$VarRawRegionStartProperties[not(contains(@Name, 'clip-'))]">
     <wwproject:Property Name="{substring-after(@Name, $VarRegionStartPropertiesPrefix)}" Value="{@Value}" />
    </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="VarStrippedRegionStartProperties" select="msxsl:node-set($VarStrippedRegionStartPropertiesAsXML)/wwproject:Property" />

   <!-- Update properties for FO -->
   <!--                          -->
   <xsl:variable name="VarRegionStartPropertiesAsXML">
    <xsl:call-template name="FO-TranslateProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarStrippedRegionStartProperties" />
     <xsl:with-param name="ParamStyleType" select="'Page'" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarRegionStartProperties" select="msxsl:node-set($VarRegionStartPropertiesAsXML)/wwproject:Property" />

   <xsl:if test="count($VarRegionStartProperties[1]) = 1">
    <fo:region-start region-name="{$ParamMode}-{$ParamPageName}-start">

     <!-- extent required -->
     <!--                 -->
     <xsl:attribute name="extent">
      <xsl:variable name="VarRuleExtent" select="$ParamPageRule/wwproject:Properties/wwproject:Property[@Name = concat($VarRegionStartPropertiesPrefix, 'extent')]/@Value" />

      <xsl:choose>
       <xsl:when test="string-length($VarRuleExtent) &gt; 0">
        <xsl:value-of select="$VarRuleExtent" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:text>0in</xsl:text>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:attribute>

    <!-- Emit properties -->
    <!--                 -->
    <xsl:for-each select="$VarRegionStartProperties">
     <xsl:attribute name="{@Name}">
      <xsl:value-of select="@Value" />
     </xsl:attribute>
    </xsl:for-each>

     <!-- Handle clip -->
     <!--             -->
     <xsl:call-template name="Stitch-CalculateClip">
      <xsl:with-param name="ParamProperties" select="$VarRegionStartProperties" />
     </xsl:call-template>
    </fo:region-start>
   </xsl:if>

   <!-- End region -->
   <!--            -->

   <!-- Raw properties -->
   <!--                -->
   <xsl:variable name="VarRegionEndPropertiesPrefix" select="concat($ParamPageName, '-master-page-region-end-')" />
   <xsl:variable name="VarRawRegionEndProperties" select="$ParamPageRule/wwproject:Properties/wwproject:Property[starts-with(@Name, $VarRegionEndPropertiesPrefix)]" />

   <!-- Strip prefix from properties -->
   <!--                              -->
   <xsl:variable name="VarStrippedRegionEndPropertiesAsXML">
    <xsl:for-each select="$VarRawRegionEndProperties[not(contains(@Name, 'clip-'))]">
     <wwproject:Property Name="{substring-after(@Name, $VarRegionEndPropertiesPrefix)}" Value="{@Value}" />
    </xsl:for-each>
   </xsl:variable>
   <xsl:variable name="VarStrippedRegionEndProperties" select="msxsl:node-set($VarStrippedRegionEndPropertiesAsXML)/wwproject:Property" />

   <!-- Update properties for FO -->
   <!--                          -->
   <xsl:variable name="VarRegionEndPropertiesAsXML">
    <xsl:call-template name="FO-TranslateProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarStrippedRegionEndProperties" />
     <xsl:with-param name="ParamStyleType" select="'Page'" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarRegionEndProperties" select="msxsl:node-set($VarRegionEndPropertiesAsXML)/wwproject:Property" />

   <xsl:if test="count($VarRegionEndProperties[1]) = 1">
    <fo:region-end region-name="{$ParamMode}-{$ParamPageName}-end">

     <!-- extent required -->
     <!--                 -->
     <xsl:attribute name="extent">
      <xsl:variable name="VarRuleExtent" select="$ParamPageRule/wwproject:Properties/wwproject:Property[@Name = concat($VarRegionEndPropertiesPrefix, 'extent')]/@Value" />

      <xsl:choose>
       <xsl:when test="string-length($VarRuleExtent) &gt; 0">
        <xsl:value-of select="$VarRuleExtent" />
       </xsl:when>

       <xsl:otherwise>
        <xsl:text>0in</xsl:text>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:attribute>

    <!-- Emit properties -->
    <!--                 -->
    <xsl:for-each select="$VarRegionEndProperties">
     <xsl:attribute name="{@Name}">
      <xsl:value-of select="@Value" />
     </xsl:attribute>
    </xsl:for-each>

     <!-- Handle clip -->
     <!--             -->
     <xsl:call-template name="Stitch-CalculateClip">
      <xsl:with-param name="ParamProperties" select="$VarRegionEndProperties" />
     </xsl:call-template>
    </fo:region-end>
   </xsl:if>
  </fo:simple-page-master>
 </xsl:template>

 <xsl:template name="Stitch-Text">
  <xsl:param name="ParamText"  />
  <xsl:param name="ParamTitle" />
  <xsl:param name="ParamStitchMacros" />

  <xsl:variable name="VarReplacementsAsXML">
   <wwmultisere:Entry match="$Title;" replacement="{$ParamTitle}" />
   <xsl:copy-of select="$ParamStitchMacros" />
  </xsl:variable>
  <xsl:variable name="VarReplacements" select="msxsl:node-set($VarReplacementsAsXML)/*" />
  <xsl:value-of select="wwmultisere:ReplaceAllInString($ParamText, $VarReplacements)" />
 </xsl:template>
 
 <xsl:template name="Stitch-BlockText">
  <xsl:param name="ParamBlockText" />
  <xsl:param name="ParamTitle" />
  <xsl:param name="ParamStitchMacros" />

  <xsl:variable name="VarTitleReplacedText">
   <xsl:call-template name="Stitch-Text">
    <xsl:with-param name="ParamText" select="$ParamBlockText"/>
    <xsl:with-param name="ParamTitle" select="$ParamTitle"/>
    <xsl:with-param name="ParamStitchMacros" select="$ParamStitchMacros"/>
   </xsl:call-template>
  </xsl:variable>

  <xsl:apply-templates select="msxsl:node-set($VarTitleReplacedText)" mode="string-replace" />
 </xsl:template>

 <xsl:template match="text()[contains(. , '$RunningTitle;')]" mode="string-replace">
  <xsl:variable name="VarBefore" select="substring-before(., '$RunningTitle;')" />
  <xsl:variable name="VarAfter" select="substring-after(., '$RunningTitle;')" />

  <xsl:apply-templates select="msxsl:node-set($VarBefore)" mode="string-replace" />
  <fo:retrieve-marker retrieve-class-name="RunningTitle" retrieve-position="last-starting-within-page" retrieve-boundary="document" />
  <xsl:apply-templates select="msxsl:node-set($VarAfter)" mode="string-replace" />
 </xsl:template>

 <xsl:template match="text()[contains(. , '$ChapterTitle;')]" mode="string-replace">
  <xsl:variable name="VarBefore" select="substring-before(., '$ChapterTitle;')" />
  <xsl:variable name="VarAfter" select="substring-after(., '$ChapterTitle;')" />

  <xsl:apply-templates select="msxsl:node-set($VarBefore)" mode="string-replace" />
  <fo:retrieve-marker retrieve-class-name="ChapterTitle" retrieve-position="last-starting-within-page" retrieve-boundary="document" />
  <xsl:apply-templates select="msxsl:node-set($VarAfter)" mode="string-replace" />
 </xsl:template>

 <xsl:template match="text()[contains(. , '$PageNumber;')]" mode="string-replace">
  <xsl:variable name="VarBefore" select="substring-before(., '$PageNumber;')" />
  <xsl:variable name="VarAfter" select="substring-after(., '$PageNumber;')" />

  <xsl:apply-templates select="msxsl:node-set($VarBefore)" mode="string-replace" />
  <fo:page-number />
  <xsl:apply-templates select="msxsl:node-set($VarAfter)" mode="string-replace" />
 </xsl:template>

 <xsl:template match="text()" mode="string-replace">
  <xsl:value-of select="." />
 </xsl:template>

 <xsl:template match="comment() | processing-instruction()" mode="string-replace">
  <!-- pass -->
  <!--      -->
 </xsl:template>

 <xsl:template name="Stitch-BlockStyle">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamStyleName" />

  <!-- Get rule -->
  <!--          -->
  <xsl:variable name="VarStyleRule" select="wwprojext:GetRule('Paragraph', $ParamStyleName)" />

  <!-- Resolve properties -->
  <!--                    -->
  <xsl:variable name="VarResolvedRulePropertiesAsXML">
   <xsl:call-template name="Properties-ResolveRule">
    <xsl:with-param name="ParamDocumentContext" select="$GlobalFiles/wwfiles:NoContext" />
    <xsl:with-param name="ParamProperties" select="$VarStyleRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamStyleName" select="$ParamStyleName" />
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
 </xsl:template>

 <xsl:template name="Stitch-CalculateClip">
  <xsl:param name="ParamProperties" />

  <!-- Clip -->
  <!--      -->
  <xsl:variable name="VarClipBottom" select="$ParamProperties[contains(@Name, 'clip-bottom')]" />
  <xsl:variable name="VarClipLeft" select="$ParamProperties[contains(@Name, 'clip-left')]" />
  <xsl:variable name="VarClipRight" select="$ParamProperties[contains(@Name, 'clip-right')]" />
  <xsl:variable name="VarClipTop" select="$ParamProperties[contains(@Name, 'clip-top')]" />

  <xsl:if test="(string-length($VarClipBottom/@Value) &gt; 0) or (string-length($VarClipLeft/@Value) &gt; 0) or (string-length($VarClipRight/@Value) &gt; 0) or (string-length($VarClipTop/@Value) &gt; 0)">
   <!-- Bottom -->
   <!--        -->
   <xsl:variable name="VarClipBottomValue">
    <xsl:choose>
     <xsl:when test="string-length($VarClipBottom/@Value) &gt; 0">
      <xsl:value-of select="$VarClipBottom/@Value" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:text>0pt</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Left -->
   <!--      -->
   <xsl:variable name="VarClipLeftValue">
    <xsl:choose>
     <xsl:when test="string-length($VarClipLeft/@Value) &gt; 0">
      <xsl:value-of select="$VarClipLeft/@Value" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:text>0pt</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Right -->
   <!--       -->
   <xsl:variable name="VarClipRightValue">
    <xsl:choose>
     <xsl:when test="string-length($VarClipRight/@Value) &gt; 0">
      <xsl:value-of select="$VarClipRight/@Value" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:text>0pt</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Top -->
   <!--     -->
   <xsl:variable name="VarClipTopValue">
    <xsl:choose>
     <xsl:when test="string-length($VarClipTop/@Value) &gt; 0">
      <xsl:value-of select="$VarClipTop/@Value" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:text>0pt</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Emit result attribute -->
   <!--                       -->
   <xsl:attribute name="clip">
    <xsl:text>rect(</xsl:text>
    <xsl:value-of select="$VarClipTopValue" />
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$VarClipRightValue" />
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$VarClipBottomValue" />
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$VarClipLeftValue" />
    <xsl:text>)</xsl:text>
   </xsl:attribute>
  </xsl:if>
 </xsl:template>

 <xsl:template name="Stitch-Block">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamDefaultProperties" />
  <xsl:param name="ParamBlockID" />
  <xsl:param name="ParamContent" />

  <xsl:variable name="VarPropertiesAsXML">
   <xsl:choose>
    <xsl:when test="string-length($ParamStyleName) &gt; 0">
     <!-- Get rule -->
     <!--          -->
     <xsl:variable name="VarStyleRule" select="wwprojext:GetRule('Paragraph', $ParamStyleName)" />

     <!-- Resolve properties -->
     <!--                    -->
     <xsl:variable name="VarResolvedRulePropertiesAsXML">
      <xsl:call-template name="Properties-ResolveRule">
       <xsl:with-param name="ParamDocumentContext" select="$GlobalFiles/wwfiles:NoContext" />
       <xsl:with-param name="ParamProperties" select="$VarStyleRule/wwproject:Properties/wwproject:Property" />
       <xsl:with-param name="ParamStyleName" select="$ParamStyleName" />
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
      <xsl:copy-of select="."/>
     </xsl:for-each>
    </xsl:when>

    <xsl:otherwise>
     <xsl:for-each select="$ParamDefaultProperties">
      <xsl:copy-of select="."/>
     </xsl:for-each>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarProperties" select="msxsl:node-set($VarPropertiesAsXML)/wwproject:Property" />

  <xsl:variable name="VarUseContainer" select="count($VarProperties[(@Name = 'absolute-position') or
                                                                    (@Name = 'display-align') or
                                                                    (@Name = 'height') or
                                                                    (@Name = 'overflow') or
                                                                    (@Name = 'reference-orientation') or
                                                                    (@Name = 'width') or
                                                                    (@Name = 'writing-mode') or
                                                                    (@Name = 'z-index') or
                                                                    (@Name = 'top') or
                                                                    (@Name = 'right') or
                                                                    (@Name = 'bottom') or
                                                                    (@Name = 'left')
                                                                   ]) &gt; 0" />

  <xsl:choose>
   <xsl:when test="$VarUseContainer">
    <fo:block-container>
     <xsl:for-each select="$VarProperties[(@Name = 'absolute-position') or
                                          (@Name = 'display-align') or
                                          (@Name = 'height') or
                                          (@Name = 'overflow') or
                                          (@Name = 'reference-orientation') or
                                          (@Name = 'width') or
                                          (@Name = 'writing-mode') or
                                          (@Name = 'z-index') or
                                          (@Name = 'top') or
                                          (@Name = 'right') or
                                          (@Name = 'bottom') or
                                          (@Name = 'left')]">
      <xsl:attribute name="{@Name}">
       <xsl:value-of select="@Value" />
      </xsl:attribute>
     </xsl:for-each>

     <!-- Auto-promote to absolute positioning when offset properties are present -->
     <!--                                                                         -->
     <xsl:if test="$VarProperties[(@Name = 'top') or (@Name = 'right') or (@Name = 'bottom') or (@Name = 'left')]">
      <xsl:if test="not($VarProperties[(@Name = 'absolute-position') and ((@Value = 'absolute') or (@Value = 'fixed'))])">
       <xsl:attribute name="absolute-position">absolute</xsl:attribute>
      </xsl:if>
     </xsl:if>

     <fo:block id="{$ParamBlockID}">
      <xsl:for-each select="$VarProperties[(@Name != 'absolute-position') and
                                           (@Name != 'display-align') and
                                           (@Name != 'height') and
                                           (@Name != 'overflow') and
                                           (@Name != 'reference-orientation') and
                                           (@Name != 'width') and
                                           (@Name != 'writing-mode') and
                                           (@Name != 'z-index') and
                                           (@Name != 'top') and
                                           (@Name != 'right') and
                                           (@Name != 'bottom') and
                                           (@Name != 'left')]">
       <xsl:attribute name="{@Name}">
        <xsl:value-of select="@Value" />
       </xsl:attribute>
      </xsl:for-each>

      <xsl:for-each select="$ParamContent">
       <xsl:copy-of select="." />
      </xsl:for-each>
     </fo:block>
    </fo:block-container>
   </xsl:when>

   <xsl:otherwise>
    <fo:block id="{$ParamBlockID}">
     <xsl:for-each select="$VarProperties">
      <xsl:attribute name="{@Name}">
       <xsl:value-of select="@Value" />
      </xsl:attribute>
     </xsl:for-each>

     <xsl:for-each select="$ParamContent">
      <xsl:copy-of select="."/>
     </xsl:for-each>
    </fo:block>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>
