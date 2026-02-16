<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwlandmarks="urn:WebWorks-XSLT-Extension-Landmarks"
                              exclude-result-prefixes="xsl msxsl wwmode wwdoc wwsplits wwexsldoc wwproject wwuri wwstring wwprojext wwlandmarks html">

 <xsl:key name="wwdoc-paragraphstyle-by-name" match="wwdoc:ParagraphStyle" use="@name" />

 <!-- Returns an alias value if present on the paragraph; otherwise its @id -->
 <xsl:template name="Landmarks-DetermineAliasOrID">
  <xsl:param name="ParamParagraph" />

  <xsl:variable name="VarParagraphID" select="$ParamParagraph/@id" />
  <xsl:variable name="VarParagraphAlias" select="$ParamParagraph/wwdoc:Aliases/wwdoc:Alias[1]/@value" />

  <xsl:choose>
   <xsl:when test="string-length($VarParagraphAlias) > 0">
    <xsl:value-of select="$VarParagraphAlias" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$VarParagraphID" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="Landmarks-ShouldGenerateID">
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamWIFDocumentParagraphStyle" />

  <!-- Read option from paragraph context rule -->
  <!--                                         -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamParagraph/@stylename, $ParamDocumentID, $ParamParagraph/@id)" />
  <xsl:variable name="VarGenerateLandmarkID" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-landmark-id']/@Value" />
  <xsl:choose>
   <!-- Explicit true -->
   <!--               -->
   <xsl:when test="$VarGenerateLandmarkID = 'true'">
    <xsl:value-of select="true()" />
   </xsl:when>

   <!-- Explicit false -->
   <!--                -->
   <xsl:when test="$VarGenerateLandmarkID = 'false'">
    <xsl:value-of select="false()" />
   </xsl:when>

   <!-- Auto -->
   <!--      -->
   <xsl:when test="$VarGenerateLandmarkID = 'auto'">
    <!-- Determine TOC level -->
    <!--                     -->
    <xsl:variable name="VarTOCLevel">
     <xsl:variable name="VarTOCOptionHint" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'toc-level']/@Value" />
     <xsl:choose>
      <xsl:when test="$VarTOCOptionHint = 'auto-detect'">
       <xsl:variable name="VarAutoDetectLevel">
        <xsl:choose>
         <xsl:when test="count($ParamParagraph/wwdoc:Style/wwdoc:Attribute[@name = 'toc-level'][1]) = 1">
          <xsl:value-of select="$ParamParagraph/wwdoc:Style/wwdoc:Attribute[@name = 'toc-level'][1]/@value" />
         </xsl:when>

         <xsl:when test="count($ParamWIFDocumentParagraphStyle/wwdoc:Style/wwdoc:Attribute[@name = 'toc-level'][1]) = 1">
          <xsl:value-of select="$ParamWIFDocumentParagraphStyle/wwdoc:Style/wwdoc:Attribute[@name = 'toc-level'][1]/@value" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="0" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:variable>
       <xsl:value-of select="$VarAutoDetectLevel" />
      </xsl:when>

      <xsl:otherwise>
       <xsl:value-of select="$VarTOCOptionHint" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:variable>

    <!-- Return true if toc-level > 0 -->
    <!--                              -->
    <xsl:value-of select="number($VarTOCLevel) > 0" />
   </xsl:when>

   <!-- Default -->
   <xsl:otherwise>
    <xsl:value-of select="false()" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="Landmarks-GenerateEntries">
  <xsl:param name="ParamProject" />
  <xsl:param name="ParamLandmarksFilePath" />
  <xsl:param name="ParamFilesByType" />
  <xsl:param name="ParamSplits" />

  <xsl:variable name="VarAllEntries">
    <wwlandmarks:Entries>
    <xsl:for-each select="$ParamFilesByType">
     <xsl:variable name="VarFilesDocument" select="." />

     <!-- Load document and get metadata -->
     <!--                                -->
     <xsl:variable name="VarWIFDocument" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesDocument/@path, false())" />
     <xsl:variable name="VarWIFDocumentParagraphStyles" select="$VarWIFDocument/wwdoc:Document[1]/wwdoc:Styles[1]/wwdoc:ParagraphStyles[1]" />
     <xsl:variable name="VarDocumentNode" select="$ParamProject//wwproject:Document[@DocumentID = $VarFilesDocument/@documentID]" />
     <xsl:variable name="VarDocumentPath" select="$VarDocumentNode/@Path"/>
     <xsl:variable name="VarDocumentID" select="$VarDocumentNode/@DocumentID"/>

     <!-- Get splits for this document -->
     <!--                              -->
     <xsl:variable name="VarDocumentSplits" select="$ParamSplits/wwsplits:Splits/wwsplits:Split[@documentID = $VarFilesDocument/@documentID]" />

     <!-- Process each split in this document -->
     <!--                                     -->
     <xsl:for-each select="$VarDocumentSplits">
      <xsl:variable name="VarSplit" select="." />

      <!-- Calculate relative path from landmarks file to split -->
      <!--                                                      -->
      <xsl:variable name="VarSplitPath" select="$VarSplit/@path" />
      <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($VarSplitPath, $ParamLandmarksFilePath)" />

      <!-- Get content in this split's range from the full document -->
      <!--                                                          -->
      <xsl:variable name="VarContent" select="$VarWIFDocument/wwdoc:Document/wwdoc:Content/*[(position() &gt;= $VarSplit/@documentstartposition) and (position() &lt;= $VarSplit/@documentendposition)]" />

      <xsl:variable name="VarFirstParagraph" select="($VarContent/descendant-or-self::wwdoc:Paragraph)[1]"/>
      <xsl:variable name="VarFirstAliasOrID">
       <xsl:call-template name="Landmarks-DetermineAliasOrID">
        <xsl:with-param name="ParamParagraph" select="$VarFirstParagraph"/>
       </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="VarLandmarkID" select="wwstring:CreateBlake2bHash(16, $VarDocumentPath, $VarFirstAliasOrID)" />

      <!-- Create file-level wwlandmarks:Entry -->
      <!--                                     -->
      <wwlandmarks:Entry id="{$VarLandmarkID}" path="{$VarRelativePath}"/>

      <!-- Process paragraphs in this split's content -->
      <!--                                            -->
      <xsl:apply-templates select="$VarContent" mode="wwmode:landmarks-entry">
       <xsl:with-param name="ParamLandmarksFilePath" select="$ParamLandmarksFilePath" />
       <xsl:with-param name="ParamWIFDocumentParagraphStyles" select="$VarWIFDocumentParagraphStyles" />
       <xsl:with-param name="ParamDocumentPath" select="$VarDocumentPath" />
       <xsl:with-param name="ParamDocumentID" select="$VarDocumentID" />
       <xsl:with-param name="ParamSplit" select="$VarSplit" />
      </xsl:apply-templates>
     </xsl:for-each>
    </xsl:for-each>
   </wwlandmarks:Entries>
  </xsl:variable>

  <wwlandmarks:Entries>
   <xsl:for-each select="msxsl:node-set($VarAllEntries)/wwlandmarks:Entries/wwlandmarks:Entry">
    <xsl:copy-of select="."/>
   </xsl:for-each>
  </wwlandmarks:Entries>
 </xsl:template>

 <!-- Mode template to process paragraphs and generate landmark entries -->
 <!--                                                                   -->
 <xsl:template match="wwdoc:Paragraph" mode="wwmode:landmarks-entry">
  <xsl:param name="ParamLandmarksFilePath" />
  <xsl:param name="ParamWIFDocumentParagraphStyles" />
  <xsl:param name="ParamDocumentPath" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarParagraph" select="." />
  <xsl:variable name="VarParagraphID" select="$VarParagraph/@id" />

  <xsl:variable name="VarWIFDocumentParagraphStyle" select="$ParamWIFDocumentParagraphStyles/wwdoc:ParagraphStyle[@name = $VarParagraph/@stylename]"/>

  <!-- Check if this paragraph should generate a landmark ID -->
  <!--                                                       -->
  <xsl:variable name="VarShouldGenerate">
   <xsl:call-template name="Landmarks-ShouldGenerateID">
    <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
    <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
    <xsl:with-param name="ParamWIFDocumentParagraphStyle" select="$VarWIFDocumentParagraphStyle"/>
   </xsl:call-template>
  </xsl:variable>

  <!-- Only output if should generate -->
  <!--                                -->
  <xsl:if test="$VarShouldGenerate = string(true())">
   <!-- Create LandmarkID -->
   <!--                   -->
   <xsl:variable name="VarID">
    <xsl:call-template name="Landmarks-DetermineAliasOrID">
     <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarLandmarkID" select="wwstring:CreateBlake2bHash(16, $ParamDocumentPath, $VarID)" />

   <!-- Calculate relative path from landmarks file to split -->
   <!--                                                      -->
   <xsl:variable name="VarSplitPath" select="$ParamSplit/@path" />
   <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($VarSplitPath, $ParamLandmarksFilePath)" />
   <xsl:variable name="VarContentID" select="concat('ww', $VarParagraphID)" />
   <xsl:variable name="VarPath" select="concat($VarRelativePath, '#', $VarContentID)" />

   <wwlandmarks:Entry id="{$VarLandmarkID}" path="{$VarPath}"/>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Block|wwdoc:List|wwdoc:Table" mode="wwmode:landmarks-entry">
  <xsl:param name="ParamLandmarksFilePath" />
  <xsl:param name="ParamWIFDocumentParagraphStyles" />
  <xsl:param name="ParamDocumentPath" />
  <xsl:param name="ParamDocumentID" />
  <xsl:param name="ParamSplit" />

  <!-- Process paragraphs in this node's content -->
  <!--                                            -->
  <xsl:apply-templates select=".//wwdoc:Paragraph" mode="wwmode:landmarks-entry">
   <xsl:with-param name="ParamLandmarksFilePath" select="$ParamLandmarksFilePath" />
   <xsl:with-param name="ParamWIFDocumentParagraphStyles" select="$ParamWIFDocumentParagraphStyles" />
   <xsl:with-param name="ParamDocumentID" select="$ParamDocumentID" />
   <xsl:with-param name="ParamDocumentPath" select="$ParamDocumentPath" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:apply-templates>
 </xsl:template>

</xsl:stylesheet>
