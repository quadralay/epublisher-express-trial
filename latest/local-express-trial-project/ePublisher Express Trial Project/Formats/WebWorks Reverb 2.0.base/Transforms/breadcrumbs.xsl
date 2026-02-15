<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
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
                              xmlns:wwx="urn:WebWorks-Web-Extension-Schema"
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwbehaviors wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc"
>
  <xsl:template name="Breadcrumbs">
  <xsl:param name="ParamPageRule" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBreadcrumbTOCEntry" />

  <!-- Determine separator -->
  <!--                     -->
  <xsl:variable name="VarBreadcrumbsSeparator">
   <xsl:variable name="VarBreadcrumbsSeparatorProperty" select="$ParamPageRule/wwproject:Properties/wwproject:Property[@Name = 'breadcrumbs-separator']/@Value" />
   <xsl:choose>
    <xsl:when test="string-length($VarBreadcrumbsSeparatorProperty) &gt; 0">
     <xsl:value-of select="$VarBreadcrumbsSeparatorProperty" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:text> : </xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Emit merge groups? -->
  <!--                    -->
  <xsl:variable name="VarMergeGroupsInBreadcrumbsOption" select="$ParamPageRule/wwproject:Options/wwproject:Option[@Name = 'include-merge-groups-in-breadcrumbs']/@Value" />
  <xsl:if test="$VarMergeGroupsInBreadcrumbsOption = 'true' or string-length($VarMergeGroupsInBreadcrumbsOption) = 0">
   <!-- Locate merge group settings -->
   <!--                             -->
   <xsl:variable name="VarMergeGroup" select="$GlobalProject/wwproject:Project/wwproject:FormatConfigurations/wwproject:FormatConfiguration[@TargetID = wwprojext:GetFormatID()]/wwproject:MergeSettings//wwproject:MergeGroup[@GroupID = $ParamSplit/@groupID]" />

   <!-- Find first generated page in group -->
   <!--                                    -->
   <xsl:variable name="VarFirstSplitInGroup" select="$ParamSplit/parent::wwsplits:Splits/wwsplits:Split[@groupID = $ParamSplit/@groupID][1]" />

   <!-- Emit merge groups hierarchy -->
   <!--                             -->
   <xsl:apply-templates select="$VarMergeGroup" mode="breadcrumbs-merge-hierarchy">
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamFirstSplitInGroup" select="$VarFirstSplitInGroup" />
    <xsl:with-param name="ParamBreadcrumbsSeparator" select="$VarBreadcrumbsSeparator" />
   </xsl:apply-templates>

   <!-- Emit separator -->
   <!--                -->
   <xsl:if test="count($ParamBreadcrumbTOCEntry) &gt; 0">
    <xsl:value-of select="$VarBreadcrumbsSeparator" />
   </xsl:if>
  </xsl:if>

  <!-- Emit TOC breadcrumb entries -->
  <!--                             -->
  <xsl:apply-templates select="$ParamBreadcrumbTOCEntry" mode="breadcrumbs-toc-hierarchy">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBreadcrumbTOCEntry" select="$ParamBreadcrumbTOCEntry" />
   <xsl:with-param name="ParamBreadcrumbsSeparator" select="$VarBreadcrumbsSeparator" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template name="BreadcrumbEntry">
  <xsl:param name="ParamTOCEntry" />

  <xsl:for-each select="$ParamTOCEntry/wwdoc:Paragraph/wwdoc:Number/wwdoc:Text | $ParamTOCEntry/wwdoc:Paragraph//wwdoc:TextRun/wwdoc:Text">
   <xsl:variable name="VarText" select="." />

   <xsl:value-of select="$VarText/@value" />
  </xsl:for-each>
 </xsl:template>

 <xsl:template match="wwproject:TOC" mode="breadcrumbs-merge-hierarchy">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamFirstSplitInGroup" />
  <xsl:param name="ParamBreadcrumbsSeparator" />
  <xsl:param name="ParamMergeTOC" select="." />

  <!-- Process parent -->
  <!--                -->
  <xsl:apply-templates select="$ParamMergeTOC/parent::*" mode="breadcrumbs-merge-hierarchy">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamFirstSplitInGroup" select="$ParamFirstSplitInGroup" />
   <xsl:with-param name="ParamBreadcrumbsSeparator" select="$ParamBreadcrumbsSeparator" />
  </xsl:apply-templates>

  <!-- Emit separator -->
  <!--                -->
  <xsl:if test="count($ParamMergeTOC/parent::wwproject:TOC) &gt; 0">
   <xsl:value-of select="$ParamBreadcrumbsSeparator" />
  </xsl:if>

  <!-- Emit entry -->
  <!--            -->
  <xsl:choose>
   <!-- Entry with link -->
   <!--                 -->
   <xsl:when test="count($ParamFirstSplitInGroup | $ParamSplit) &gt; 1">
    <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($ParamFirstSplitInGroup/@path, $ParamSplit/@path)" />
    <html:a class="WebWorks_Breadcrumb_Link" href="{$VarRelativePath}">
     <xsl:value-of select="$ParamMergeTOC/@Name" />
    </html:a>
   </xsl:when>

   <!-- Entry without link -->
   <!--                    -->
   <xsl:otherwise>
    <html:span class="WebWorks_Breadcrumb_Text">
     <xsl:value-of select="$ParamMergeTOC/@Name" />
    </html:span>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="wwproject:MergeGroup" mode="breadcrumbs-merge-hierarchy">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamFirstSplitInGroup" />
  <xsl:param name="ParamBreadcrumbsSeparator" />
  <xsl:param name="ParamMergeGroup" select="." />

  <!-- Process parent -->
  <!--                -->
  <xsl:apply-templates select="$ParamMergeGroup/parent::*" mode="breadcrumbs-merge-hierarchy">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamFirstSplitInGroup" select="$ParamFirstSplitInGroup" />
   <xsl:with-param name="ParamBreadcrumbsSeparator" select="$ParamBreadcrumbsSeparator" />
  </xsl:apply-templates>

  <!-- Emit separator -->
  <!--                -->
  <xsl:if test="count($ParamMergeGroup/parent::wwproject:TOC) &gt; 0">
   <xsl:value-of select="$ParamBreadcrumbsSeparator" />
  </xsl:if>

  <!-- Determine title -->
  <!--                 -->
  <xsl:variable name="VarMergeGroupTitle">
   <xsl:choose>
    <!-- Title exists? -->
    <!--               -->
    <xsl:when test="string-length($ParamMergeGroup/@Title) &gt; 0">
     <xsl:value-of select="$ParamMergeGroup/@Title" />
    </xsl:when>

    <!-- Use group name -->
    <!--                -->
    <xsl:otherwise>
     <xsl:value-of select="wwprojext:GetGroupName($ParamMergeGroup/@GroupID)" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Emit entry -->
  <!--            -->
  <xsl:choose>
   <!-- Entry with link -->
   <!--                 -->
   <xsl:when test="count($ParamFirstSplitInGroup | $ParamSplit) &gt; 1">
    <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($ParamFirstSplitInGroup/@path, $ParamSplit/@path)" />
    <html:a class="WebWorks_Breadcrumb_Link" href="{$VarRelativePath}">
     <xsl:value-of select="$VarMergeGroupTitle" />
    </html:a>
   </xsl:when>

   <!-- Entry without link -->
   <!--                    -->
   <xsl:otherwise>
    <html:span class="WebWorks_Breadcrumb_Text">
     <xsl:value-of select="$VarMergeGroupTitle" />
    </html:span>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="*" mode="breadcrumbs-merge-hierarchy">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamFirstSplitInGroup" />
  <xsl:param name="ParamBreadcrumbsSeparator" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="breadcrumbs-merge-hierarchy">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamFirstSplitInGroup" />
  <xsl:param name="ParamBreadcrumbsSeparator" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <!-- breadcrumbs-toc-hierarchy -->
 <!--                           -->
 <xsl:template match="wwtoc:Entry" mode="breadcrumbs-toc-hierarchy">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBreadcrumbTOCEntry" />
  <xsl:param name="ParamBreadcrumbsSeparator" />
  <xsl:param name="ParamTOCEntry" select="." />


  <!-- Process parent -->
  <!--                -->
  <xsl:apply-templates select="$ParamTOCEntry/parent::*" mode="breadcrumbs-toc-hierarchy">
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamBreadcrumbTOCEntry" select="$ParamBreadcrumbTOCEntry" />
   <xsl:with-param name="ParamBreadcrumbsSeparator" select="$ParamBreadcrumbsSeparator" />
  </xsl:apply-templates>

  <!-- Emit separator if necessary -->
  <!--                             -->
  <xsl:if test="count($ParamTOCEntry/parent::wwtoc:Entry) &gt; 0">
   <xsl:value-of select="$ParamBreadcrumbsSeparator" />
  </xsl:if>

  <!-- Emit entry -->
  <!--            -->
  <xsl:choose>
   <!-- Entry with link -->
   <!--                 -->
   <xsl:when test="(string-length($ParamTOCEntry/@path) &gt; 0) and (count($ParamBreadcrumbTOCEntry | $ParamTOCEntry) &gt; 1)">
    <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($ParamTOCEntry/@path, $ParamSplit/@path)" />
    <html:a class="WebWorks_Breadcrumb_Link" href="{$VarRelativePath}#{$ParamBreadcrumbTOCEntry/@linkid}">
     <xsl:call-template name="BreadcrumbEntry">
      <xsl:with-param name="ParamTOCEntry" select="$ParamTOCEntry" />
     </xsl:call-template>
    </html:a>
   </xsl:when>

   <!-- Entry without link -->
   <!--                    -->
   <xsl:otherwise>
    <html:span class="WebWorks_Breadcrumb_Text">
     <xsl:call-template name="BreadcrumbEntry">
      <xsl:with-param name="ParamTOCEntry" select="$ParamTOCEntry" />
     </xsl:call-template>
    </html:span>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="*" mode="breadcrumbs-toc-hierarchy">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBreadcrumbTOCEntry" />
  <xsl:param name="ParamBreadcrumbsSeparator" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>


 <xsl:template match="text() | comment() | processing-instruction()" mode="breadcrumbs-toc-hierarchy">
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBreadcrumbTOCEntry" />
  <xsl:param name="ParamBreadcrumbsSeparator" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>
</xsl:stylesheet>
