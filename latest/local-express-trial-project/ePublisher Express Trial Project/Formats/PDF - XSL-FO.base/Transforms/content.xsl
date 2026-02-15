<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Format"
                              xmlns:fo="http://www.w3.org/1999/XSL/Format"
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
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwbehaviors wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc"
>
 <xsl:key name="wwsplits-frames-by-id" match="wwsplits:Frame" use="@id" />
 <xsl:key name="wwtoc-entry-by-id" match="wwtoc:Entry" use="@id" />
 <xsl:key name="wwbehaviors-paragraphs-by-id" match="wwbehaviors:Paragraph" use="@id" />
 <xsl:key name="wwbehaviors-frames-by-id" match="wwbehaviors:Frame" use="@id" />
 <xsl:key name="wwbehaviors-tables-by-id" match="wwbehaviors:Table" use="@id" />
 <xsl:key name="wwbehaviors-markers-by-id" match="wwbehaviors:Marker" use="@id" />
 <xsl:key name="wwnotes-notes-by-id" match="wwnotes:Note" use="@id" />
 <xsl:key name="wwfiles-files-by-path" match="wwfiles:File" use="@path" />
 <xsl:key name="wwlinks-by-anchor" match="wwdoc:Link" use="@anchor" />


 <xsl:template name="Content-Content">
  <xsl:param name="ParamContent" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <!-- Content -->
  <!--         -->
  <xsl:apply-templates select="$ParamContent" mode="wwmode:content">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:apply-templates>

  <!-- Related Topics -->
  <!--                -->
  <xsl:call-template name="RelatedTopics">
   <xsl:with-param name="ParamContent" select="$ParamContent" />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template name="RelatedTopics">
  <xsl:param name="ParamContent" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarAllRelatedTopicParagraphsAsXML">
   <xsl:apply-templates select="$ParamContent" mode="wwmode:related-topics-paragraphs">
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
   </xsl:apply-templates>
  </xsl:variable>
  <xsl:variable name="VarAllRelatedTopicParagraphs" select="msxsl:node-set($VarAllRelatedTopicParagraphsAsXML)/wwdoc:Paragraph" />

  <xsl:variable name="VarRelatedTopicParagraphsAsXML">
   <xsl:call-template name="EliminateDuplicateRelatedTopicParagraphs">
    <xsl:with-param name="ParamRelatedTopicParagraphs" select="$VarAllRelatedTopicParagraphs" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarRelatedTopicParagraphs" select="msxsl:node-set($VarRelatedTopicParagraphsAsXML)/wwdoc:Paragraph" />

  <xsl:if test="count($VarRelatedTopicParagraphs) &gt; 0">

   <fo:block>
    <fo:block>
     <xsl:variable name="VarRelatedTopicsTitleStyleName" select="wwprojext:GetFormatSetting('related-topics-title-style')" />

     <xsl:choose>
      <xsl:when test="string-length($VarRelatedTopicsTitleStyleName) &gt; 0">
       <xsl:variable name="VarRelatedTopicsTitleRule" select="wwprojext:GetRule('Paragraph', $VarRelatedTopicsTitleStyleName)" />

       <xsl:variable name="VarResolvedRulePropertiesAsXML">
        <xsl:call-template name="Properties-ResolveRule">
         <xsl:with-param name="ParamDocumentContext" select="$ParamSplit/wwsplits:NoContext" />
         <xsl:with-param name="ParamProperties" select="$VarRelatedTopicsTitleRule/wwproject:Properties/wwproject:Property" />
         <xsl:with-param name="ParamStyleName" select="$VarRelatedTopicsTitleStyleName" />
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
       <!-- Set some suitable defaults -->
       <!--                            -->
       <xsl:attribute name="font-weight">bold</xsl:attribute>
      </xsl:otherwise>
     </xsl:choose>

     <xsl:value-of select="$GlobalLocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'RelatedTopics']/@value" />
    </fo:block>

    <xsl:for-each select="$VarRelatedTopicParagraphs">
     <xsl:variable name="VarRelatedTopicParagraph" select="." />

     <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $VarRelatedTopicParagraph/@stylename, $ParamSplit/@documentID, $VarRelatedTopicParagraph/@id)" />
     <xsl:variable name="VarParagraphBehavior" select="$ParamCargo/wwbehaviors:Behaviors[1]" />

     <fo:block start-indent="12pt">
      <xsl:call-template name="Paragraph-Normal">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamTOCData" select="$GlobalProject/wwstring:*" />
       <xsl:with-param name="ParamParagraph" select="$VarRelatedTopicParagraph" />
       <xsl:with-param name="ParamStyleName" select="$VarRelatedTopicParagraph/@stylename" />
       <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
       <xsl:with-param name="ParamParagraphBehavior" select="$VarParagraphBehavior" />
      </xsl:call-template>
     </fo:block>
    </xsl:for-each>
   </fo:block>
  </xsl:if>
 </xsl:template>


 <!-- wwmode:related-topics-paragraphs -->
 <!--                                  -->

 <xsl:template match="/" mode="wwmode:related-topics-paragraphs">
  <xsl:param name="ParamCargo" />

  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:related-topics-paragraphs">
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:Paragraph" mode="wwmode:related-topics-paragraphs">
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamParagraph" select="." />

  <!-- Related topic paragraph? -->
  <!--                          -->
  <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
   <xsl:variable name="VarParagraphBehavior" select="key('wwbehaviors-paragraphs-by-id', $ParamParagraph/@id)[1]" />

   <!-- Defines a related topic -->
   <!--                         -->
   <xsl:if test="($VarParagraphBehavior/@relatedtopic = 'define') or ($VarParagraphBehavior/@relatedtopic = 'define-no-output')">
    <!-- Paragraph has link? -->
    <!--                     -->
    <xsl:variable name="VarChildLinks" select="$ParamParagraph//wwdoc:Link[count($ParamParagraph | ancestor::wwdoc:Paragraph[1]) = 1]" />
    <xsl:variable name="VarChildLinksCount" select="count($VarChildLinks)" />
    <xsl:if test="$VarChildLinksCount &gt; 0">
     <!-- Preserve paragraph with different ID -->
     <!--                                      -->
     <xsl:apply-templates select="$ParamParagraph" mode="wwmode:related-topics-qualify-id">
      <xsl:with-param name="ParamIDPrefix" select="'rt_'" />
     </xsl:apply-templates>
    </xsl:if>
   </xsl:if>
  </xsl:for-each>
 </xsl:template>

 <xsl:template match="*" mode="wwmode:related-topics-paragraphs">
  <xsl:param name="ParamCargo" />

  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:related-topics-paragraphs">
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:related-topics-paragraphs">
  <xsl:param name="ParamCargo" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


 <!-- wwmode:related-topics-qualify-id -->
 <!--                                  -->

 <xsl:template match="/" mode="wwmode:related-topics-qualify-id">
  <xsl:param name="ParamIDPrefix" />

  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:related-topics-qualify-id">
   <xsl:with-param name="ParamIDPrefix" select="$ParamIDPrefix" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="*" mode="wwmode:related-topics-qualify-id">
  <xsl:param name="ParamIDPrefix" />

  <!-- Preserve element with new ID -->
  <!--                              -->
  <xsl:copy>
   <xsl:attribute name="id">
    <xsl:value-of select="$ParamIDPrefix" />
    <xsl:value-of select="@id" />
   </xsl:attribute>
   <xsl:copy-of select="@*[local-name() != 'id']" />

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:related-topics-qualify-id">
    <xsl:with-param name="ParamIDPrefix" select="$ParamIDPrefix" />
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:related-topics-qualify-id">
  <xsl:param name="ParamIDPrefix" />

  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>

 <xsl:template name="EliminateDuplicateRelatedTopicParagraphs">
  <xsl:param name="ParamRelatedTopicParagraphs" />

  <xsl:for-each select="$ParamRelatedTopicParagraphs">
   <xsl:variable name="VarRelatedTopicParagraph" select="." />

   <xsl:variable name="VarParagraphLinks" select="$VarRelatedTopicParagraph//wwdoc:Link" />
   <xsl:variable name="VarLink" select="$VarParagraphLinks[1]" />
   <xsl:variable name="VarMatchingLinks" select="key('wwlinks-by-anchor', $VarLink/@anchor)" />

   <!-- Preserve paragraph if it is the first unique link -->
   <!--                                                   -->
   <xsl:if test="count($VarLink | $VarMatchingLinks[1]) = 1">
    <xsl:copy-of select="$VarRelatedTopicParagraph" />
   </xsl:if>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Content-Notes">
  <xsl:param name="ParamNotes" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:if test="count($ParamNotes[1]) = 1">
   <fo:block width="100%"><fo:leader leader-pattern="rule" /></fo:block>
   <xsl:for-each select="$ParamNotes">
    <xsl:variable name="VarNote" select="." />

    <xsl:variable name="VarNoteNumber" select="$ParamCargo/wwnotes:NoteNumbering/wwnotes:Note[@id = $VarNote/@id]/@number" />

    <xsl:if test="string-length($VarNoteNumber) &gt; 0">

     <fo:block>
      <xsl:variable name="VarParagraph" select="$VarNote/wwdoc:Paragraph[1]" />
      <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $VarParagraph/@stylename, $ParamSplit/@documentID, $VarParagraph/@id)" />

      <!-- Resolve project properties -->
      <!--                            -->
      <xsl:variable name="VarResolvedContextPropertiesAsXML">
       <xsl:call-template name="Properties-ResolveContextRule">
        <xsl:with-param name="ParamDocumentContext" select="$VarParagraph" />
        <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
        <xsl:with-param name="ParamStyleName" select="$VarParagraph/@stylename" />
        <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
        <xsl:with-param name="ParamContextStyle" select="$VarParagraph/wwdoc:Style" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

      <!-- FO properties -->
      <!--               -->
      <xsl:variable name="VarFOPropertiesAsXML">
       <xsl:call-template name="FO-TranslateProjectProperties">
        <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
        <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarFOProperties" select="msxsl:node-set($VarFOPropertiesAsXML)/wwproject:Property" />

      <!-- Emit formatting attributes -->
      <!--                            -->
      <xsl:for-each select="$VarFOProperties">
       <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
      </xsl:for-each>

      <fo:inline font-size="8pt" baseline-shift="super">
       <fo:basic-link id="w{$ParamSplit/@groupID}_{$ParamSplit/@documentID}_{$VarNote/@id}">
        <xsl:attribute name="internal-destination">
         <xsl:text>wwfootnote_inline_</xsl:text>
         <xsl:value-of select="$ParamSplit/@groupID" />
         <xsl:text>_</xsl:text>
         <xsl:value-of select="$ParamSplit/@documentID" />
         <xsl:text>_</xsl:text>
         <xsl:value-of select="$VarNote/@id" />
        </xsl:attribute>

        <xsl:value-of select="$VarNoteNumber"/>
        <xsl:text>)&#xA0;</xsl:text>
       </fo:basic-link>
      </fo:inline>

      <xsl:call-template name="ParagraphTextRuns">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamPreserveEmpty" select="false()" />
       <xsl:with-param name="ParamUseCharacterStyles" select="true()" />
       <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
      </xsl:call-template>
     </fo:block>
    </xsl:if>
   </xsl:for-each>
  </xsl:if>
 </xsl:template>


 <xsl:template name="Content-Bullet">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamCharacter" />
  <xsl:param name="ParamImage" />
  <xsl:param name="ParamSeparator" />
  <xsl:param name="ParamStyle" />

  <xsl:choose>
   <xsl:when test="string-length($ParamStyle) &gt; 0">

    <!-- Get rule -->
    <!--          -->
    <xsl:variable name="VarRule" select="wwprojext:GetRule('Character', $ParamStyle)" />

    <!-- Resolve project properties -->
    <!--                            -->
    <xsl:variable name="VarResolvedContextPropertiesAsXML">
     <xsl:call-template name="Properties-ResolveContextRule">
      <xsl:with-param name="ParamDocumentContext" select="$ParamParagraph" />
      <xsl:with-param name="ParamProperties" select="$VarRule/wwproject:Properties/wwproject:Property" />
      <xsl:with-param name="ParamStyleName" select="$ParamStyle" />
      <xsl:with-param name="ParamStyleType" select="'Character'" />
      <xsl:with-param name="ParamContextStyle" select="$ParamParagraph/wwdoc:Number[1]/wwdoc:Style" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

    <!-- FO properties -->
    <!--               -->
    <xsl:variable name="VarFOPropertiesAsXML">
     <xsl:call-template name="FO-TranslateProjectProperties">
      <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
      <xsl:with-param name="ParamStyleType" select="'Character'" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarFOProperties" select="msxsl:node-set($VarFOPropertiesAsXML)/wwproject:Property" />

    <fo:inline>
     <xsl:for-each select="$VarFOProperties">
      <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
     </xsl:for-each>

     <!-- Insert image? -->
     <!--               -->
     <xsl:if test="string-length($ParamImage) &gt; 0">
      <!-- Get absolute path for imaging info -->
      <!--                                    -->
      <xsl:variable name="VarImageFileSystemPath" select="wwfilesystem:Combine(wwprojext:GetProjectFilesDirectoryPath(), $ParamImage)" />
      <xsl:variable name="VarImageInfo" select="wwimaging:GetInfo($VarImageFileSystemPath)" />

      <xsl:variable name="VarImagePath">
	  <xsl:text>url('</xsl:text>
       <xsl:call-template name="FO-ResolveProjectFileURI">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamURI" select="$ParamImage" />
       </xsl:call-template>
	  <xsl:text>')</xsl:text>
      </xsl:variable>

      <!-- Image -->
      <!--       -->
      <fo:external-graphic src="{$VarImagePath}" content-height="{$VarImageInfo/@height}px" vertical-align="baseline" />
     </xsl:if>

     <!-- Characters -->
     <!--            -->
     <xsl:value-of select="$ParamCharacter" />

     <!-- Separator -->
     <!--           -->
     <xsl:value-of select="$ParamSeparator" />
    </fo:inline>
   </xsl:when>

   <xsl:otherwise>
    <xsl:if test="string-length($ParamImage) &gt; 0">
     <!-- Get absolute path for imaging info -->
     <!--                                    -->
     <xsl:variable name="VarImageFileSystemPath" select="wwfilesystem:Combine(wwprojext:GetProjectFilesDirectoryPath(), $ParamImage)" />
     <xsl:variable name="VarImageInfo" select="wwimaging:GetInfo($VarImageFileSystemPath)" />

     <xsl:variable name="VarImagePath">
      <xsl:text>url('</xsl:text>
      <xsl:call-template name="FO-ResolveProjectFileURI">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamURI" select="$ParamImage" />
      </xsl:call-template>
      <xsl:text>')</xsl:text>
     </xsl:variable>

     <!-- Image -->
     <!--       -->
     <fo:external-graphic src="{$VarImagePath}" content-height="{$VarImageInfo/@height}px" vertical-align="baseline" />
    </xsl:if>

    <!-- Characters -->
    <!--            -->
    <xsl:value-of select="$ParamCharacter" />

    <!-- Separator -->
    <!--           -->
    <xsl:value-of select="$ParamSeparator" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="Notes-Number">
  <xsl:param name="ParamNotes" />

  <wwnotes:NoteNumbering version="1.0">
   <xsl:for-each select="$ParamNotes">
    <xsl:variable name="VarNote" select="." />

    <wwnotes:Note id="{$VarNote/@id}" number="{position()}" />
   </xsl:for-each>
  </wwnotes:NoteNumbering>
 </xsl:template>


 <xsl:template name="MiniTOC">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamTOCEntry" />
  <xsl:param name="ParamEmitTOCEntry" />
  <xsl:param name="ParamMiniTOCSubLevels" />

  <xsl:if test="($ParamEmitTOCEntry = true()) or (count($ParamTOCEntry/wwtoc:Entry[1]) = 1)">
   <!-- MiniTOC container style rule -->
   <!--                              -->
   <xsl:variable name="VarMiniTOCContainerStyleName" select="wwprojext:GetFormatSetting('minitoc-container-style')" />

   <fo:block>
    <xsl:choose>
     <xsl:when test="string-length($VarMiniTOCContainerStyleName) &gt; 0">
      <xsl:variable name="VarMiniTOCContainerStyleRule" select="wwprojext:GetRule('Paragraph', $VarMiniTOCContainerStyleName)" />

      <xsl:variable name="VarResolvedRulePropertiesAsXML">
       <xsl:call-template name="Properties-ResolveRule">
        <xsl:with-param name="ParamDocumentContext" select="$ParamSplit/wwsplits:NoContext" />
        <xsl:with-param name="ParamProperties" select="$VarMiniTOCContainerStyleRule/wwproject:Properties/wwproject:Property" />
        <xsl:with-param name="ParamStyleName" select="$VarMiniTOCContainerStyleName" />
        <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResolvedRuleProperties" select="msxsl:node-set($VarResolvedRulePropertiesAsXML)/wwproject:Property" />

      <!-- FO properties -->
      <!--               -->
      <xsl:variable name="VarContainerPropertiesAsXML">
       <xsl:call-template name="FO-TranslateProjectProperties">
        <xsl:with-param name="ParamProperties" select="$VarResolvedRuleProperties" />
        <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarContainerProperties" select="msxsl:node-set($VarContainerPropertiesAsXML)/wwproject:Property" />

      <xsl:for-each select="$VarContainerProperties">
       <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
      </xsl:for-each>
     </xsl:when>

     <xsl:otherwise>
      <!-- Suitable defaults -->
      <!--                   -->
      <xsl:attribute name="background-color">#EEEEEE</xsl:attribute>
      <xsl:attribute name="border-color">#000000</xsl:attribute>
      <xsl:attribute name="border-width">1px</xsl:attribute>
      <xsl:attribute name="border-style">solid</xsl:attribute>
      <xsl:attribute name="padding">1px</xsl:attribute>
      <xsl:attribute name="font-family">sans-serif</xsl:attribute>
     </xsl:otherwise>
    </xsl:choose>

    <!-- MiniTOC Style Rule -->
    <!--                    -->
    <xsl:variable name="VarMiniTOCStyleName" select="wwprojext:GetFormatSetting('minitoc-style')" />
    <xsl:variable name="VarMiniTOCStyleRule" select="wwprojext:GetRule('Paragraph', $VarMiniTOCStyleName)" />

    <xsl:variable name="VarResolvedRulePropertiesAsXML">
     <xsl:call-template name="Properties-ResolveRule">
      <xsl:with-param name="ParamDocumentContext" select="$ParamSplit/wwsplits:NoContext" />
      <xsl:with-param name="ParamProperties" select="$VarMiniTOCStyleRule/wwproject:Properties/wwproject:Property" />
      <xsl:with-param name="ParamStyleName" select="$VarMiniTOCStyleName" />
      <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarResolvedRuleProperties" select="msxsl:node-set($VarResolvedRulePropertiesAsXML)/wwproject:Property" />

    <!-- FO properties -->
    <!--               -->
    <xsl:variable name="VarStylePropertiesAsXML">
     <xsl:call-template name="FO-TranslateProjectProperties">
      <xsl:with-param name="ParamProperties" select="$VarResolvedRuleProperties" />
      <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarStyleProperties" select="msxsl:node-set($VarStylePropertiesAsXML)/wwproject:Property" />

    <!-- Emit top-level entry? -->
    <!--                       -->
    <xsl:choose>
     <xsl:when test="$ParamEmitTOCEntry = true()">
       <!-- Paragraph -->
       <!--           -->
       <xsl:call-template name="MiniTOCParagraph">
        <xsl:with-param name="ParamParagraph" select="$ParamTOCEntry/wwdoc:Paragraph" />
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$ParamCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamMiniTOCStyleName" select="$VarMiniTOCStyleName" />
        <xsl:with-param name="ParamLevel" select="1" />
       </xsl:call-template>

      <!-- Children -->
      <!--          -->
      <xsl:call-template name="MiniTOCEntries">
       <xsl:with-param name="ParamReferencePath" select="$ParamSplit/@path" />
       <xsl:with-param name="ParamParent" select="$ParamTOCEntry" />
       <xsl:with-param name="ParamMiniTOCSubLevels" select="$ParamMiniTOCSubLevels" />
       <xsl:with-param name="ParamLevel" select="2" />
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamStyleProperties" select="$VarStyleProperties" />
       <xsl:with-param name="ParamMiniTOCStyleName" select="$VarMiniTOCStyleName" />
      </xsl:call-template>
     </xsl:when>

     <xsl:otherwise>
      <!-- Children -->
      <!--          -->
      <xsl:call-template name="MiniTOCEntries">
       <xsl:with-param name="ParamReferencePath" select="$ParamSplit/@path" />
       <xsl:with-param name="ParamParent" select="$ParamTOCEntry" />
       <xsl:with-param name="ParamMiniTOCSubLevels" select="$ParamMiniTOCSubLevels" />
       <xsl:with-param name="ParamLevel" select="1" />
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamStyleProperties" select="$VarStyleProperties" />
       <xsl:with-param name="ParamMiniTOCStyleName" select="$VarMiniTOCStyleName" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </fo:block>
  </xsl:if>
 </xsl:template>

 <xsl:template name="MiniTOCEntries">
  <xsl:param name="ParamReferencePath" />
  <xsl:param name="ParamParent" />
  <xsl:param name="ParamMiniTOCSubLevels" />
  <xsl:param name="ParamLevel" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamStyleProperties" />
  <xsl:param name="ParamMiniTOCStyleName" />

  <xsl:variable name="VarSubEntries" select="$ParamParent/wwtoc:Entry" />

  <xsl:for-each select="$VarSubEntries[1]">
   <xsl:for-each select="$VarSubEntries">
    <xsl:variable name="VarEntry" select="." />

     <xsl:call-template name="MiniTOCParagraph">
      <xsl:with-param name="ParamParagraph" select="$VarEntry/wwdoc:Paragraph" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamEntry" select="$VarEntry" />
      <xsl:with-param name="ParamMiniTOCStyleName" select="$ParamMiniTOCStyleName" />
      <xsl:with-param name="ParamLevel" select="$ParamLevel" />
     </xsl:call-template>

    <!-- Recurse -->
    <!--         -->
    <xsl:choose>
     <xsl:when test="$ParamMiniTOCSubLevels = 'all'">
      <xsl:call-template name="MiniTOCEntries">
       <xsl:with-param name="ParamReferencePath" select="$ParamReferencePath" />
       <xsl:with-param name="ParamParent" select="$VarEntry" />
       <xsl:with-param name="ParamMiniTOCSubLevels" select="$ParamMiniTOCSubLevels" />
       <xsl:with-param name="ParamLevel" select="$ParamLevel + 1" />
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamStyleProperties" select="$ParamStyleProperties" />
       <xsl:with-param name="ParamMiniTOCStyleName" select="$ParamMiniTOCStyleName" />
      </xsl:call-template>
     </xsl:when>

     <xsl:when test="($ParamMiniTOCSubLevels - 1) &gt; 0">
      <xsl:call-template name="MiniTOCEntries">
       <xsl:with-param name="ParamReferencePath" select="$ParamReferencePath" />
       <xsl:with-param name="ParamParent" select="$VarEntry" />
       <xsl:with-param name="ParamMiniTOCSubLevels" select="$ParamMiniTOCSubLevels - 1" />
       <xsl:with-param name="ParamLevel" select="$ParamLevel + 1" />
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamStyleProperties" select="$ParamStyleProperties" />
       <xsl:with-param name="ParamMiniTOCStyleName" select="$ParamMiniTOCStyleName" />
      </xsl:call-template>
     </xsl:when>
    </xsl:choose>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>

 <xsl:template name="MiniTOCParagraph">
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamEntry" />
  <xsl:param name="ParamMiniTOCStyleName" />
  <xsl:param name="ParamLevel" />

  <xsl:variable name="VarMiniTOCLevelIndentAsPoints" select="number($ParamLevel) * 12" />
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamMiniTOCStyleName, $ParamSplit/@documentID, $ParamParagraph/@id)" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedContextPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveContextRule">
    <xsl:with-param name="ParamDocumentContext" select="$ParamParagraph" />
    <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamStyleName" select="$ParamMiniTOCStyleName" />
    <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
    <xsl:with-param name="ParamContextStyle" select="$ParamParagraph/wwdoc:Style" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

  <!-- FO properties -->
  <!--               -->
  <xsl:variable name="VarFOPropertiesAsXML">
   <xsl:call-template name="FO-TranslateProjectProperties">
    <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
    <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarFOProperties" select="msxsl:node-set($VarFOPropertiesAsXML)/wwproject:Property" />

  <!-- Use numbering? -->
  <!--                -->
  <xsl:variable name="VarUseNumberingOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'use-numbering']/@Value" />
  <xsl:variable name="VarUseNumbering" select="(string-length($VarUseNumberingOption) = 0) or ($VarUseNumberingOption = 'true')" />

  <!-- Text Indent -->
  <!--             -->
  <xsl:variable name="VarTextIndent">
   <xsl:variable name="VarTextIndentRaw">
    <xsl:if test="$VarUseNumbering">
     <xsl:value-of select="$VarResolvedContextProperties[@Name = 'text-indent']/@Value" />
    </xsl:if>
   </xsl:variable>
   <xsl:call-template name="Property-Normalize">
    <xsl:with-param name="ParamProperty" select="$VarTextIndentRaw"/>
    <xsl:with-param name="ParamDefault" select="'0pt'"/>
   </xsl:call-template>
  </xsl:variable>  

  <xsl:variable name="VarTextIndentNumericPrefix" select="wwunits:NumericPrefix($VarTextIndent)" />
  <xsl:variable name="VarTextIndentLessThanZero" select="(string-length($VarTextIndentNumericPrefix) &gt; 0) and (number($VarTextIndentNumericPrefix) &lt; 0)" />

  <!-- Use bullet from UI? -->
  <!--                     -->
  <xsl:variable name="VarBulletCharacter" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-character']/@Value" />
  <xsl:variable name="VarBulletImage" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-image']/@Value" />
  <xsl:variable name="VarBulletSeparator" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-separator']/@Value" />
  <xsl:variable name="VarBulletStyle" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-style']/@Value" />
  <xsl:variable name="VarIgnoreDocumentNumber" select="(string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0)" />

  <!-- Is numbered paragraph -->
  <!--                       -->
  <xsl:variable name="VarIsNumberedParagraph" select="($VarTextIndentLessThanZero = true()) and ((count($ParamParagraph/wwdoc:Number[1]) = 1) or (string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0))" />

  <!-- Tag -->
  <!--     -->
  <xsl:variable name="VarTag">
   <xsl:choose>
    <xsl:when test="$VarIsNumberedParagraph = true()">
     <xsl:value-of select="'list-block'" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="'block'" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Use character styles? -->
  <!--                       -->
  <xsl:variable name="VarUseCharacterStylesOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'use-character-styles']/@Value" />
  <xsl:variable name="VarUseCharacterStyles" select="(string-length($VarUseCharacterStylesOption) = 0) or ($VarUseCharacterStylesOption = 'true')" />

  <!-- Preserve empty? -->
  <!--                 -->
  <xsl:variable name="VarPreserveEmptyOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'preserve-empty']/@Value" />
  <xsl:variable name="VarPreserveEmpty" select="(string-length($VarPreserveEmptyOption) = 0) or ($VarPreserveEmptyOption = 'true')" />

  <!-- Begin paragraph emit -->
  <!--                      -->
  <xsl:element name="{$VarTag}" namespace="{$GlobalDefaultNamespace}">

   <xsl:for-each select="$VarFOProperties[@Name != 'margin-left' and @Name != 'text-indent']">
    <xsl:attribute name="{@Name}">
     <xsl:value-of select="@Value" />
    </xsl:attribute>
   </xsl:for-each>

   <!-- Emit margin-left and text-indent for non-numbered paragraphs -->
   <!--                                                              -->
   <xsl:if test="not($VarIsNumberedParagraph)">
    <xsl:for-each select="$VarFOProperties[@Name = 'margin-left' or @Name = 'text-indent']">
     <xsl:attribute name="{@Name}">
      <xsl:choose>
       <xsl:when test="@Name = 'margin-left'">

        <xsl:variable name="VarMarginLeft">
         <xsl:call-template name="Property-Normalize">
          <xsl:with-param name="ParamProperty" select="@Value"/>
          <xsl:with-param name="ParamDefault" select="'0pt'"/>
         </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="VarMarginLeftNumberAsUnits" select="wwunits:NumericPrefix($VarMarginLeft)" />
        <xsl:variable name="VarMarginLeftUnits" select="wwunits:UnitsSuffix($VarMarginLeft)" />
        <xsl:variable name="VarMarginLeftAsPoints" select="wwunits:Convert($VarMarginLeftNumberAsUnits, $VarMarginLeftUnits, 'pt')" />
        <xsl:variable name="VarResolvedMarginLeftAsPoints" select="$VarMarginLeftAsPoints + $VarMiniTOCLevelIndentAsPoints" />
        <xsl:variable name="VarStartIndentNumber" select="wwunits:Convert($VarResolvedMarginLeftAsPoints, 'pt', $VarMarginLeftUnits)" />

        <xsl:value-of select="$VarStartIndentNumber" />
        <xsl:value-of select="$VarMarginLeftUnits" />

       </xsl:when>
       <xsl:otherwise>
        <xsl:value-of select="@Value" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:attribute>
    </xsl:for-each>
   </xsl:if>

   <xsl:variable name="VarTextIndentNumberAsUnits" select="wwunits:NumericPrefix($VarTextIndent)" />
   <xsl:variable name="VarTextIndentUnits" select="wwunits:UnitsSuffix($VarTextIndent)" />


   <xsl:if test="$VarTag = 'list-block'">
    <xsl:attribute name="provisional-label-separation">
     <xsl:text>0.25in</xsl:text>
    </xsl:attribute>

    <xsl:attribute name="provisional-distance-between-starts">
     <xsl:value-of select="round(0 - $VarTextIndentNumberAsUnits)" />
     <xsl:value-of select="$VarTextIndentUnits" />
    </xsl:attribute>
   </xsl:if>

   <!-- Use numbering? -->
   <!--                -->
   <xsl:choose>
    <!-- Use Number -->
    <!--            -->
    <xsl:when test="$VarUseNumbering">
     <xsl:choose>
      <xsl:when test="(count($ParamParagraph/wwdoc:Number[1]) &gt; 0) or (string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0)">
       <xsl:choose>
        <xsl:when test="$VarTextIndentLessThanZero">

         <xsl:variable name="VarMarginLeft">
          <xsl:call-template name="Property-Normalize">
           <xsl:with-param name="ParamProperty" select="$VarResolvedContextProperties[@Name = 'margin-left']/@Value"/>
           <xsl:with-param name="ParamDefault" select="'0pt'"/>
          </xsl:call-template>
         </xsl:variable>
         <xsl:variable name="VarMarginLeftNumberAsUnits" select="wwunits:NumericPrefix($VarMarginLeft)" />
         <xsl:variable name="VarMarginLeftUnits" select="wwunits:UnitsSuffix($VarMarginLeft)" />
         <xsl:variable name="VarTextIndentAsPoints" select="wwunits:Convert($VarTextIndentNumberAsUnits, $VarTextIndentUnits, 'pt')" />
         <xsl:variable name="VarMarginLeftAsPoints" select="wwunits:Convert($VarMarginLeftNumberAsUnits, $VarMarginLeftUnits, 'pt')" />

         <xsl:variable name="VarResolvedTextIndent" select="$VarMarginLeftAsPoints + $VarTextIndentAsPoints + $VarMiniTOCLevelIndentAsPoints" />

         <xsl:variable name="VarStartIndentNumber" select="wwunits:Convert($VarResolvedTextIndent, 'pt', $VarTextIndentUnits)" />

         <!-- Emit margin-left -->
         <!--                  -->
         <xsl:attribute name="margin-left">
          <xsl:value-of select="$VarStartIndentNumber" />
          <xsl:value-of select="$VarTextIndentUnits" />
         </xsl:attribute>

         <fo:list-item relative-align="baseline">
          <fo:list-item-label start-indent="{$VarStartIndentNumber}{$VarTextIndentUnits}">
           <!-- end-indent -->
           <!--            -->
           <xsl:attribute name="end-indent">
            <xsl:value-of select="round(0 - $VarTextIndentNumberAsUnits)" />
            <xsl:value-of select="$VarTextIndentUnits" />
           </xsl:attribute>

           <fo:block>
            <!-- Do formatting for number portion -->
            <!--                                  -->
            <xsl:call-template name="MiniTOCParagraphNumber">
             <xsl:with-param name="ParamSplits" select="$ParamSplits" />
             <xsl:with-param name="ParamCargo" select="$ParamCargo" />
             <xsl:with-param name="ParamLinks" select="$ParamLinks" />
             <xsl:with-param name="ParamSplit" select="$ParamSplit" />
             <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
             <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
             <xsl:with-param name="ParamIgnoreDocumentNumber" select="$VarIgnoreDocumentNumber" />
             <xsl:with-param name="ParamCharacter" select="$VarBulletCharacter" />
             <xsl:with-param name="ParamImage" select="$VarBulletImage" />
             <xsl:with-param name="ParamSeparator" select="$VarBulletSeparator" />
             <xsl:with-param name="ParamStyle" select="$VarBulletStyle" />
             <xsl:with-param name="ParamEntry" select="$ParamEntry" />
            </xsl:call-template>
           </fo:block>
          </fo:list-item-label>

          <!-- Text Runs -->
          <!--           -->
          <fo:list-item-body start-indent="body-start()">
           <fo:block>
            <xsl:call-template name="MiniTOCParagraphText">
             <xsl:with-param name="ParamSplits" select="$ParamSplits" />
             <xsl:with-param name="ParamCargo" select="$ParamCargo" />
             <xsl:with-param name="ParamLinks" select="$ParamLinks" />
             <xsl:with-param name="ParamSplit" select="$ParamSplit" />
             <xsl:with-param name="ParamPreserveEmpty" select="$VarPreserveEmpty" />
             <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
             <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
             <xsl:with-param name="ParamEntry" select="$ParamEntry" />
            </xsl:call-template>
           </fo:block>
          </fo:list-item-body>
         </fo:list-item>
        </xsl:when>

        <xsl:otherwise>
         <!-- Number -->
         <!--        -->
         <xsl:call-template name="MiniTOCParagraphNumber">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamCargo" select="$ParamCargo" />
          <xsl:with-param name="ParamLinks" select="$ParamLinks" />
          <xsl:with-param name="ParamSplit" select="$ParamSplit" />
          <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
          <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
          <xsl:with-param name="ParamIgnoreDocumentNumber" select="$VarIgnoreDocumentNumber" />
          <xsl:with-param name="ParamCharacter" select="$VarBulletCharacter" />
          <xsl:with-param name="ParamImage" select="$VarBulletImage" />
          <xsl:with-param name="ParamSeparator" select="$VarBulletSeparator" />
          <xsl:with-param name="ParamStyle" select="$VarBulletStyle" />
          <xsl:with-param name="ParamEntry" select="$ParamEntry" />
         </xsl:call-template>

         <!-- Text Runs -->
         <!--           -->
         <xsl:call-template name="MiniTOCParagraphText">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamCargo" select="$ParamCargo" />
          <xsl:with-param name="ParamLinks" select="$ParamLinks" />
          <xsl:with-param name="ParamSplit" select="$ParamSplit" />
          <xsl:with-param name="ParamPreserveEmpty" select="$VarPreserveEmpty" />
          <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
          <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
          <xsl:with-param name="ParamEntry" select="$ParamEntry" />
         </xsl:call-template>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
       <!-- Text Runs -->
       <!--           -->
       <xsl:call-template name="MiniTOCParagraphText">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$ParamCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamPreserveEmpty" select="$VarPreserveEmpty" />
        <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
        <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
        <xsl:with-param name="ParamEntry" select="$ParamEntry" />
       </xsl:call-template>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:when>

    <!-- Skip Number -->
    <!--             -->
    <xsl:otherwise>
     <!-- Text Runs -->
     <!--           -->
     <xsl:call-template name="MiniTOCParagraphText">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamPreserveEmpty" select="$VarPreserveEmpty" />
      <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
      <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
      <xsl:with-param name="ParamEntry" select="$ParamEntry" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>

   <!-- End paragraph emit -->
   <!--                    -->
  </xsl:element>
 </xsl:template>

 <xsl:template name="MiniTOCParagraphNumber">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamUseCharacterStyles" />
  <xsl:param name="ParamIgnoreDocumentNumber" />
  <xsl:param name="ParamCharacter" />
  <xsl:param name="ParamImage" />
  <xsl:param name="ParamSeparator" />
  <xsl:param name="ParamStyle" />
  <xsl:param name="ParamEntry" />

  <xsl:choose>
   <xsl:when test="string-length($ParamEntry/@path) &gt; 0">
    <!-- Link -->
    <!--      -->
    <fo:basic-link internal-destination="w{$ParamSplit/@groupID}_{$ParamSplit/@documentID}_{$ParamEntry/@linkid}">
     <xsl:call-template name="Number">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
      <xsl:with-param name="ParamUseCharacterStyles" select="$ParamUseCharacterStyles" />
      <xsl:with-param name="ParamIgnoreDocumentNumber" select="$ParamIgnoreDocumentNumber" />
      <xsl:with-param name="ParamCharacter" select="$ParamCharacter" />
      <xsl:with-param name="ParamImage" select="$ParamImage" />
      <xsl:with-param name="ParamSeparator" select="$ParamSeparator" />
      <xsl:with-param name="ParamStyle" select="$ParamStyle" />
     </xsl:call-template>
    </fo:basic-link>
   </xsl:when>

   <xsl:otherwise>
    <xsl:call-template name="Number">
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$ParamCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     <xsl:with-param name="ParamUseCharacterStyles" select="$ParamUseCharacterStyles" />
     <xsl:with-param name="ParamIgnoreDocumentNumber" select="$ParamIgnoreDocumentNumber" />
     <xsl:with-param name="ParamCharacter" select="$ParamCharacter" />
     <xsl:with-param name="ParamImage" select="$ParamImage" />
     <xsl:with-param name="ParamSeparator" select="$ParamSeparator" />
     <xsl:with-param name="ParamStyle" select="$ParamStyle" />
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="MiniTOCParagraphText">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamPreserveEmpty" />
  <xsl:param name="ParamUseCharacterStyles" />
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamEntry" />

  <xsl:choose>
   <xsl:when test="string-length($ParamEntry/@path) &gt; 0">
    <!-- Link -->
    <!--      -->
    <fo:basic-link internal-destination="w{$ParamSplit/@groupID}_{$ParamSplit/@documentID}_{$ParamEntry/@linkid}">
     <xsl:call-template name="ParagraphTextRuns">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamPreserveEmpty" select="$ParamPreserveEmpty" />
      <xsl:with-param name="ParamUseCharacterStyles" select="$ParamUseCharacterStyles" />
      <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     </xsl:call-template>
    </fo:basic-link>
   </xsl:when>

   <xsl:otherwise>
    <xsl:call-template name="ParagraphTextRuns">
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$ParamCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamPreserveEmpty" select="$ParamPreserveEmpty" />
     <xsl:with-param name="ParamUseCharacterStyles" select="$ParamUseCharacterStyles" />
     <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template match="wwdoc:List" mode="wwmode:content">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarList" select="." />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarList/@stylename, $ParamSplit/@documentID, $VarList/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">
    <!-- Related Topic Only or Popup Only? -->
    <!--                                   -->
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
     <xsl:variable name="VarListBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarList/@id)[1]" />
     <xsl:variable name="VarInPopupPage" select="count($ParamCargo/wwbehaviors:PopupPage) &gt; 0" />
     <xsl:variable name="VarPopupOnly" select="($VarListBehavior/@popup = 'define-no-output') or ($VarListBehavior/@popup = 'append-no-output')" />
     <xsl:variable name="VarRelatedTopicOnly" select="$VarListBehavior/@relatedtopic = 'define-no-output'" />

     <xsl:if test="$VarInPopupPage or (not($VarPopupOnly) and not($VarRelatedTopicOnly))">
      <!-- List -->
      <!--      -->
      <xsl:call-template name="List">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamList" select="$VarList" />
       <xsl:with-param name="ParamStyleName" select="$VarList/@stylename" />
       <xsl:with-param name="ParamOverrideRule" select="$VarOverrideRule" />
       <xsl:with-param name="ParamListBehavior" select="$VarListBehavior" />
      </xsl:call-template>
     </xsl:if>
    </xsl:for-each>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:List" mode="wwmode:nestedcontent">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:apply-templates select="." mode="wwmode:content">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template name="List">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamList" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamOverrideRule" />
  <xsl:param name="ParamListBehavior" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveOverrideRule">
    <xsl:with-param name="ParamProperties" select="$ParamOverrideRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamContextStyle" select="$ParamList/wwdoc:Style" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamList/@stylename, $ParamSplit/@documentID, $ParamList/@id)" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedContextPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveContextRule">
    <xsl:with-param name="ParamDocumentContext" select="$ParamList" />
    <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamStyleName" select="$ParamList/@stylename" />
    <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
    <xsl:with-param name="ParamContextStyle" select="$ParamList/wwdoc:Style" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

  <xsl:variable name="VarIsOrdered" select="$ParamList/@ordered = 'True'" />

  <!-- Begin list emit -->
  <!--                 -->
  <fo:list-block>
   <!-- ID -->
   <!--    -->
   <xsl:attribute name="id">
    <xsl:text>w</xsl:text>
    <xsl:value-of select="$ParamSplit/@groupID" />
    <xsl:text>_</xsl:text>
    <xsl:value-of select="$ParamSplit/@documentID" />
    <xsl:text>_</xsl:text>
    <xsl:value-of select="$ParamList/@id" />
   </xsl:attribute>

   <!-- FO properties -->
   <!--               -->
   <xsl:variable name="VarFOPropertiesAsXML">
    <xsl:call-template name="FO-TranslateProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
     <xsl:with-param name="ParamStyleType" select="'List'" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarFOProperties" select="msxsl:node-set($VarFOPropertiesAsXML)/wwproject:Property" />

   <xsl:for-each select="$VarFOProperties">
    <xsl:attribute name="{@Name}">
     <xsl:value-of select="@Value" />
    </xsl:attribute>
   </xsl:for-each>

   <!-- Child Content -->
   <!--               -->
   <xsl:apply-templates select="$ParamList/*" mode="wwmode:nestedcontent">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:apply-templates>

   <!-- End list emit -->
   <!--               -->
  </fo:list-block>
 </xsl:template>


 <xsl:template match="wwdoc:ListItem" mode="wwmode:nestedcontent">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarListItem" select="." />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarListItem/@stylename, $ParamSplit/@documentID, $VarListItem/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">
    <!-- Related Topic Only or Popup Only? -->
    <!--                                   -->
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
     <xsl:variable name="VarListItemBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarListItem/@id)[1]" />
     <xsl:variable name="VarInPopupPage" select="count($ParamCargo/wwbehaviors:PopupPage) &gt; 0" />
     <xsl:variable name="VarPopupOnly" select="($VarListItemBehavior/@popup = 'define-no-output') or ($VarListItemBehavior/@popup = 'append-no-output')" />
     <xsl:variable name="VarRelatedTopicOnly" select="$VarListItemBehavior/@relatedtopic = 'define-no-output'" />

     <xsl:if test="$VarInPopupPage or (not($VarPopupOnly) and not($VarRelatedTopicOnly))">
      <!-- ListItem -->
      <!--          -->
      <xsl:call-template name="ListItem">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamListItem" select="$VarListItem" />
       <xsl:with-param name="ParamStyleName" select="$VarListItem/@stylename" />
       <xsl:with-param name="ParamOverrideRule" select="$VarOverrideRule" />
       <xsl:with-param name="ParamListItemBehavior" select="$VarListItemBehavior" />
      </xsl:call-template>
     </xsl:if>
    </xsl:for-each>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template name="ListItem">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamListItem" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamOverrideRule" />
  <xsl:param name="ParamListItemBehavior" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveOverrideRule">
    <xsl:with-param name="ParamProperties" select="$ParamOverrideRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamContextStyle" select="$ParamListItem/wwdoc:Style" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamListItem/@stylename, $ParamSplit/@documentID, $ParamListItem/@id)" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedContextPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveContextRule">
    <xsl:with-param name="ParamDocumentContext" select="$ParamListItem" />
    <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamStyleName" select="$ParamListItem/@stylename" />
    <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
    <xsl:with-param name="ParamContextStyle" select="$ParamListItem/wwdoc:Style" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

  <xsl:variable name="VarUseCharacterStylesOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'use-character-styles']/@Value" />
  <xsl:variable name="VarUseCharacterStyles" select="(string-length($VarUseCharacterStylesOption) = 0) or ($VarUseCharacterStylesOption = 'true')" />

  <!-- Use bullet from UI? -->
  <!--                     -->
  <xsl:variable name="VarBulletCharacter" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-character']/@Value" />
  <xsl:variable name="VarBulletImage" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-image']/@Value" />
  <xsl:variable name="VarBulletSeparator" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-separator']/@Value" />
  <xsl:variable name="VarBulletStyle" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-style']/@Value" />
  <xsl:variable name="VarIgnoreDocumentNumber" select="(string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0)" />

  <xsl:variable name="VarCharacter">
   <xsl:choose>
    <xsl:when test="$VarBulletCharacter != ''">
     <!-- Use Bullet Character from Style Designer if it's there -->
     <!--                                                        -->
     <xsl:value-of select="$VarBulletCharacter"/>
    </xsl:when>
    <xsl:when test="$ParamListItem/@ordered = 'True'">
     <!-- Build default numbering pattern -->
     <!--                                 -->
     <xsl:choose>
      <xsl:when test="$ParamListItem/@level mod 3 = 0">
       <!-- lower roman case -->
       <!--                  -->
       <xsl:number format="i" value="$ParamListItem/@number" /><xsl:text>.</xsl:text>
      </xsl:when>
      <xsl:when test="($ParamListItem/@level - 2) mod 3 = 0">
       <!-- lower alpha case -->
       <!--                  -->
       <xsl:number format="a" value="$ParamListItem/@number" /><xsl:text>.</xsl:text>
      </xsl:when>
      <xsl:otherwise>
       <!-- numeric case -->
       <!--              -->
       <xsl:number format="1" value="$ParamListItem/@number" /><xsl:text>.</xsl:text>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
     <!-- Write default bullet -->
     <!--                      -->
     <xsl:choose>
      <xsl:when test="$ParamListItem/@level mod 3 = 0">
       <!-- square case -->
       <!--             -->
       <xsl:text>&#9642;</xsl:text>
      </xsl:when>
      <xsl:when test="($ParamListItem/@level - 2) mod 3 = 0">
       <!-- open bullet case -->
       <!--                  -->
       <xsl:text>&#9702;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
       <!-- solid bullet case -->
       <!--                   -->
       <xsl:text>&#8226;</xsl:text>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>


  <xsl:variable name="VarSeparator">
   <xsl:choose>
    <xsl:when test="$VarBulletSeparator != ''">
     <xsl:value-of select="$VarBulletSeparator"/>
    </xsl:when>
    <xsl:otherwise>
     <xsl:text> </xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>


  <!-- Begin list item emit -->
  <!--                      -->
  <fo:list-item relative-align="baseline">
   <!-- Emit id -->
   <!--         -->
   <xsl:attribute name="id">
    <xsl:text>w</xsl:text>
    <xsl:value-of select="$ParamSplit/@groupID" />
    <xsl:text>_</xsl:text>
    <xsl:value-of select="$ParamSplit/@documentID" />
    <xsl:text>_</xsl:text>
    <xsl:value-of select="$ParamListItem/@id" />
   </xsl:attribute>

   <!-- FO properties -->
   <!--               -->
   <xsl:variable name="VarFOPropertiesAsXML">
    <xsl:call-template name="FO-TranslateProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
     <xsl:with-param name="ParamStyleType" select="'ListItem'" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarFOProperties" select="msxsl:node-set($VarFOPropertiesAsXML)/wwproject:Property" />

   <xsl:variable name="VarProvisionalDistanceBetweenStartsProperty">
    <xsl:choose>
     <xsl:when test="$VarFOProperties[@Name = 'provisional-distance-between-starts'][1]">
      <xsl:value-of select="$VarFOProperties[@Name = 'provisional-distance-between-starts'][1]/@Value" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>0pt</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:attribute name="provisional-distance-between-starts">
    <xsl:value-of select="$VarProvisionalDistanceBetweenStartsProperty"/>
   </xsl:attribute>

   <xsl:variable name="VarPaddingLeftProperty">
    <xsl:choose>
     <xsl:when test="$VarFOProperties[@Name = 'padding-left'][1]">
      <xsl:value-of select="$VarFOProperties[@Name = 'padding-left'][1]/@Value" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:text>0pt</xsl:text>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:attribute name="padding-left">
    <xsl:value-of select="$VarPaddingLeftProperty"/>
   </xsl:attribute>

   <!-- Emit standard properties -->
   <!--                          -->
   <xsl:for-each select="$VarFOProperties[not(@Name = 'provisional-distance-between-starts' or @Name = 'padding-left')]">
    <xsl:attribute name="{@Name}">
     <xsl:value-of select="@Value" />
    </xsl:attribute>
   </xsl:for-each>

   <xsl:variable name="VarListItemWithNumberAsXML">
    <wwdoc:ListItem id="{$ParamListItem/@id}" stylename="{$ParamListItem/@stylename}">
     <wwdoc:Number value="{$ParamListItem/@value}">
      <wwdoc:Style>
       <xsl:if test="$ParamListItem/@ordered = 'False'">
        <wwdoc:Attribute name="font-family" value="Calibri" />
       </xsl:if>
      </wwdoc:Style>
      <wwdoc:Text value="{$VarCharacter}{$VarSeparator}"/>
     </wwdoc:Number>
     <xsl:copy-of select="$ParamListItem/*"/>
    </wwdoc:ListItem>
   </xsl:variable>

   <xsl:variable name="VarListItemWithNumber" select="msxsl:node-set($VarListItemWithNumberAsXML)/*" />

   <fo:list-item-label start-indent="body-start() - from-nearest-specified-value(margin-left) - {$VarProvisionalDistanceBetweenStartsProperty} - {$VarPaddingLeftProperty}" end-indent="label-end() + {$VarPaddingLeftProperty}">
    <fo:block text-align="right">
     <xsl:call-template name="Number">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamParagraph" select="$VarListItemWithNumber" />
      <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
      <xsl:with-param name="ParamIgnoreDocumentNumber" select="$VarIgnoreDocumentNumber" />
      <xsl:with-param name="ParamCharacter" select="$VarBulletCharacter" />
      <xsl:with-param name="ParamImage" select="$VarBulletImage" />
      <xsl:with-param name="ParamSeparator" select="$VarBulletSeparator" />
      <xsl:with-param name="ParamStyle" select="$VarBulletStyle" />
     </xsl:call-template>
    </fo:block>
   </fo:list-item-label>
   <fo:list-item-body start-indent="body-start()">
    <fo:block>
     <xsl:apply-templates select="$ParamListItem/*" mode="wwmode:nestedcontent">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     </xsl:apply-templates>
    </fo:block>
   </fo:list-item-body>

   <!-- End list item emit -->
   <!--                    -->
  </fo:list-item>
 </xsl:template>


 <xsl:template match="wwdoc:Block" mode="wwmode:content">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarBlock" select="." />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarBlock/@stylename, $ParamSplit/@documentID, $VarBlock/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">
    <!-- Related Topic Only or Popup Only? -->
    <!--                                   -->
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
     <xsl:variable name="VarBlockBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarBlock/@id)[1]" />
     <xsl:variable name="VarInPopupPage" select="count($ParamCargo/wwbehaviors:PopupPage) &gt; 0" />
     <xsl:variable name="VarPopupOnly" select="($VarBlockBehavior/@popup = 'define-no-output') or ($VarBlockBehavior/@popup = 'append-no-output')" />
     <xsl:variable name="VarRelatedTopicOnly" select="$VarBlockBehavior/@relatedtopic = 'define-no-output'" />

     <xsl:if test="$VarInPopupPage or (not($VarPopupOnly) and not($VarRelatedTopicOnly))">
      <!-- Block -->
      <!--           -->
      <xsl:call-template name="Block">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamBlock" select="$VarBlock" />
       <xsl:with-param name="ParamStyleName" select="$VarBlock/@stylename" />
       <xsl:with-param name="ParamOverrideRule" select="$VarOverrideRule" />
       <xsl:with-param name="ParamBlockBehavior" select="$VarBlockBehavior" />
      </xsl:call-template>
     </xsl:if>
    </xsl:for-each>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Block" mode="wwmode:nestedcontent">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:apply-templates select="." mode="wwmode:content">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template name="Block">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData"/>
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamBlock" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamOverrideRule" />
  <xsl:param name="ParamBlockBehavior" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveOverrideRule">
    <xsl:with-param name="ParamProperties" select="$ParamOverrideRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamContextStyle" select="$ParamBlock/wwdoc:Style" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamBlock/@stylename, $ParamSplit/@documentID, $ParamBlock/@id)" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedContextPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveContextRule">
    <xsl:with-param name="ParamDocumentContext" select="$ParamBlock" />
    <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamStyleName" select="$ParamBlock/@stylename" />
    <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
    <xsl:with-param name="ParamContextStyle" select="$ParamBlock/wwdoc:Style" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

  <!-- Begin list item emit -->
  <!--                      -->
  <fo:block>
   <!-- Emit id -->
   <!--         -->
   <xsl:attribute name="id">
    <xsl:text>w</xsl:text>
    <xsl:value-of select="$ParamSplit/@groupID" />
    <xsl:text>_</xsl:text>
    <xsl:value-of select="$ParamSplit/@documentID" />
    <xsl:text>_</xsl:text>
    <xsl:value-of select="$ParamBlock/@id" />
   </xsl:attribute>

   <!-- FO properties -->
   <!--               -->
   <xsl:variable name="VarFOPropertiesAsXML">
    <xsl:call-template name="FO-TranslateProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
     <xsl:with-param name="ParamStyleType" select="'Block'" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarFOProperties" select="msxsl:node-set($VarFOPropertiesAsXML)/wwproject:Property" />

   <xsl:for-each select="$VarFOProperties">
    <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
   </xsl:for-each>

   <!-- Child Content -->
   <!--               -->
   <xsl:apply-templates select="$ParamBlock/*" mode="wwmode:content">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   </xsl:apply-templates>

   <!-- End quote emit -->
   <!--                -->
  </fo:block>
 </xsl:template>


 <xsl:template match="wwdoc:Paragraph" mode="wwmode:content">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarParagraph" select="." />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $VarParagraph/@stylename, $ParamSplit/@documentID, $VarParagraph/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">
    <!-- Related Topic Only or Popup Only? -->
    <!--                                   -->
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
     <xsl:variable name="VarParagraphBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarParagraph/@id)[1]" />
     <xsl:variable name="VarInPopupPage" select="count($ParamCargo/wwbehaviors:PopupPage) &gt; 0" />
     <xsl:variable name="VarPopupOnly" select="($VarParagraphBehavior/@popup = 'define-no-output') or ($VarParagraphBehavior/@popup = 'append-no-output')" />
     <xsl:variable name="VarRelatedTopicOnly" select="$VarParagraphBehavior/@relatedtopic = 'define-no-output'" />

     <xsl:if test="$VarInPopupPage or (not($VarPopupOnly) and not($VarRelatedTopicOnly))">
      <!-- Paragraph -->
      <!--           -->
      <xsl:call-template name="Paragraph">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
       <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
       <xsl:with-param name="ParamStyleName" select="$VarParagraph/@stylename" />
       <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
       <xsl:with-param name="ParamParagraphBehavior" select="$VarParagraphBehavior" />
      </xsl:call-template>

      <!-- MiniTOC -->
      <!--         -->
      <xsl:if test="not($VarInPopupPage)">
       <xsl:variable name="VarMiniTOCSubLevels" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'minitoc-sublevels']/@Value" />
       <xsl:variable name="VarMiniTOCSubLevelsNumericPrefix" select="wwunits:NumericPrefix($VarMiniTOCSubLevels)" />
       <xsl:variable name="VarMiniTOCSubLevelsGreaterThanZero" select="(string-length($VarMiniTOCSubLevelsNumericPrefix) &gt; 0) and (number($VarMiniTOCSubLevelsNumericPrefix) &gt; 0)" />
       <xsl:if test="($VarMiniTOCSubLevelsGreaterThanZero) or ($VarMiniTOCSubLevels = 'all')">
        <xsl:for-each select="$ParamTOCData[1]">
         <xsl:variable name="VarTOCEntry" select="key('wwtoc-entry-by-id', $VarParagraph/@id)[@documentID = $ParamSplit/@documentID]" />
         <xsl:for-each select="$VarTOCEntry[1]">
          <xsl:call-template name="MiniTOC">
           <xsl:with-param name="ParamSplits" select="$ParamSplits" />
           <xsl:with-param name="ParamCargo" select="$ParamCargo" />
           <xsl:with-param name="ParamLinks" select="$ParamLinks" />
           <xsl:with-param name="ParamSplit" select="$ParamSplit" />
           <xsl:with-param name="ParamTOCEntry" select="$VarTOCEntry[1]" />
           <xsl:with-param name="ParamEmitTOCEntry" select="false()" />
           <xsl:with-param name="ParamMiniTOCSubLevels" select="$VarMiniTOCSubLevels" />
          </xsl:call-template>
         </xsl:for-each>
        </xsl:for-each>
       </xsl:if>
      </xsl:if>
     </xsl:if>
    </xsl:for-each>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template match="wwdoc:Paragraph" mode="wwmode:nestedcontent">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarParagraph" select="." />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $VarParagraph/@stylename, $ParamSplit/@documentID, $VarParagraph/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">
    <!-- Related Topic Only or Popup Only? -->
    <!--                                   -->
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
     <xsl:variable name="VarParagraphBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarParagraph/@id)[1]" />
     <xsl:variable name="VarInPopupPage" select="count($ParamCargo/wwbehaviors:PopupPage) &gt; 0" />
     <xsl:variable name="VarPopupOnly" select="($VarParagraphBehavior/@popup = 'define-no-output') or ($VarParagraphBehavior/@popup = 'append-no-output')" />
     <xsl:variable name="VarRelatedTopicOnly" select="$VarParagraphBehavior/@relatedtopic = 'define-no-output'" />

     <xsl:if test="$VarInPopupPage or (not($VarPopupOnly) and not($VarRelatedTopicOnly))">
      <!-- Paragraph -->
      <!--           -->
      <xsl:call-template name="Paragraph-Nested">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
       <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
       <xsl:with-param name="ParamStyleName" select="$VarParagraph/@stylename" />
       <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
       <xsl:with-param name="ParamParagraphBehavior" select="$VarParagraphBehavior" />
      </xsl:call-template>

      <!-- MiniTOC -->
      <!--         -->
      <xsl:if test="not($VarInPopupPage)">
       <xsl:variable name="VarMiniTOCSubLevels" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'minitoc-sublevels']/@Value" />
       <xsl:variable name="VarMiniTOCSubLevelsNumericPrefix" select="wwunits:NumericPrefix($VarMiniTOCSubLevels)" />
       <xsl:variable name="VarMiniTOCSubLevelsGreaterThanZero" select="(string-length($VarMiniTOCSubLevelsNumericPrefix) &gt; 0) and (number($VarMiniTOCSubLevelsNumericPrefix) &gt; 0)" />
       <xsl:if test="($VarMiniTOCSubLevelsGreaterThanZero) or ($VarMiniTOCSubLevels = 'all')">
        <xsl:for-each select="$ParamTOCData[1]">
         <xsl:variable name="VarTOCEntry" select="key('wwtoc-entry-by-id', $VarParagraph/@id)[@documentID = $ParamSplit/@documentID]" />
         <xsl:for-each select="$VarTOCEntry[1]">
          <xsl:call-template name="MiniTOC">
           <xsl:with-param name="ParamSplits" select="$ParamSplits" />
           <xsl:with-param name="ParamCargo" select="$ParamCargo" />
           <xsl:with-param name="ParamLinks" select="$ParamLinks" />
           <xsl:with-param name="ParamSplit" select="$ParamSplit" />
           <xsl:with-param name="ParamTOCEntry" select="$VarTOCEntry[1]" />
           <xsl:with-param name="ParamEmitTOCEntry" select="false()" />
           <xsl:with-param name="ParamMiniTOCSubLevels" select="$VarMiniTOCSubLevels" />
          </xsl:call-template>
         </xsl:for-each>
        </xsl:for-each>
       </xsl:if>
      </xsl:if>
     </xsl:if>
    </xsl:for-each>
   </xsl:if>
  </xsl:if>
 </xsl:template>

 <xsl:template name="Paragraph">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamParagraphBehavior" />

  <!-- Preserve empty? -->
  <!--                 -->
  <xsl:variable name="VarPreserveEmptyOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'preserve-empty']/@Value" />
  <xsl:variable name="VarPreserveEmpty" select="(string-length($VarPreserveEmptyOption) = 0) or ($VarPreserveEmptyOption = 'true')" />

  <!-- Non-empty text runs -->
  <!--                     -->
  <xsl:variable name="VarTextRuns" select="$ParamParagraph/wwdoc:TextRun[count(child::wwdoc:TextRun[1] | child::wwdoc:Text[1] | child::wwdoc:Frame[1] | child::wwdoc:Note[1] | child::wwdoc:LineBreak[1] | child::wwdoc:Marker[1]) &gt; 0]" />

  <!-- Process this paragraph at all? -->
  <!--                                -->
  <xsl:if test="($VarPreserveEmpty) or (count($VarTextRuns[1]) = 1)">
   <!-- Pass-through? -->
   <!--               -->
   <xsl:variable name="VarPassThrough">
    <xsl:variable name="VarPassThroughOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'pass-through']/@Value" />

    <xsl:choose>
     <xsl:when test="$VarPassThroughOption = 'true'">
      <xsl:value-of select="true()" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:call-template name="Conditions-PassThrough">
       <xsl:with-param name="ParamConditions" select="$ParamParagraph/wwdoc:Conditions" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:choose>
    <!-- Pass-through -->
    <!--              -->
    <xsl:when test="$VarPassThrough = 'true'">
     <xsl:call-template name="Paragraph-PassThrough">
      <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
     <xsl:call-template name="Paragraph-Normal">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
      <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
      <xsl:with-param name="ParamStyleName" select="$ParamStyleName" />
      <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
      <xsl:with-param name="ParamParagraphBehavior" select="$ParamParagraphBehavior" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:template>

 <xsl:template name="Paragraph-Nested">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamParagraphBehavior" />

  <!-- Preserve empty? -->
  <!--                 -->
  <xsl:variable name="VarPreserveEmptyOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'preserve-empty']/@Value" />
  <xsl:variable name="VarPreserveEmpty" select="(string-length($VarPreserveEmptyOption) = 0) or ($VarPreserveEmptyOption = 'true')" />

  <!-- Non-empty text runs -->
  <!--                     -->
  <xsl:variable name="VarTextRuns" select="$ParamParagraph/wwdoc:TextRun[count(child::wwdoc:TextRun[1] | child::wwdoc:Text[1] | child::wwdoc:Frame[1] | child::wwdoc:Note[1] | child::wwdoc:LineBreak[1] | child::wwdoc:Marker[1]) &gt; 0]" />

  <!-- Process this paragraph at all? -->
  <!--                                -->
  <xsl:if test="($VarPreserveEmpty) or (count($VarTextRuns[1]) = 1)">
   <!-- Pass-through? -->
   <!--               -->
   <xsl:variable name="VarPassThrough">
    <xsl:variable name="VarPassThroughOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'pass-through']/@Value" />

    <xsl:choose>
     <xsl:when test="$VarPassThroughOption = 'true'">
      <xsl:value-of select="true()" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:call-template name="Conditions-PassThrough">
       <xsl:with-param name="ParamConditions" select="$ParamParagraph/wwdoc:Conditions" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:choose>
    <!-- Pass-through -->
    <!--              -->
    <xsl:when test="$VarPassThrough = 'true'">
     <xsl:call-template name="Paragraph-PassThrough">
      <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
     <xsl:call-template name="Paragraph-Normal-Nested">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
      <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
      <xsl:with-param name="ParamStyleName" select="$ParamStyleName" />
      <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
      <xsl:with-param name="ParamParagraphBehavior" select="$ParamParagraphBehavior" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:template>

 <xsl:template name="Paragraph-PassThrough">
  <xsl:param name="ParamParagraph" />

  <wwexsldoc:Text disable-output-escaping="yes">
   <xsl:for-each select="$ParamParagraph//wwdoc:TextRun[count(parent::wwdoc:Marker[1]) = 0]/wwdoc:Text">
    <xsl:variable name="VarText" select="." />

    <xsl:value-of select="$VarText/@value" />
   </xsl:for-each>
  </wwexsldoc:Text>
 </xsl:template>

 <xsl:template name="Paragraph-Normal">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamParagraphBehavior" />

  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamParagraph/@stylename, $ParamSplit/@documentID, $ParamParagraph/@id)" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedContextPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveContextRule">
    <xsl:with-param name="ParamDocumentContext" select="$ParamParagraph" />
    <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamStyleName" select="$ParamParagraph/@stylename" />
    <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
    <xsl:with-param name="ParamContextStyle" select="$ParamParagraph/wwdoc:Style" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

  <!-- FO properties -->
  <!--               -->
  <xsl:variable name="VarFOPropertiesAsXML">
   <xsl:call-template name="FO-TranslateProjectProperties">
    <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
    <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarFOProperties" select="msxsl:node-set($VarFOPropertiesAsXML)/wwproject:Property" />

  <!-- Use numbering? -->
  <!--                -->
  <xsl:variable name="VarUseNumberingOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'use-numbering']/@Value" />
  <xsl:variable name="VarUseNumbering" select="(string-length($VarUseNumberingOption) = 0) or ($VarUseNumberingOption = 'true')" />

  <!-- Text Indent -->
  <!--             -->
  <xsl:variable name="VarTextIndent">
   <xsl:variable name="VarTextIndentRaw">
    <xsl:if test="$VarUseNumbering">
     <xsl:value-of select="$VarResolvedContextProperties[@Name = 'text-indent']/@Value" />
    </xsl:if>
   </xsl:variable>
   <xsl:call-template name="Property-Normalize">
    <xsl:with-param name="ParamProperty" select="$VarTextIndentRaw"/>
    <xsl:with-param name="ParamDefault" select="'0pt'"/>
   </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="VarTextIndentNumericPrefix" select="wwunits:NumericPrefix($VarTextIndent)" />
  <xsl:variable name="VarTextIndentLessThanZero" select="(string-length($VarTextIndentNumericPrefix) &gt; 0) and (number($VarTextIndentNumericPrefix) &lt; 0)" />

  <!-- Use bullet from UI? -->
  <!--                     -->
  <xsl:variable name="VarBulletCharacter" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-character']/@Value" />
  <xsl:variable name="VarBulletImage" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-image']/@Value" />
  <xsl:variable name="VarBulletSeparator" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-separator']/@Value" />
  <xsl:variable name="VarBulletStyle" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-style']/@Value" />
  <xsl:variable name="VarIgnoreDocumentNumber" select="(string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0)" />

  <!-- Is numbered paragraph -->
  <!--                       -->
  <xsl:variable name="VarIsNumberedParagraph" select="($VarTextIndentLessThanZero = true()) and ((count($ParamParagraph/wwdoc:Number[1]) = 1) or (string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0))" />

  <!-- Tag -->
  <!--     -->
  <xsl:variable name="VarTag">
   <xsl:choose>
    <xsl:when test="$VarIsNumberedParagraph = true()">
     <xsl:value-of select="'list-block'" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="'block'" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Use character styles? -->
  <!--                       -->
  <xsl:variable name="VarUseCharacterStylesOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'use-character-styles']/@Value" />
  <xsl:variable name="VarUseCharacterStyles" select="(string-length($VarUseCharacterStylesOption) = 0) or ($VarUseCharacterStylesOption = 'true')" />

  <!-- Preserve empty? -->
  <!--                 -->
  <xsl:variable name="VarPreserveEmptyOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'preserve-empty']/@Value" />
  <xsl:variable name="VarPreserveEmpty" select="(string-length($VarPreserveEmptyOption) = 0) or ($VarPreserveEmptyOption = 'true')" />

  <!-- Is TOC item -->
  <!--             -->
  <xsl:variable name="VarTOCLevelAsText">
   <xsl:for-each select="$ParamTOCData[1]">
    <xsl:variable name="VarTOCEntry" select="key('wwtoc-entry-by-id', $ParamParagraph/@id)[@documentID = $ParamSplit/@documentID]" />
    <xsl:for-each select="$VarTOCEntry[1]">
     <xsl:value-of select="count($VarTOCEntry/ancestor-or-self::wwtoc:Entry)" />
    </xsl:for-each>
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarTOCLevel" select="number($VarTOCLevelAsText)" />
  <xsl:variable name="VarIsTOCItem" select="$VarTOCLevel &gt; 0" />

  <!-- Begin paragraph emit -->
  <!--                      -->
  <xsl:element name="{$VarTag}" namespace="{$GlobalDefaultNamespace}">
   <!-- Emit id -->
   <!--         -->
   <xsl:attribute name="id">
    <xsl:text>w</xsl:text>
    <xsl:value-of select="$ParamSplit/@groupID" />
    <xsl:text>_</xsl:text>
    <xsl:value-of select="$ParamSplit/@documentID" />
    <xsl:text>_</xsl:text>
    <xsl:value-of select="$ParamParagraph/@id" />
   </xsl:attribute>

   <xsl:for-each select="$VarFOProperties[@Name != 'margin-left' and @Name != 'text-indent']">
    <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
   </xsl:for-each>

   <!-- Emit margin-left and text-indent for non-numbered paragraphs -->
   <!--                                                              -->
   <xsl:if test="not($VarIsNumberedParagraph)">
    <xsl:for-each select="$VarFOProperties[@Name = 'margin-left' or @Name = 'text-indent']">
     <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
    </xsl:for-each>
   </xsl:if>

   <xsl:variable name="VarTextIndentNumberAsUnits" select="wwunits:NumericPrefix($VarTextIndent)" />
   <xsl:variable name="VarTextIndentUnits" select="wwunits:UnitsSuffix($VarTextIndent)" />


   <xsl:if test="$VarTag = 'list-block'">
    <xsl:attribute name="provisional-label-separation">
     <xsl:text>0.25in</xsl:text>
    </xsl:attribute>

    <xsl:attribute name="provisional-distance-between-starts">
     <xsl:value-of select="round(0 - $VarTextIndentNumberAsUnits)" />
     <xsl:value-of select="$VarTextIndentUnits" />
    </xsl:attribute>
   </xsl:if>

   <!-- Use numbering? -->
   <!--                -->
   <xsl:choose>
    <!-- Use Number -->
    <!--            -->
    <xsl:when test="$VarUseNumbering">
     <xsl:choose>
      <xsl:when test="(count($ParamParagraph/wwdoc:Number[1]) &gt; 0) or (string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0)">
       <xsl:choose>
        <xsl:when test="$VarTextIndentLessThanZero">

         <xsl:variable name="VarMarginLeft">
          <xsl:call-template name="Property-Normalize">
           <xsl:with-param name="ParamProperty" select="$VarResolvedContextProperties[@Name = 'margin-left']/@Value"/>
           <xsl:with-param name="ParamDefault" select="'0pt'"/>
          </xsl:call-template>
         </xsl:variable>
         <xsl:variable name="VarMarginLeftNumberAsUnits" select="wwunits:NumericPrefix($VarMarginLeft)" />
         <xsl:variable name="VarMarginLeftUnits" select="wwunits:UnitsSuffix($VarMarginLeft)" />
         <xsl:variable name="VarTextIndentAsPoints" select="wwunits:Convert($VarTextIndentNumberAsUnits, $VarTextIndentUnits, 'pt')" />
         <xsl:variable name="VarMarginLeftAsPoints" select="wwunits:Convert($VarMarginLeftNumberAsUnits, $VarMarginLeftUnits, 'pt')" />

         <xsl:variable name="VarResolvedTextIndent" select="$VarMarginLeftAsPoints + $VarTextIndentAsPoints" />

         <xsl:variable name="VarStartIndentNumber" select="wwunits:Convert($VarResolvedTextIndent, 'pt', $VarTextIndentUnits)" />

         <!-- Emit margin-left -->
         <!--                  -->
         <!-- WARNING: Node insertions must come after all attributes are set in the parent element. -->
         <xsl:attribute name="margin-left">
          <xsl:value-of select="$VarStartIndentNumber" />
          <xsl:value-of select="$VarTextIndentUnits" />
         </xsl:attribute>

         <!-- Emit marker if TOC item -->
         <!--                         -->
         <xsl:if test="$VarIsTOCItem">
          <!-- RunningTitle -->
          <!--              -->
          <fo:marker marker-class-name="RunningTitle">
           <xsl:apply-templates select="$ParamParagraph/wwdoc:Number/wwdoc:Text | $ParamParagraph/wwdoc:TextRun" mode="wwmode:textrun_text" />
          </fo:marker>

          <!-- ChapterTitle -->
          <!--              -->
          <xsl:if test="$VarTOCLevel = 1">
           <fo:marker marker-class-name="ChapterTitle">
            <xsl:apply-templates select="$ParamParagraph/wwdoc:Number/wwdoc:Text | $ParamParagraph/wwdoc:TextRun" mode="wwmode:textrun_text" />
           </fo:marker>
          </xsl:if>
         </xsl:if>

         <fo:list-item relative-align="baseline">
          <fo:list-item-label start-indent="{$VarStartIndentNumber}{$VarTextIndentUnits}">
           <!-- end-indent -->
           <!--            -->
           <xsl:attribute name="end-indent">
            <xsl:value-of select="round(0 - $VarTextIndentNumberAsUnits)" />
            <xsl:value-of select="$VarTextIndentUnits" />
           </xsl:attribute>

           <fo:block>
            <!-- Do formatting for number portion -->
            <!--                                  -->
            <xsl:call-template name="Number">
             <xsl:with-param name="ParamSplits" select="$ParamSplits" />
             <xsl:with-param name="ParamCargo" select="$ParamCargo" />
             <xsl:with-param name="ParamLinks" select="$ParamLinks" />
             <xsl:with-param name="ParamSplit" select="$ParamSplit" />
             <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
             <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
             <xsl:with-param name="ParamIgnoreDocumentNumber" select="$VarIgnoreDocumentNumber" />
             <xsl:with-param name="ParamCharacter" select="$VarBulletCharacter" />
             <xsl:with-param name="ParamImage" select="$VarBulletImage" />
             <xsl:with-param name="ParamSeparator" select="$VarBulletSeparator" />
             <xsl:with-param name="ParamStyle" select="$VarBulletStyle" />
            </xsl:call-template>
           </fo:block>
          </fo:list-item-label>

          <fo:list-item-body start-indent="body-start()">
           <fo:block>
            <!-- Text Runs -->
            <!--           -->
            <xsl:call-template name="ParagraphTextRuns">
             <xsl:with-param name="ParamSplits" select="$ParamSplits" />
             <xsl:with-param name="ParamCargo" select="$ParamCargo" />
             <xsl:with-param name="ParamLinks" select="$ParamLinks" />
             <xsl:with-param name="ParamSplit" select="$ParamSplit" />
             <xsl:with-param name="ParamPreserveEmpty" select="$VarPreserveEmpty" />
             <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
             <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
            </xsl:call-template>
           </fo:block>
          </fo:list-item-body>
         </fo:list-item>
        </xsl:when>

        <xsl:otherwise>
         <!-- Emit marker if TOC item -->
         <!--                         -->
         <xsl:if test="$VarIsTOCItem">
          <!-- RunningTitle -->
          <!--              -->
          <fo:marker marker-class-name="RunningTitle">
           <xsl:apply-templates select="$ParamParagraph/wwdoc:Number/wwdoc:Text | $ParamParagraph/wwdoc:TextRun" mode="wwmode:textrun_text" />
          </fo:marker>
                    
          <!-- ChapterTitle -->
          <!--              -->
          <xsl:if test="$VarTOCLevel = 1">
           <fo:marker marker-class-name="ChapterTitle">
            <xsl:apply-templates select="$ParamParagraph/wwdoc:Number/wwdoc:Text | $ParamParagraph/wwdoc:TextRun" mode="wwmode:textrun_text" />
           </fo:marker>
          </xsl:if>
         </xsl:if>

         <!-- Number -->
         <!--        -->
         <xsl:call-template name="Number">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamCargo" select="$ParamCargo" />
          <xsl:with-param name="ParamLinks" select="$ParamLinks" />
          <xsl:with-param name="ParamSplit" select="$ParamSplit" />
          <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
          <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
          <xsl:with-param name="ParamIgnoreDocumentNumber" select="$VarIgnoreDocumentNumber" />
          <xsl:with-param name="ParamCharacter" select="$VarBulletCharacter" />
          <xsl:with-param name="ParamImage" select="$VarBulletImage" />
          <xsl:with-param name="ParamSeparator" select="$VarBulletSeparator" />
          <xsl:with-param name="ParamStyle" select="$VarBulletStyle" />
         </xsl:call-template>

         <!-- Text Runs -->
         <!--           -->
         <xsl:call-template name="ParagraphTextRuns">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamCargo" select="$ParamCargo" />
          <xsl:with-param name="ParamLinks" select="$ParamLinks" />
          <xsl:with-param name="ParamSplit" select="$ParamSplit" />
          <xsl:with-param name="ParamPreserveEmpty" select="$VarPreserveEmpty" />
          <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
          <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
         </xsl:call-template>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
       <!-- Emit marker if TOC item -->
       <!--                         -->
       <xsl:if test="$VarIsTOCItem">
        <!-- RunningTitle -->
        <!--              -->
        <fo:marker marker-class-name="RunningTitle">
         <xsl:apply-templates select="$ParamParagraph/wwdoc:Number/wwdoc:Text | $ParamParagraph/wwdoc:TextRun" mode="wwmode:textrun_text" />
        </fo:marker>
                    
        <!-- ChapterTitle -->
        <!--              -->
        <xsl:if test="$VarTOCLevel = 1">
         <fo:marker marker-class-name="ChapterTitle">
          <xsl:apply-templates select="$ParamParagraph/wwdoc:Number/wwdoc:Text | $ParamParagraph/wwdoc:TextRun" mode="wwmode:textrun_text" />
         </fo:marker>
        </xsl:if>
       </xsl:if>

       <!-- Text Runs -->
       <!--           -->
       <xsl:call-template name="ParagraphTextRuns">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$ParamCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamPreserveEmpty" select="$VarPreserveEmpty" />
        <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
        <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
       </xsl:call-template>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:when>

    <!-- Skip Number -->
    <!--             -->
    <xsl:otherwise>
     <!-- Emit marker if TOC item -->
     <!--                         -->
     <xsl:if test="$VarIsTOCItem">
      <!-- RunningTitle -->
      <!--              -->
      <fo:marker marker-class-name="RunningTitle">
       <xsl:apply-templates select="$ParamParagraph/wwdoc:TextRun" mode="wwmode:textrun_text" />
      </fo:marker>

      <!-- ChapterTitle -->
      <!--              -->
      <xsl:if test="$VarTOCLevel = 1">
       <fo:marker marker-class-name="ChapterTitle">
        <xsl:apply-templates select="$ParamParagraph/wwdoc:TextRun" mode="wwmode:textrun_text" />
       </fo:marker>
      </xsl:if>
     </xsl:if>

     <!-- Text Runs -->
     <!--           -->
     <xsl:call-template name="ParagraphTextRuns">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamPreserveEmpty" select="$VarPreserveEmpty" />
      <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
      <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>

   <!-- End paragraph emit -->
   <!--                    -->
  </xsl:element>
 </xsl:template>

 <xsl:template name="Paragraph-Normal-Nested">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamParagraphBehavior" />

  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamParagraph/@stylename, $ParamSplit/@documentID, $ParamParagraph/@id)" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedContextPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveContextRule">
    <xsl:with-param name="ParamDocumentContext" select="$ParamParagraph" />
    <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamStyleName" select="$ParamParagraph/@stylename" />
    <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
    <xsl:with-param name="ParamContextStyle" select="$ParamParagraph/wwdoc:Style" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

  <!-- FO properties -->
  <!--               -->
  <xsl:variable name="VarFOPropertiesAsXML">
   <xsl:call-template name="FO-TranslateProjectProperties">
    <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
    <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarFOProperties" select="msxsl:node-set($VarFOPropertiesAsXML)/wwproject:Property" />

  <!-- Use numbering? -->
  <!--                -->
  <xsl:variable name="VarUseNumberingOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'use-numbering']/@Value" />
  <xsl:variable name="VarUseNumbering" select="(string-length($VarUseNumberingOption) = 0) or ($VarUseNumberingOption = 'true')" />

  <!-- Text Indent -->
  <!--             -->
  <xsl:variable name="VarTextIndent">
   <xsl:variable name="VarTextIndentRaw">
    <xsl:if test="$VarUseNumbering">
     <xsl:value-of select="$VarResolvedContextProperties[@Name = 'text-indent']/@Value" />
    </xsl:if>
   </xsl:variable>
   <xsl:call-template name="Property-Normalize">
    <xsl:with-param name="ParamProperty" select="$VarTextIndentRaw"/>
    <xsl:with-param name="ParamDefault" select="'0pt'"/>
   </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="VarTextIndentNumericPrefix" select="wwunits:NumericPrefix($VarTextIndent)" />
  <xsl:variable name="VarTextIndentLessThanZero" select="(string-length($VarTextIndentNumericPrefix) &gt; 0) and (number($VarTextIndentNumericPrefix) &lt; 0)" />

  <!-- Use bullet from UI? -->
  <!--                     -->
  <xsl:variable name="VarBulletCharacter" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-character']/@Value" />
  <xsl:variable name="VarBulletImage" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-image']/@Value" />
  <xsl:variable name="VarBulletSeparator" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-separator']/@Value" />
  <xsl:variable name="VarBulletStyle" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-style']/@Value" />
  <xsl:variable name="VarIgnoreDocumentNumber" select="(string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0)" />

  <!-- Is numbered paragraph -->
  <!--                       -->
  <xsl:variable name="VarIsNumberedParagraph" select="($VarTextIndentLessThanZero = true()) and ((count($ParamParagraph/wwdoc:Number[1]) = 1) or (string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0))" />

  <!-- Tag -->
  <!--     -->
  <xsl:variable name="VarTag">
   <xsl:choose>
    <xsl:when test="$VarIsNumberedParagraph = true()">
     <xsl:value-of select="'list-block'" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="'block'" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Use character styles? -->
  <!--                       -->
  <xsl:variable name="VarUseCharacterStylesOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'use-character-styles']/@Value" />
  <xsl:variable name="VarUseCharacterStyles" select="(string-length($VarUseCharacterStylesOption) = 0) or ($VarUseCharacterStylesOption = 'true')" />

  <!-- Preserve empty? -->
  <!--                 -->
  <xsl:variable name="VarPreserveEmptyOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'preserve-empty']/@Value" />
  <xsl:variable name="VarPreserveEmpty" select="(string-length($VarPreserveEmptyOption) = 0) or ($VarPreserveEmptyOption = 'true')" />

  <!-- Is TOC item -->
  <!--             -->
  <xsl:variable name="VarTOCLevelAsText">
   <xsl:for-each select="$ParamTOCData[1]">
    <xsl:variable name="VarTOCEntry" select="key('wwtoc-entry-by-id', $ParamParagraph/@id)[@documentID = $ParamSplit/@documentID]" />
    <xsl:for-each select="$VarTOCEntry[1]">
     <xsl:value-of select="count($VarTOCEntry/ancestor-or-self::wwtoc:Entry)" />
    </xsl:for-each>
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarTOCLevel" select="number($VarTOCLevelAsText)" />
  <xsl:variable name="VarIsTOCItem" select="$VarTOCLevel &gt; 0" />

  <!-- Begin paragraph emit -->
  <!--                      -->
  <xsl:element name="{$VarTag}" namespace="{$GlobalDefaultNamespace}">
   <!-- Emit id -->
   <!--         -->
   <xsl:attribute name="id">
    <xsl:text>w</xsl:text>
    <xsl:value-of select="$ParamSplit/@groupID" />
    <xsl:text>_</xsl:text>
    <xsl:value-of select="$ParamSplit/@documentID" />
    <xsl:text>_</xsl:text>
    <xsl:value-of select="$ParamParagraph/@id" />
   </xsl:attribute>

   <xsl:for-each select="$VarFOProperties[@Name != 'margin-left' and @Name != 'text-indent']">
    <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
   </xsl:for-each>

   <!-- Emit margin-left and text-indent for non-numbered paragraphs -->
   <!--                                                              -->
   <xsl:if test="not($VarIsNumberedParagraph)">
    <xsl:for-each select="$VarFOProperties[@Name = 'margin-left' or @Name = 'text-indent']">
     <xsl:attribute name="{@Name}">
      <xsl:call-template name="Property-Normalize">
       <xsl:with-param name="ParamProperty" select="@Value"/>
       <xsl:with-param name="ParamDefault" select="'0pt'"/>
      </xsl:call-template>
     </xsl:attribute>
    </xsl:for-each>
   </xsl:if>

   <xsl:variable name="VarTextIndentNumberAsUnits" select="wwunits:NumericPrefix($VarTextIndent)" />
   <xsl:variable name="VarTextIndentUnits" select="wwunits:UnitsSuffix($VarTextIndent)" />


   <xsl:if test="$VarTag = 'list-block'">
    <xsl:attribute name="provisional-label-separation">
     <xsl:text>0.25in</xsl:text>
    </xsl:attribute>

    <xsl:attribute name="provisional-distance-between-starts">
     <xsl:value-of select="round(0 - $VarTextIndentNumberAsUnits)" />
     <xsl:value-of select="$VarTextIndentUnits" />
    </xsl:attribute>
   </xsl:if>

   <!-- Use numbering? -->
   <!--                -->
   <xsl:choose>
    <!-- Use Number -->
    <!--            -->
    <xsl:when test="$VarUseNumbering">
     <!-- Emit marker if TOC item -->
     <!--                         -->
     <xsl:if test="$VarIsTOCItem">
      <!-- RunningTitle -->
      <!--              -->
      <fo:marker marker-class-name="RunningTitle">
       <xsl:apply-templates select="$ParamParagraph/wwdoc:Number/wwdoc:Text | $ParamParagraph/wwdoc:TextRun" mode="wwmode:textrun_text" />
      </fo:marker>

      <!-- ChapterTitle -->
      <!--              -->
      <xsl:if test="$VarTOCLevel = 1">
       <fo:marker marker-class-name="ChapterTitle">
        <xsl:apply-templates select="$ParamParagraph/wwdoc:Number/wwdoc:Text | $ParamParagraph/wwdoc:TextRun" mode="wwmode:textrun_text" />
       </fo:marker>
      </xsl:if>
     </xsl:if>

     <xsl:choose>
      <xsl:when test="(count($ParamParagraph/wwdoc:Number[1]) &gt; 0) or (string-length($VarBulletCharacter) &gt; 0) or (string-length($VarBulletImage) &gt; 0)">
       <xsl:choose>
        <xsl:when test="$VarTextIndentLessThanZero">

         <xsl:variable name="VarMarginLeft">
          <xsl:call-template name="Property-Normalize">
           <xsl:with-param name="ParamProperty" select="$VarResolvedContextProperties[@Name = 'margin-left']/@Value"/>
           <xsl:with-param name="ParamDefault" select="'0pt'"/>
          </xsl:call-template>
         </xsl:variable>
         <xsl:variable name="VarMarginLeftNumberAsUnits" select="wwunits:NumericPrefix($VarMarginLeft)" />
         <xsl:variable name="VarMarginLeftUnits" select="wwunits:UnitsSuffix($VarMarginLeft)" />
         <xsl:variable name="VarTextIndentAsPoints" select="wwunits:Convert($VarTextIndentNumberAsUnits, $VarTextIndentUnits, 'pt')" />
         <xsl:variable name="VarMarginLeftAsPoints" select="wwunits:Convert($VarMarginLeftNumberAsUnits, $VarMarginLeftUnits, 'pt')" />

         <xsl:variable name="VarResolvedTextIndent" select="$VarMarginLeftAsPoints + $VarTextIndentAsPoints" />

         <xsl:variable name="VarStartIndentNumber" select="wwunits:Convert($VarResolvedTextIndent, 'pt', $VarTextIndentUnits)" />

         <!-- Emit margin-left -->
         <!--                  -->
         <xsl:attribute name="margin-left">
          <xsl:value-of select="$VarStartIndentNumber" />
          <xsl:value-of select="$VarTextIndentUnits" />
         </xsl:attribute>

         <fo:list-item relative-align="baseline">
          <fo:list-item-label start-indent="{$VarStartIndentNumber}{$VarTextIndentUnits}">
           <!-- end-indent -->
           <!--            -->
           <xsl:attribute name="end-indent">
            <xsl:value-of select="round(0 - $VarTextIndentNumberAsUnits)" />
            <xsl:value-of select="$VarTextIndentUnits" />
           </xsl:attribute>

           <fo:block>
            <!-- Do formatting for number portion -->
            <!--                                  -->
            <xsl:call-template name="Number">
             <xsl:with-param name="ParamSplits" select="$ParamSplits" />
             <xsl:with-param name="ParamCargo" select="$ParamCargo" />
             <xsl:with-param name="ParamLinks" select="$ParamLinks" />
             <xsl:with-param name="ParamSplit" select="$ParamSplit" />
             <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
             <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
             <xsl:with-param name="ParamIgnoreDocumentNumber" select="$VarIgnoreDocumentNumber" />
             <xsl:with-param name="ParamCharacter" select="$VarBulletCharacter" />
             <xsl:with-param name="ParamImage" select="$VarBulletImage" />
             <xsl:with-param name="ParamSeparator" select="$VarBulletSeparator" />
             <xsl:with-param name="ParamStyle" select="$VarBulletStyle" />
            </xsl:call-template>
           </fo:block>
          </fo:list-item-label>

          <fo:list-item-body start-indent="body-start()">
           <fo:block>
            <!-- Text Runs -->
            <!--           -->
            <xsl:call-template name="ParagraphTextRuns">
             <xsl:with-param name="ParamSplits" select="$ParamSplits" />
             <xsl:with-param name="ParamCargo" select="$ParamCargo" />
             <xsl:with-param name="ParamLinks" select="$ParamLinks" />
             <xsl:with-param name="ParamSplit" select="$ParamSplit" />
             <xsl:with-param name="ParamPreserveEmpty" select="$VarPreserveEmpty" />
             <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
             <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
            </xsl:call-template>
           </fo:block>
          </fo:list-item-body>
         </fo:list-item>
        </xsl:when>

        <xsl:otherwise>
         <!-- Number -->
         <!--        -->
         <xsl:call-template name="Number">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamCargo" select="$ParamCargo" />
          <xsl:with-param name="ParamLinks" select="$ParamLinks" />
          <xsl:with-param name="ParamSplit" select="$ParamSplit" />
          <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
          <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
          <xsl:with-param name="ParamIgnoreDocumentNumber" select="$VarIgnoreDocumentNumber" />
          <xsl:with-param name="ParamCharacter" select="$VarBulletCharacter" />
          <xsl:with-param name="ParamImage" select="$VarBulletImage" />
          <xsl:with-param name="ParamSeparator" select="$VarBulletSeparator" />
          <xsl:with-param name="ParamStyle" select="$VarBulletStyle" />
         </xsl:call-template>

         <!-- Text Runs -->
         <!--           -->
         <xsl:call-template name="ParagraphTextRuns">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamCargo" select="$ParamCargo" />
          <xsl:with-param name="ParamLinks" select="$ParamLinks" />
          <xsl:with-param name="ParamSplit" select="$ParamSplit" />
          <xsl:with-param name="ParamPreserveEmpty" select="$VarPreserveEmpty" />
          <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
          <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
         </xsl:call-template>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
       <!-- Text Runs -->
       <!--           -->
       <xsl:call-template name="ParagraphTextRuns">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$ParamCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamPreserveEmpty" select="$VarPreserveEmpty" />
        <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
        <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
       </xsl:call-template>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:when>

    <!-- Skip Number -->
    <!--             -->
    <xsl:otherwise>
     <!-- Emit marker if TOC item -->
     <!--                         -->
     <xsl:if test="$VarIsTOCItem">
      <!-- RunningTitle -->
      <!--              -->
      <fo:marker marker-class-name="RunningTitle">
       <xsl:apply-templates select="$ParamParagraph/wwdoc:TextRun" mode="wwmode:textrun_text" />
      </fo:marker>

      <!-- ChapterTitle -->
      <!--              -->
      <xsl:if test="$VarTOCLevel = 1">
       <fo:marker marker-class-name="ChapterTitle">
        <xsl:apply-templates select="$ParamParagraph/wwdoc:TextRun" mode="wwmode:textrun_text" />
       </fo:marker>
      </xsl:if>
     </xsl:if>

     <!-- Text Runs -->
     <!--           -->
     <xsl:call-template name="ParagraphTextRuns">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamPreserveEmpty" select="$VarPreserveEmpty" />
      <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
      <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>

   <!-- End paragraph emit -->
   <!--                    -->
  </xsl:element>
 </xsl:template>


 <xsl:template name="Number">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamParagraph" />
  <xsl:param name="ParamUseCharacterStyles" />
  <xsl:param name="ParamIgnoreDocumentNumber" />
  <xsl:param name="ParamCharacter" />
  <xsl:param name="ParamImage" />
  <xsl:param name="ParamSeparator" />
  <xsl:param name="ParamStyle" />

  <xsl:choose>
   <xsl:when test="$ParamIgnoreDocumentNumber">
    <xsl:call-template name="Content-Bullet">
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
     <xsl:with-param name="ParamCharacter" select="$ParamCharacter" />
     <xsl:with-param name="ParamImage" select="$ParamImage" />
     <xsl:with-param name="ParamSeparator" select="$ParamSeparator" />
     <xsl:with-param name="ParamStyle" select="$ParamStyle" />
    </xsl:call-template>
   </xsl:when>

   <xsl:otherwise>
    <xsl:variable name="VarBulletPropertiesAsXML">
     <wwproject:BulletProperties>
      <wwproject:Property Name="bullet-style" Value="{$ParamStyle}" />
      <wwproject:Property Name="bullet-separator" Value="{$ParamSeparator}" />
     </wwproject:BulletProperties>
    </xsl:variable>
    <xsl:variable name="VarBulletProperties" select="msxsl:node-set($VarBulletPropertiesAsXML)" />

    <xsl:variable name="VarCargo" select="$ParamCargo/*[local-name() != 'BulletProperties']/.. | $VarBulletProperties" />

    <xsl:call-template name="TextRun">
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$VarCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamParagraphID" select="$ParamParagraph/@id" />
     <xsl:with-param name="ParamUseCharacterStyles" select="$ParamUseCharacterStyles" />
     <xsl:with-param name="ParamTextRun" select="$ParamParagraph/wwdoc:Number[1]" />
     <xsl:with-param name="ParamEmitAnchorName" select="false()" />
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="ParagraphTextRuns">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamPreserveEmpty" />
  <xsl:param name="ParamUseCharacterStyles" />
  <xsl:param name="ParamParagraph" />

  <!-- Prevent whitespace issues with preformatted text blocks -->
  <!--                                                         -->
  <wwexsldoc:NoBreak />

  <!-- Non-empty text runs -->
  <!--                     -->
  <xsl:variable name="VarTextRuns" select="$ParamParagraph/wwdoc:TextRun[count(child::wwdoc:TextRun[1] | child::wwdoc:Text[1] | child::wwdoc:Frame[1] | child::wwdoc:Note[1] | child::wwdoc:LineBreak[1] | child::wwdoc:Marker[1]) &gt; 0]" />
  <xsl:variable name="VarNonMarkerTextRuns" select="$ParamParagraph/wwdoc:TextRun[count(child::wwdoc:TextRun[1] | child::wwdoc:Text[1] | child::wwdoc:Frame[1] | child::wwdoc:Note[1] | child::wwdoc:LineBreak[1]) &gt; 0]" />

  <!-- Check for empty paragraphs -->
  <!--                            -->
  <xsl:choose>
   <xsl:when test="count($VarTextRuns[1]) = 1">
    <!-- Paragraph has content -->
    <!--                       -->
    <xsl:for-each select="$VarTextRuns">
     <xsl:variable name="VarTextRun" select="." />

     <xsl:call-template name="TextRun">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamParagraphID" select="$ParamParagraph/@id" />
      <xsl:with-param name="ParamUseCharacterStyles" select="$ParamUseCharacterStyles" />
      <xsl:with-param name="ParamTextRun" select="$VarTextRun" />
      <xsl:with-param name="ParamEmitAnchorName" select="count($VarTextRun | $VarNonMarkerTextRuns[1]) = 1" />
     </xsl:call-template>
    </xsl:for-each>
   </xsl:when>

   <xsl:otherwise>
    <!-- Empty paragraph! -->
    <!--                  -->
    <xsl:if test="$ParamPreserveEmpty"> &#160; </xsl:if>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="LinkInfo">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamDocumentLink" />

  <xsl:element name="LinkInfo" namespace="urn:WebWorks-Engine-Links-Schema">
   <xsl:if test="count($ParamDocumentLink) &gt; 0">
    <!-- Resolve link -->
    <!--              -->
    <xsl:variable name="VarResolvedLinkInfoAsXML">
     <xsl:call-template name="Links-Resolve">
      <xsl:with-param name="ParamAllowBaggage" select="$ParameterAllowBaggage" />
      <xsl:with-param name="ParamAllowGroupToGroup" select="$ParameterAllowGroupToGroup" />
      <xsl:with-param name="ParamAllowURL" select="$ParameterAllowURL" />
      <xsl:with-param name="ParamBaggageSplitFileType" select="$ParameterBaggageSplitFileType" />
      <xsl:with-param name="ParamProject" select="$GlobalProject" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamSplitGroupID" select="$ParamSplit/@groupID" />
      <xsl:with-param name="ParamSplitDocumentID" select="$ParamSplit/@documentID" />
      <xsl:with-param name="ParamDocumentLink" select="$ParamDocumentLink" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarResolvedLinkInfo" select="msxsl:node-set($VarResolvedLinkInfoAsXML)/wwlinks:ResolvedLink" />

    <!-- @title -->
    <!--        -->
    <xsl:if test="string-length($VarResolvedLinkInfo/@title) &gt; 0">
     <xsl:attribute name="title">
      <xsl:value-of select="$VarResolvedLinkInfo/@title" />
     </xsl:attribute>
    </xsl:if>

    <xsl:choose>
     <!-- Baggage -->
     <!--         -->
     <xsl:when test="$VarResolvedLinkInfo/@type = 'baggage'">
      <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($VarResolvedLinkInfo/@path, $ParamSplit/@path)" />

      <xsl:attribute name="href">
       <xsl:text>url('</xsl:text>
       <xsl:value-of select="$VarRelativePath" />
       <xsl:text>')</xsl:text>
      </xsl:attribute>

      <xsl:attribute name="attribute-name">external-destination</xsl:attribute>
     </xsl:when>

     <!-- Document -->
     <!--          -->
     <xsl:when test="($VarResolvedLinkInfo/@type = 'document') or ($VarResolvedLinkInfo/@type = 'group') or ($VarResolvedLinkInfo/@type = 'project')">
      <xsl:variable name="VarLinkTargetID">
       <xsl:text>w</xsl:text>
       <xsl:value-of select="$VarResolvedLinkInfo/@groupID" />
       <xsl:text>_</xsl:text>
       <xsl:value-of select="$VarResolvedLinkInfo/@documentID" />
       <xsl:text>_</xsl:text>
       <xsl:value-of select="$VarResolvedLinkInfo/@linkid" />
      </xsl:variable>

      <xsl:choose>
       <!-- Document mode -->
       <!--               -->
       <xsl:when test="$ParameterMode = 'document'">
        <xsl:choose>
         <!-- Destination is in another project document -->
         <!--                                            -->
         <xsl:when test="$VarResolvedLinkInfo/@documentID != $ParamSplit/@documentID">
          <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($VarResolvedLinkInfo/@path, $ParamSplit/@path)" />

          <xsl:attribute name="href">
           <xsl:text>url('</xsl:text>
           <xsl:value-of select="$VarRelativePath" />
           <xsl:text>#</xsl:text>
           <xsl:value-of select="$VarLinkTargetID" />
           <xsl:text>')</xsl:text>
          </xsl:attribute>

          <xsl:attribute name="attribute-name">external-destination</xsl:attribute>
         </xsl:when>

         <xsl:otherwise>
          <xsl:attribute name="href"><xsl:value-of select="$VarLinkTargetID" /></xsl:attribute>
          <xsl:attribute name="attribute-name">internal-destination</xsl:attribute>
         </xsl:otherwise>
        </xsl:choose>
       </xsl:when>

       <!-- Group mode -->
       <!--            -->
       <xsl:when test="$ParameterMode = 'group'">
        <xsl:choose>
         <!-- Destination is in another project document -->
         <!--                                            -->
         <xsl:when test="$VarResolvedLinkInfo/@groupID != $ParamSplit/@groupID">
          <xsl:for-each select="$GlobalFiles[1]">
           <xsl:variable name="VarTargetSplitsFile" select="key('wwfiles-files-by-type', $ParameterSplitsType)[@groupID = $VarResolvedLinkInfo/@groupID]" />
           <xsl:variable name="VarTargetSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarTargetSplitsFile/@path)" />

           <xsl:for-each select="$VarTargetSplits[1]">
            <xsl:variable name="VarTargetOutputSplit" select="key('wwsplits-files-by-type', $ParameterGroupSplitFileType)[1]" />

            <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($VarTargetOutputSplit/@path, $ParamSplit/@path)" />

            <xsl:attribute name="href">
             <xsl:text>url('</xsl:text>
             <xsl:value-of select="$VarRelativePath" />
             <xsl:text>#</xsl:text>
             <xsl:value-of select="$VarLinkTargetID" />
             <xsl:text>')</xsl:text>
            </xsl:attribute>

            <xsl:attribute name="attribute-name">external-destination</xsl:attribute>
           </xsl:for-each>
          </xsl:for-each>
         </xsl:when>

         <xsl:otherwise>
          <xsl:attribute name="href"><xsl:value-of select="$VarLinkTargetID" /></xsl:attribute>
          <xsl:attribute name="attribute-name">internal-destination</xsl:attribute>
         </xsl:otherwise>
        </xsl:choose>
       </xsl:when>

       <!-- Project mode -->
       <!--              -->
       <xsl:otherwise>
        <xsl:attribute name="href"><xsl:value-of select="$VarLinkTargetID" /></xsl:attribute>
        <xsl:attribute name="attribute-name">internal-destination</xsl:attribute>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:when>

     <!-- URL -->
     <!--     -->
     <xsl:when test="$VarResolvedLinkInfo/@type = 'url'">
      <xsl:attribute name="href">
       <xsl:text>url('</xsl:text>
       <xsl:value-of select="$VarResolvedLinkInfo/@url" />
       <xsl:text>')</xsl:text>
      </xsl:attribute>

      <xsl:attribute name="attribute-name">external-destination</xsl:attribute>
     </xsl:when>
    </xsl:choose>
   </xsl:if>
  </xsl:element>
 </xsl:template>


 <xsl:template name="TextRun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamParagraphID" />
  <xsl:param name="ParamUseCharacterStyles" />
  <xsl:param name="ParamTextRun" />
  <xsl:param name="ParamEmitAnchorName" />

  <!-- Get stylename -->
  <!--               -->
  <xsl:variable name="VarStyleName">
   <xsl:choose>
    <xsl:when test="string-length($ParamCargo/wwproject:BulletProperties/wwproject:Property[@Name = 'bullet-style']/@Value) &gt; 0">
     <xsl:value-of select="$ParamCargo/wwproject:BulletProperties/wwproject:Property[@Name = 'bullet-style']/@Value" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$ParamTextRun/@stylename" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Get rule -->
  <!--          -->
  <xsl:variable name="VarRule" select="wwprojext:GetRule('Character', $VarStyleName)" />

  <!-- Generate output? -->
  <!---                 -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Pass-through? -->
   <!--               -->
   <xsl:variable name="VarPassThrough">
    <xsl:variable name="VarPassThroughOption" select="$VarRule/wwproject:Options/wwproject:Option[@Name = 'pass-through']/@Value" />

    <xsl:choose>
     <xsl:when test="$VarPassThroughOption = 'true'">
      <xsl:value-of select="true()" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:call-template name="Conditions-PassThrough">
       <xsl:with-param name="ParamConditions" select="$ParamTextRun/wwdoc:Conditions" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <xsl:choose>
    <xsl:when test="$VarPassThrough = 'true'">
     <xsl:call-template name="TextRun-PassThrough">
      <xsl:with-param name="ParamTextRun" select="$ParamTextRun" />
     </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
     <xsl:call-template name="TextRun-Normal">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamParagraphID" select="$ParamParagraphID" />
      <xsl:with-param name="ParamUseCharacterStyles" select="$ParamUseCharacterStyles" />
      <xsl:with-param name="ParamTextRun" select="$ParamTextRun" />
      <xsl:with-param name="ParamRule" select="$VarRule" />
      <xsl:with-param name="ParamEmitAnchorName" select="$ParamEmitAnchorName" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:template>


 <xsl:template name="TextRun-PassThrough">
  <xsl:param name="ParamTextRun" />

  <wwexsldoc:Text>
   <xsl:for-each select="$ParamTextRun/wwdoc:Text">
    <xsl:variable name="VarText" select="." />

    <xsl:value-of select="$VarText/@value" />
   </xsl:for-each>
  </wwexsldoc:Text>
 </xsl:template>


 <xsl:template name="TextRun-Normal">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamParagraphID" />
  <xsl:param name="ParamUseCharacterStyles" />
  <xsl:param name="ParamTextRun" />
  <xsl:param name="ParamRule" />
  <xsl:param name="ParamEmitAnchorName" />

  <!-- Get stylename -->
  <!--               -->
  <xsl:variable name="VarStyleName">
   <xsl:choose>
    <xsl:when test="string-length($ParamCargo/wwproject:BulletProperties/wwproject:Property[@Name = 'bullet-style']/@Value) &gt; 0">
     <xsl:value-of select="$ParamCargo/wwproject:BulletProperties/wwproject:Property[@Name = 'bullet-style']/@Value" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$ParamTextRun/@stylename" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:choose>
   <xsl:when test="($ParamUseCharacterStyles) and ((string-length($VarStyleName) &gt; 0) or (count($ParamTextRun/wwdoc:Style) = 1))">
    <!-- Get context rule -->
    <!--                  -->
     <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Character', $VarStyleName, $ParamSplit/@documentID, $ParamTextRun/@id)" />

    <!-- Resolve project properties -->
    <!--                            -->
    <xsl:variable name="VarResolvedContextPropertiesAsXML">
     <xsl:call-template name="Properties-ResolveContextRule">
      <xsl:with-param name="ParamDocumentContext" select="$ParamTextRun" />
      <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
      <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
      <xsl:with-param name="ParamStyleType" select="'Character'" />
      <xsl:with-param name="ParamContextStyle" select="$ParamTextRun/wwdoc:Style" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

    <!-- FO properties -->
    <!--               -->
    <xsl:variable name="VarFOPropertiesAsXML">
     <xsl:call-template name="FO-TranslateProjectProperties">
      <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
      <xsl:with-param name="ParamStyleType" select="'Character'" />
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarFOProperties" select="msxsl:node-set($VarFOPropertiesAsXML)/wwproject:Property" />

    <xsl:choose>
     <xsl:when test="count($VarFOProperties[1]) = 1">
      <!-- Character Style -->
      <!--                 -->
      <fo:inline>
       <xsl:for-each select="$VarFOProperties">
        <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
       </xsl:for-each>

       <xsl:call-template name="TextRunChildren">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$ParamCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamParagraphID" select="$ParamParagraphID" />
        <xsl:with-param name="ParamTextRun" select="$ParamTextRun" />
        <xsl:with-param name="ParamEmitAnchorName" select="$ParamEmitAnchorName" />
       </xsl:call-template>
      </fo:inline>
     </xsl:when>

     <xsl:otherwise>
      <!-- No style -->
      <!--          -->
      <xsl:call-template name="TextRunChildren">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamParagraphID" select="$ParamParagraphID" />
       <xsl:with-param name="ParamTextRun" select="$ParamTextRun" />
       <xsl:with-param name="ParamEmitAnchorName" select="$ParamEmitAnchorName" />
      </xsl:call-template>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>

   <xsl:otherwise>
    <!-- No style -->
    <!--          -->
    <xsl:call-template name="TextRunChildren">
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$ParamCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamParagraphID" select="$ParamParagraphID" />
     <xsl:with-param name="ParamTextRun" select="$ParamTextRun" />
     <xsl:with-param name="ParamEmitAnchorName" select="$ParamEmitAnchorName" />
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>


 <xsl:template name="TextRunChildren">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamParagraphID" />
  <xsl:param name="ParamTextRun" />
  <xsl:param name="ParamEmitAnchorName" />

  <!-- Force anchor on same line as container -->
  <!--                                        -->
  <wwexsldoc:NoBreak />

  <!-- Link? -->
  <!--       -->
  <xsl:variable name="VarLinkInfoAsXML">
   <xsl:call-template name="LinkInfo">
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamDocumentLink" select="$ParamTextRun/wwdoc:Link" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarLinkInfo" select="msxsl:node-set($VarLinkInfoAsXML)/wwlinks:LinkInfo" />

  <!-- Handle links and first textrun anchor -->
  <!--                                       -->
  <xsl:choose>
   <xsl:when test="string-length($VarLinkInfo/@href) &gt; 0">
    <fo:basic-link>
     <xsl:attribute name="{$VarLinkInfo/@attribute-name}">
      <xsl:value-of select="$VarLinkInfo/@href" />
     </xsl:attribute>

     <xsl:apply-templates select="$ParamTextRun/*" mode="wwmode:textrun">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     </xsl:apply-templates>

     <!-- Emit 'on page' for links? -->
     <!--                           -->
     <xsl:if test="false()">
      <xsl:if test="$VarLinkInfo/@attribute-name = 'internal-destination'">
       <xsl:text> on page </xsl:text>
       <fo:page-number-citation ref-id="{$VarLinkInfo/@href}"/>
      </xsl:if>
     </xsl:if>
    </fo:basic-link>
   </xsl:when>

   <xsl:otherwise>
    <xsl:apply-templates select="$ParamTextRun/*" mode="wwmode:textrun">
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$ParamCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    </xsl:apply-templates>
   </xsl:otherwise>
  </xsl:choose>

  <!-- Separator -->
  <!--           -->
  <xsl:if test="string-length($ParamCargo/wwproject:BulletProperties/wwproject:Property[@Name = 'bullet-separator']/@Value) &gt; 0">
   <xsl:value-of select="$ParamCargo/wwproject:BulletProperties/wwproject:Property[@Name = 'bullet-separator']/@Value" />
  </xsl:if>

  <!-- Force anchor on same line as container -->
  <!--                                        -->
  <wwexsldoc:NoBreak />
 </xsl:template>


 <xsl:template match="wwdoc:TextRun" mode="wwmode:textrun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarTextRun" select="." />
  <xsl:variable name="VarStyleName" select="$VarTextRun/@stylename" />
  <xsl:variable name="VarParagraphID" select="$ParamSplit/@id" />
  <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Character', $VarStyleName, $ParamSplit/@documentID, $VarTextRun/@id)" />

  <!-- Use character styles? -->
  <!--                       -->
  <xsl:variable name="VarUseCharacterStylesOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'use-character-styles']/@Value" />
  <xsl:variable name="VarUseCharacterStyles" select="(string-length($VarUseCharacterStylesOption) = 0) or ($VarUseCharacterStylesOption = 'true')" />

  <xsl:call-template name="TextRun">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
   <xsl:with-param name="ParamParagraphID" select="$VarParagraphID" />
   <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
   <xsl:with-param name="ParamTextRun" select="$VarTextRun" />
   <xsl:with-param name="ParamEmitAnchorName" select="false()" />
  </xsl:call-template>
 </xsl:template>


 <xsl:template match="wwdoc:Note" mode="wwmode:textrun">
  <xsl:param name="ParamContext" select="." />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />


  <!-- Implement notes -->
  <!--                 -->
  <xsl:for-each select="$ParamCargo/wwnotes:NoteNumbering[1]">
   <xsl:variable name="VarNoteNumber" select="key('wwnotes-notes-by-id', $ParamContext/@id)/@number" />

   <xsl:choose>
    <xsl:when test="count($ParamContext/ancestor::wwdoc:Table[1]) = 1 or count($ParamContext/ancestor::wwdoc:Frame[1]) = 1">
     <!-- Case for tables and graphics -->
     <!--                              -->
     <fo:inline baseline-shift="super" font-size="8pt">
      <fo:basic-link id="wwfootnote_inline_{$ParamSplit/@groupID}_{$ParamSplit/@documentID}_{$ParamContext/@id}">
       <xsl:attribute name="internal-destination">
        <xsl:text>w</xsl:text>
        <xsl:value-of select="$ParamSplit/@groupID" />
        <xsl:text>_</xsl:text>
        <xsl:value-of select="$ParamSplit/@documentID" />
        <xsl:text>_</xsl:text>
        <xsl:value-of select="$ParamContext/@id" />
       </xsl:attribute>

       <xsl:value-of select="$VarNoteNumber"/>
      </fo:basic-link>
     </fo:inline>
    </xsl:when>

    <xsl:otherwise>
     <fo:footnote>
      <fo:inline baseline-shift="super" font-size="8pt">
       <fo:basic-link id="wwfootnote_inline_{$ParamSplit/@groupID}_{$ParamSplit/@documentID}_{$ParamContext/@id}">
        <xsl:attribute name="internal-destination">
         <xsl:text>w</xsl:text>
         <xsl:value-of select="$ParamSplit/@groupID" />
         <xsl:text>_</xsl:text>
         <xsl:value-of select="$ParamSplit/@documentID" />
         <xsl:text>_</xsl:text>
         <xsl:value-of select="$ParamContext/@id" />
        </xsl:attribute>

        <xsl:value-of select="$VarNoteNumber"/>
       </fo:basic-link>
      </fo:inline>

      <fo:footnote-body>
       <fo:block>
        <xsl:variable name="VarParagraph" select="$ParamContext/wwdoc:Paragraph[1]" />
        <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $VarParagraph/@stylename, $ParamSplit/@documentID, $VarParagraph/@id)" />

        <!-- Resolve project properties -->
        <!--                            -->
        <xsl:variable name="VarResolvedContextPropertiesAsXML">
         <xsl:call-template name="Properties-ResolveContextRule">
          <xsl:with-param name="ParamDocumentContext" select="$VarParagraph" />
          <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
          <xsl:with-param name="ParamStyleName" select="$VarParagraph/@stylename" />
          <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
          <xsl:with-param name="ParamContextStyle" select="$VarParagraph/wwdoc:Style" />
         </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

        <!-- FO properties -->
        <!--               -->
        <xsl:variable name="VarFOPropertiesAsXML">
         <xsl:call-template name="FO-TranslateProjectProperties">
          <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
          <xsl:with-param name="ParamStyleType" select="'Paragraph'" />
         </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="VarFOProperties" select="msxsl:node-set($VarFOPropertiesAsXML)/wwproject:Property" />

        <!-- Emit formatting attributes -->
        <!--                            -->
        <xsl:for-each select="$VarFOProperties">
         <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
        </xsl:for-each>

        <fo:inline font-size="8pt" baseline-shift="super">
         <fo:basic-link id="w{$ParamSplit/@groupID}_{$ParamSplit/@documentID}_{$ParamContext/@id}">
          <xsl:attribute name="internal-destination">
           <xsl:text>wwfootnote_inline_</xsl:text>
           <xsl:value-of select="$ParamSplit/@groupID" />
           <xsl:text>_</xsl:text>
           <xsl:value-of select="$ParamSplit/@documentID" />
           <xsl:text>_</xsl:text>
           <xsl:value-of select="$ParamContext/@id" />
          </xsl:attribute>

          <xsl:value-of select="$VarNoteNumber"/>
          <xsl:text>)&#xA0;</xsl:text>
         </fo:basic-link>
        </fo:inline>

        <xsl:call-template name="ParagraphTextRuns">
         <xsl:with-param name="ParamSplits" select="$ParamSplits" />
         <xsl:with-param name="ParamCargo" select="$ParamCargo" />
         <xsl:with-param name="ParamLinks" select="$ParamLinks" />
         <xsl:with-param name="ParamSplit" select="$ParamSplit" />
         <xsl:with-param name="ParamPreserveEmpty" select="false()" />
         <xsl:with-param name="ParamUseCharacterStyles" select="true()" />
         <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
        </xsl:call-template>
       </fo:block>
      </fo:footnote-body>
     </fo:footnote>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:for-each>
 </xsl:template>


 <xsl:template match="wwdoc:LineBreak" mode="wwmode:textrun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <fo:block keep-with-previous="always" keep-with-next="always">
   <xsl:text>&#x0A;</xsl:text>
  </fo:block>

 </xsl:template>


 <xsl:template match="wwdoc:IndexMarker" mode="wwmode:textrun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <!-- Ignore index markers -->
  <!--                      -->
 </xsl:template>


 <xsl:template match="wwdoc:Marker" mode="wwmode:textrun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <!-- Ignore markers -->
  <!--                -->
 </xsl:template>


 <xsl:template match="wwdoc:Text" mode="wwmode:textrun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:value-of select="@value" />
 </xsl:template>


 <xsl:template match="wwdoc:Table" mode="wwmode:content">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:variable name="VarTable" select="." />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Table', $VarTable/@stylename, $ParamSplit/@documentID, $VarTable/@id)" />
   <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
   <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
   <xsl:if test="$VarGenerateOutput">

    <!-- Get behavior -->
    <!--              -->
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
     <xsl:variable name="VarTableBehavior" select="key('wwbehaviors-tables-by-id', $VarTable/@id)[1]" />

     <!-- Ensure body rows exist -->
     <!--                        -->
     <xsl:if test="count($VarTable/wwdoc:TableBody/wwdoc:*[1]) = 1">
      <!-- Table -->
      <!--       -->
      <xsl:call-template name="Table">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamTable" select="$VarTable" />
       <xsl:with-param name="ParamStyleName" select="$VarTable/@stylename" />
       <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
       <xsl:with-param name="ParamTableBehavior" select="$VarTableBehavior" />
      </xsl:call-template>
     </xsl:if>
    </xsl:for-each>
   </xsl:if>
  </xsl:if>

 </xsl:template>

 <xsl:template match="wwdoc:Table" mode="wwmode:nestedcontent">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:apply-templates select="." mode="wwmode:content">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template name="Table">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamTable" />
  <xsl:param name="ParamStyleName" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamTableBehavior" />

  <!-- Notes -->
  <!--       -->
  <xsl:variable name="VarNotes" select="$ParamTable//wwdoc:Note[not(ancestor::wwdoc:Frame)]" />

  <!-- Note numbering -->
  <!--                -->
  <xsl:variable name="VarNoteNumberingAsXML">
   <xsl:call-template name="Notes-Number">
    <xsl:with-param name="ParamNotes" select="$VarNotes" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarNoteNumbering" select="msxsl:node-set($VarNoteNumberingAsXML)" />

  <!-- Cargo for recursion -->
  <!--                     -->
  <xsl:variable name="VarCargo" select="$ParamCargo/*[local-name() != 'NoteNumbering']/.. | $VarNoteNumbering" />

  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Table', $ParamTable/@stylename, $ParamSplit/@documentID, $ParamTable/@id)" />

  <!-- Resolve project properties -->
  <!--                            -->
  <xsl:variable name="VarResolvedContextPropertiesAsXML">
   <xsl:call-template name="Properties-ResolveContextRule">
    <xsl:with-param name="ParamDocumentContext" select="$ParamTable" />
    <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
    <xsl:with-param name="ParamStyleName" select="$ParamTable/@stylename" />
    <xsl:with-param name="ParamStyleType" select="'Table'" />
    <xsl:with-param name="ParamContextStyle" select="$ParamTable/wwdoc:Style" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarResolvedContextProperties" select="msxsl:node-set($VarResolvedContextPropertiesAsXML)/wwproject:Property" />

  <!-- FO properties -->
  <!--               -->
  <xsl:variable name="VarFOPropertiesAsXML">
   <xsl:call-template name="FO-TranslateProjectProperties">
    <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
    <xsl:with-param name="ParamStyleType" select="'Table'" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarFOProperties" select="msxsl:node-set($VarFOPropertiesAsXML)/wwproject:Property" />

  <!-- Table vertical alignment -->
  <!--                          -->
  <xsl:variable name="VarTableVerticalAlignment">
   <xsl:variable name="VarTableVerticalAlignmentHint" select="$VarResolvedContextProperties[@Name = 'vertical-align']/@Value" />
   <xsl:choose>
    <xsl:when test="string-length($VarTableVerticalAlignmentHint) &gt; 0">
     <xsl:value-of select="$VarTableVerticalAlignmentHint" />
    </xsl:when>
    <xsl:otherwise>
     <xsl:value-of select="''" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <!-- Emit <table> element with class, style, and summary attrs. -->
  <!--                                                                -->
  <!-- <fo:table-and-caption> -->
   <!-- Apply caption templates -->
   <!--                         -->
   <xsl:for-each select="$ParamTable/wwdoc:Caption[1][count(./wwdoc:*[local-name() != 'Style'][1]) &gt; 0]">
    <xsl:if test="count(./*[1]) = 1">
     <!-- <fo:table-caption> -->

      <xsl:apply-templates select="./*" mode="wwmode:content">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$VarCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      </xsl:apply-templates>

     <!-- </fo:table-caption> -->
    </xsl:if>
   </xsl:for-each>

   <fo:block>
    <!-- Handle span -->
    <!--             -->
    <xsl:for-each select="$VarFOProperties[@Name = 'span']">
     <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
    </xsl:for-each>

    <fo:table id="w{$ParamSplit/@groupID}_{$ParamSplit/@documentID}_{$ParamTable/@id}">

     <xsl:for-each select="$VarFOProperties[@Name != 'span' and @Name != 'margin-left' and @Name != 'text-indent']">
      <xsl:attribute name="{@Name}">
       <xsl:value-of select="@Value" />
      </xsl:attribute>
     </xsl:for-each>

     <!-- Determine table cell widths -->
     <!--                             -->
     <xsl:variable name="VarFirstTableCellWidth" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'table-cell-width-first']/@Value" />
     <xsl:variable name="VarLastTableCellWidth" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'table-cell-width-last']/@Value" />
     <xsl:variable name="VarEmitTableWidthsOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'table-use-document-cell-widths']/@Value" />
     <xsl:variable name="VarEmitTableWidths" select="($VarEmitTableWidthsOption = 'true') or (string-length($VarFirstTableCellWidth) &gt; 0) or (string-length($VarLastTableCellWidth) &gt; 0)" />
     <xsl:variable name="VarEmitFirstLastOnly" select="($VarEmitTableWidthsOption != 'true') and ((string-length($VarFirstTableCellWidth) &gt; 0) or (string-length($VarLastTableCellWidth) &gt; 0))" />
     <xsl:if test="$VarEmitTableWidths">
      <xsl:variable name="VarUsePercentageWidthsOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'table-use-percentage-cell-widths']/@Value" />
      <xsl:variable name="VarUsePercentageWidths" select="$VarUsePercentageWidthsOption = 'true'" />

      <!-- Determine table cell widths -->
      <!--                             -->
      <xsl:variable name="VarTableCellWidthsAsXML">
       <xsl:choose>
        <!-- Calculate percentage widths -->
        <!--                             -->
        <xsl:when test="$VarUsePercentageWidths">
         <xsl:call-template name="Table-CellWidthsAsPercentage">
          <xsl:with-param name="ParamTable" select="$ParamTable" />
          <xsl:with-param name="ParamReportAllCellWidths" select="false()" />
          <xsl:with-param name="ParamFirstTableCellWidth" select="$VarFirstTableCellWidth" />
          <xsl:with-param name="ParamLastTableCellWidth" select="$VarLastTableCellWidth" />
          <xsl:with-param name="ParamEmitFirstLastOnly" select="$VarEmitFirstLastOnly" />
         </xsl:call-template>
        </xsl:when>

        <xsl:otherwise>
         <xsl:call-template name="Table-CellWidths">
          <xsl:with-param name="ParamTable" select="$ParamTable" />
          <xsl:with-param name="ParamReportAllCellWidths" select="false()" />
          <xsl:with-param name="ParamFirstTableCellWidth" select="$VarFirstTableCellWidth" />
          <xsl:with-param name="ParamLastTableCellWidth" select="$VarLastTableCellWidth" />
          <xsl:with-param name="ParamEmitFirstLastOnly" select="$VarEmitFirstLastOnly" />
         </xsl:call-template>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:variable>
      <xsl:variable name="VarTableCellWidths" select="msxsl:node-set($VarTableCellWidthsAsXML)/*" />

      <!-- Emit column widths for all columns -->
      <!--                                    -->
      <xsl:for-each select="$ParamTable/wwdoc:TableColumns/wwdoc:TableColumn">
       <xsl:variable name="VarTableColumn" select="." />
       <xsl:variable name="VarTableColumnPosition" select="position()" />

       <xsl:variable name="VarSpecifiedColumnWidth">
        <xsl:variable name="VarFoundTableCellWidth" select="$VarTableCellWidths[@column = $VarTableColumnPosition][1]/@width" />
        <xsl:if test="string-length($VarFoundTableCellWidth) &gt; 0">
         <xsl:value-of select="$VarFoundTableCellWidth" />
        </xsl:if>
       </xsl:variable>

       <!-- Account for proportional column widths -->
       <!--                                        -->
       <xsl:variable name="VarColumnWidth">
        <xsl:variable name="VarColumnWidthUnits" select="wwunits:UnitsSuffix($VarSpecifiedColumnWidth)" />
        <xsl:choose>
         <xsl:when test="$VarColumnWidthUnits = '*'">
          <xsl:text>proportional-column-width(</xsl:text>
          <xsl:value-of select="wwunits:NumericPrefix($VarSpecifiedColumnWidth)" />
          <xsl:text>)</xsl:text>
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="$VarSpecifiedColumnWidth" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:variable>

       <fo:table-column column-number="{$VarTableColumnPosition}">
        <xsl:if test="string-length($VarColumnWidth) &gt; 0">
         <xsl:attribute name="column-width">
          <xsl:value-of select="$VarColumnWidth" />
         </xsl:attribute>
        </xsl:if>
       </fo:table-column>
      </xsl:for-each>
     </xsl:if>

     <!-- Order significant when processing sections -->
     <!--                                            -->
     <xsl:if test="count($ParamTable/wwdoc:TableHead/wwdoc:*[1]) = 1">
      <xsl:call-template name="Content-TableSection">
       <xsl:with-param name="ParamSectionTag" select="'table-header'" />
       <xsl:with-param name="ParamSection" select="$ParamTable/wwdoc:TableHead" />
       <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$VarCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamTable" select="$ParamTable" />
      </xsl:call-template>
     </xsl:if>

     <xsl:if test="count($ParamTable/wwdoc:TableFoot/wwdoc:*[1]) = 1">
      <xsl:call-template name="Content-TableSection">
       <xsl:with-param name="ParamSectionTag" select="'table-footer'" />
       <xsl:with-param name="ParamSection" select="$ParamTable/wwdoc:TableFoot" />
       <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$VarCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamTable" select="$ParamTable" />
      </xsl:call-template>
     </xsl:if>

     <xsl:if test="count($ParamTable/wwdoc:TableBody/wwdoc:*[1]) = 1">
      <xsl:call-template name="Content-TableSection">
       <xsl:with-param name="ParamSectionTag" select="'table-body'" />
       <xsl:with-param name="ParamSection" select="$ParamTable/wwdoc:TableBody" />
       <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$VarCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamTable" select="$ParamTable" />
      </xsl:call-template>
     </xsl:if>
    </fo:table>
   </fo:block>
  <!-- </fo:table-and-caption> -->

  <!-- Table Footnotes -->
  <!--                 -->
  <xsl:call-template name="Content-Notes">
   <xsl:with-param name="ParamNotes" select="$VarNotes" />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$VarCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:call-template>
 </xsl:template>

 <xsl:template name="Content-TableSection">
  <xsl:param name="ParamSectionTag" />
  <xsl:param name="ParamSection" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamTable" />


  <!-- Emit Section -->
  <!--              -->
  <xsl:element name="{$ParamSectionTag}" namespace="{$GlobalDefaultNamespace}">
   <xsl:attribute name="start-indent">0pt</xsl:attribute>
   <xsl:attribute name="end-indent">0pt</xsl:attribute>

   <!-- Resolve section properties -->
   <!--                            -->
   <xsl:variable name="VarResolvedSectionPropertiesAsXML">
    <xsl:call-template name="Properties-Table-Section-ResolveContextRule">
     <xsl:with-param name="ParamProperties" select="$ParamContextRule/wwproject:Properties/wwproject:Property" />
     <xsl:with-param name="ParamDocumentContext" select="$ParamTable" />
     <xsl:with-param name="ParamTable" select="$ParamTable" />
     <xsl:with-param name="ParamSection" select="$ParamSection" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarResolvedSectionProperties" select="msxsl:node-set($VarResolvedSectionPropertiesAsXML)/wwproject:Property" />

   <!-- FO properties -->
   <!--               -->
   <xsl:variable name="VarFOSectionPropertiesAsXML">
    <xsl:call-template name="FO-TranslateProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarResolvedSectionProperties" />
     <xsl:with-param name="ParamStyleType" select="'None'" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarFOSectionProperties" select="msxsl:node-set($VarFOSectionPropertiesAsXML)/wwproject:Property" />

   <xsl:for-each select="$VarFOSectionProperties">
    <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
   </xsl:for-each>

   <!-- Process section rows -->
   <!--                      -->
   <xsl:for-each select="$ParamSection/wwdoc:TableRow">
    <xsl:variable name="VarTableRow" select="." />
    <xsl:variable name="VarRowPosition" select="position()" />

    <fo:table-row>
     <!-- TODO: Implement a resolver for context table row properties -->
     <!--                                                             -->

     <!-- Apache FOP requires at least one table-cell with one block to validate -->
     <!--                                                                        -->
     <xsl:if test="count($VarTableRow/wwdoc:TableCell) &lt; 1">
      <fo:table-cell><fo:block/></fo:table-cell>    
     </xsl:if>

     <xsl:for-each select="$VarTableRow/wwdoc:TableCell">
      <xsl:variable name="VarTableCell" select="." />
      <xsl:variable name="VarCellPosition" select="position()" />

      <!-- Resolve cell properties -->
      <!--                         -->
      <xsl:variable name="VarResolvedCellPropertiesAsXML">
       <xsl:call-template name="Properties-Table-Cell-ResolveProperties">
        <xsl:with-param name="ParamSectionProperties" select="$VarResolvedSectionProperties" />
        <xsl:with-param name="ParamCellStyle" select="$VarTableCell/wwdoc:Style" />
        <xsl:with-param name="ParamRowIndex" select="$VarRowPosition" />
        <xsl:with-param name="ParamColumnIndex" select="$VarCellPosition" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResolvedCellProperties" select="msxsl:node-set($VarResolvedCellPropertiesAsXML)/wwproject:Property" />

      <!-- FO properties -->
      <!--               -->
      <xsl:variable name="VarFOCellPropertiesAsXML">
       <xsl:call-template name="FO-TranslateProjectProperties">
        <xsl:with-param name="ParamProperties" select="$VarResolvedCellProperties" />
        <xsl:with-param name="ParamStyleType" select="'None'" />
       </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarFOCellProperties" select="msxsl:node-set($VarFOCellPropertiesAsXML)/wwproject:Property" />

      <!-- Calculate row span -->
      <!--                    -->
      <xsl:variable name="VarRowSpan">
       <xsl:variable name="VarRowSpanHint" select="$VarTableCell/wwdoc:Style/wwdoc:Attribute[@name = 'row-span']/@value" />
       <xsl:choose>
        <xsl:when test="string-length($VarRowSpanHint) &gt; 0">
         <xsl:value-of select="$VarRowSpanHint" />
        </xsl:when>
        <xsl:otherwise>
         <xsl:value-of select="'0'" />
        </xsl:otherwise>
       </xsl:choose>
      </xsl:variable>

      <!-- Calculate column span -->
      <!--                       -->
      <xsl:variable name="VarColumnSpan">
       <xsl:variable name="VarColumnSpanHint" select="$VarTableCell/wwdoc:Style/wwdoc:Attribute[@name = 'column-span']/@value" />
       <xsl:choose>
        <xsl:when test="string-length($VarColumnSpanHint) &gt; 0">
         <xsl:value-of select="$VarColumnSpanHint" />
        </xsl:when>
        <xsl:otherwise>
         <xsl:value-of select="'0'" />
        </xsl:otherwise>
       </xsl:choose>
      </xsl:variable>

      <!-- Emit cell -->
      <!--           -->
      <fo:table-cell>
       <xsl:for-each select="$VarFOCellProperties">
        <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
       </xsl:for-each>

       <!-- Row span attribute -->
       <!--                    -->
       <xsl:if test="number($VarRowSpan) &gt; 0">
        <xsl:attribute name="number-rows-spanned">
         <xsl:value-of select="$VarRowSpan" />
        </xsl:attribute>
       </xsl:if>

       <!-- Column span attribute -->
       <!--                       -->
       <xsl:if test="number($VarColumnSpan) &gt; 0">
        <xsl:attribute name="number-columns-spanned">
         <xsl:value-of select="$VarColumnSpan" />
        </xsl:attribute>
       </xsl:if>

       <!-- Don't emit empty table cells -->
       <!--                              -->
       <xsl:choose>
        <xsl:when test="count(.//wwdoc:Text[1] | ./wwdoc:Frame[1] | ./wwdoc:Table[1]) &gt; 0">
         <!-- Recurse -->
         <!--         -->
         <xsl:apply-templates select="./*" mode="wwmode:content">
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamCargo" select="$ParamCargo" />
          <xsl:with-param name="ParamLinks" select="$ParamLinks" />
          <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
          <xsl:with-param name="ParamSplit" select="$ParamSplit" />
         </xsl:apply-templates>
        </xsl:when>

        <xsl:otherwise>
         <fo:block> &#x00A0; </fo:block>
        </xsl:otherwise>
       </xsl:choose>
      </fo:table-cell>
     </xsl:for-each>

    </fo:table-row>
   </xsl:for-each>
  </xsl:element>
 </xsl:template>


 <xsl:template match="wwdoc:Frame" mode="wwmode:content">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:if test="not(wwprogress:Abort())">
   <fo:block>
    <xsl:call-template name="Frame">
     <xsl:with-param name="ParamFrame" select="." />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$ParamCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    </xsl:call-template>
   </fo:block>
  </xsl:if>

 </xsl:template>

 <xsl:template match="wwdoc:Frame" mode="wwmode:nestedcontent">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamTOCData" />
  <xsl:param name="ParamSplit" />

  <xsl:apply-templates select="." mode="wwmode:content">
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamTOCData" select="$ParamTOCData" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:apply-templates>
 </xsl:template>

 <xsl:template match="wwdoc:Frame" mode="wwmode:textrun">
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <xsl:call-template name="Frame">
   <xsl:with-param name="ParamFrame" select="." />
   <xsl:with-param name="ParamSplits" select="$ParamSplits" />
   <xsl:with-param name="ParamCargo" select="$ParamCargo" />
   <xsl:with-param name="ParamLinks" select="$ParamLinks" />
   <xsl:with-param name="ParamSplit" select="$ParamSplit" />
  </xsl:call-template>
 </xsl:template>

 <xsl:template name="Frame">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />

  <!-- Get splits frame -->
  <!--                  -->
  <xsl:for-each select="$ParamSplits[1]">
   <xsl:variable name="VarSplitsFrame" select="key('wwsplits-frames-by-id', $ParamFrame/@id)[@documentID = $ParamSplit/@documentID]" />

   <!-- Frame known? -->
   <!--              -->
   <xsl:if test="count($VarSplitsFrame) = 1">
    <!-- Thumbnail? -->
    <!--            -->
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarSplitsThumbnail" select="$VarSplitsFrame/wwsplits:Thumbnail" />
     <xsl:variable name="VarThumbnailDefined" select="(string-length($VarSplitsThumbnail/@path) &gt; 0) and wwfilesystem:FileExists($VarSplitsThumbnail/@path)" />

     <!-- Emit image -->
     <!--            -->
     <xsl:choose>
      <!-- Thumbnail -->
      <!--           -->
      <xsl:when test="$VarThumbnailDefined">
       <!-- Emit markup -->
       <!--             -->
       <xsl:call-template name="Frame-Markup">
        <xsl:with-param name="ParamFrame" select="$ParamFrame" />
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$ParamCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamSplitsFrame" select="$VarSplitsFrame" />
        <xsl:with-param name="ParamThumbnail" select="true()" />
       </xsl:call-template>
      </xsl:when>

      <!-- Fullsize -->
      <!--          -->
      <xsl:otherwise>
       <!-- Note numbering -->
       <!--                -->
       <xsl:variable name="VarNotes" select="$ParamFrame//wwdoc:Note" />
       <xsl:variable name="VarNoteNumberingAsXML">
        <xsl:call-template name="Notes-Number">
         <xsl:with-param name="ParamNotes" select="$VarNotes" />
        </xsl:call-template>
       </xsl:variable>
       <xsl:variable name="VarNoteNumbering" select="msxsl:node-set($VarNoteNumberingAsXML)" />

       <!-- Frame cargo -->
       <!--             -->
       <xsl:variable name="VarCargo" select="$ParamCargo/*[local-name() != 'NoteNumbering']/.. | $VarNoteNumbering" />

       <!-- Emit markup -->
       <!--             -->
       <xsl:call-template name="Frame-Markup">
        <xsl:with-param name="ParamFrame" select="$ParamFrame" />
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$VarCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamSplitsFrame" select="$VarSplitsFrame" />
        <xsl:with-param name="ParamThumbnail" select="false()" />
       </xsl:call-template>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:for-each>
   </xsl:if>
  </xsl:for-each>
 </xsl:template>

 <xsl:template name="Frame-Markup">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamThumbnail" />

  <!-- Context Rule -->
  <!--              -->
  <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Graphic', $ParamSplitsFrame/@stylename, $ParamSplitsFrame/@documentID, $ParamSplitsFrame/@id)" />

  <!-- Generate? -->
  <!--           -->
  <xsl:variable name="VarGenerateOutputOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
  <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
  <xsl:if test="$VarGenerateOutput">
   <!-- Media file exists? -->
   <!--                    -->
   <xsl:variable name="VarSplitsMedia" select="$ParamSplitsFrame/wwsplits:Media[1]" />
   <xsl:choose>
    <!-- Media file exists -->
    <!--                   -->
    <xsl:when test="count($VarSplitsMedia) = 1">
     <xsl:call-template name="Frame-Markup-Media">
      <xsl:with-param name="ParamFrame" select="$ParamFrame" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
      <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
      <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
      <xsl:with-param name="ParamSplitsMedia" select="$VarSplitsMedia" />
     </xsl:call-template>
    </xsl:when>

    <!-- Document image -->
    <!--                -->
    <xsl:otherwise>
     <xsl:call-template name="Frame-Markup-Document-Image">
      <xsl:with-param name="ParamFrame" select="$ParamFrame" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
      <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
      <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
     </xsl:call-template>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:if>
 </xsl:template>

 <xsl:template name="Frame-Markup-Media">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamThumbnail" />
  <xsl:param name="ParamSplitsMedia" />

  <!-- Handle media link -->
  <!--                   -->
  <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($ParamSplitsMedia/@path, $ParamSplit/@path)" />
  <xsl:variable name="VarMediaURL">
   <xsl:text>url('</xsl:text>
   <xsl:value-of select="$VarRelativePath" />
   <xsl:text>')</xsl:text>
  </xsl:variable>

  <!-- Retrieve image markup -->
  <!--                       -->
  <xsl:variable name="VarImageMarkupAsXML">
   <xsl:call-template name="Frame-Markup-Document-Image">
    <xsl:with-param name="ParamFrame" select="$ParamFrame" />
    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
    <xsl:with-param name="ParamCargo" select="$ParamCargo" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
    <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
    <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
   </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="VarImageMarkup" select="msxsl:node-set($VarImageMarkupAsXML)/*" />

  <!-- Link to external media -->
  <!--                        -->
  <xsl:choose>
   <!-- Image markup defined -->
   <!--                      -->
   <xsl:when test="count($VarImageMarkup) &gt; 0">
    <!-- Emit image markup -->
    <!--                   -->
    <xsl:choose>
     <!-- Block image -->
     <!--             -->
     <xsl:when test="(local-name($VarImageMarkup[1]) = 'block') and (namespace-uri($VarImageMarkup[1]) = 'http://www.w3.org/1999/XSL/Format')">
      <fo:block>
       <fo:basic-link external-destination="{$VarMediaURL}">
        <xsl:copy-of select="$VarImageMarkup/*" />
       </fo:basic-link>
      </fo:block>
     </xsl:when>

     <!-- Inline image -->
     <!--              -->
     <xsl:otherwise>
      <fo:basic-link external-destination="{$VarMediaURL}">
       <xsl:copy-of select="$VarImageMarkup" />
      </fo:basic-link>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:when>

   <!-- Link around media filename -->
   <!--                            -->
   <xsl:otherwise>
    <fo:basic-link external-destination="{$VarMediaURL}">
     <xsl:value-of select="$ParamSplitsMedia/@title" />
    </fo:basic-link>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="Frame-Markup-Document-Image">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamThumbnail" />

  <!-- Document facet defined? -->
  <!--                         -->
  <xsl:if test="count($ParamFrame/wwdoc:Facets[1]/wwdoc:Facet[@type = 'document'][1]) = 1">
   <!-- Determine image path -->
   <!--                      -->
   <xsl:variable name="VarImagePath">
    <xsl:choose>
     <xsl:when test="$ParamThumbnail">
      <xsl:value-of select="$ParamSplitsFrame/wwsplits:Thumbnail/@path" />
     </xsl:when>

     <xsl:otherwise>
      <xsl:value-of select="$ParamSplitsFrame/@path" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Access image info -->
   <!--                   -->
   <xsl:variable name="VarImageInfo" select="wwimaging:GetInfo($VarImagePath)" />

   <!-- Determine type -->
   <!--                -->
   <xsl:variable name="VarVectorImageAsText">
    <xsl:call-template name="Images-VectorImageFormat">
     <xsl:with-param name="ParamImageInfo" select="$VarImageInfo" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarVectorImage" select="$VarVectorImageAsText = string(true())" />
   <xsl:variable name="VarRasterImageAsText">
    <xsl:call-template name="Images-RasterImageFormat">
     <xsl:with-param name="ParamImageInfo" select="$VarImageInfo" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarRasterImage" select="$VarRasterImageAsText = string(true())" />

   <!-- Emit image -->
   <!--            -->
   <xsl:choose>
    <!-- Vector Image -->
    <!--              -->
    <xsl:when test="$VarVectorImage">
     <xsl:call-template name="Frame-Markup-Vector">
      <xsl:with-param name="ParamFrame" select="$ParamFrame" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
      <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
      <xsl:with-param name="ParamImageInfo" select="$VarImageInfo" />
      <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
     </xsl:call-template>
    </xsl:when>

    <!-- Raster Image -->
    <!--              -->
    <xsl:when test="$VarRasterImage">
     <xsl:call-template name="Frame-Markup-Raster">
      <xsl:with-param name="ParamFrame" select="$ParamFrame" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
      <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
      <xsl:with-param name="ParamImageInfo" select="$VarImageInfo" />
      <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
     </xsl:call-template>
    </xsl:when>
   </xsl:choose>
  </xsl:if>
 </xsl:template>

 <xsl:template name="Frame-Markup-Vector">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamImageInfo" />
  <xsl:param name="ParamThumbnail" />

  <xsl:choose>
   <!-- SVG -->
   <!--     -->
   <xsl:when test="$ParamImageInfo/@format = 'svg'">
    <xsl:call-template name="Frame-Markup-Vector-SVG">
     <xsl:with-param name="ParamFrame" select="$ParamFrame" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$ParamCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
     <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
     <xsl:with-param name="ParamImageInfo" select="$ParamImageInfo" />
     <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
    </xsl:call-template>
   </xsl:when>
  </xsl:choose>
 </xsl:template>

 <!-- SVG-PageDimensionPt: Extract a page layout dimension as points.           -->
 <!-- Returns the property value converted to points, or the default if absent. -->
 <!--                                                                           -->
 <xsl:template name="SVG-PageDimensionPt">
  <xsl:param name="ParamPageRule" />
  <xsl:param name="ParamPropertyName" />
  <xsl:param name="ParamDefaultPt" />

  <xsl:variable name="VarRawValue" select="$ParamPageRule/wwproject:Properties/wwproject:Property[@Name = $ParamPropertyName]/@Value" />
  <xsl:choose>
   <xsl:when test="string-length($VarRawValue) &gt; 0">
    <xsl:value-of select="wwunits:Convert(wwunits:NumericPrefix($VarRawValue), wwunits:UnitsSuffix($VarRawValue), 'pt')" />
   </xsl:when>
   <xsl:otherwise>
    <xsl:value-of select="$ParamDefaultPt" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="Frame-Markup-Vector-SVG">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamImageInfo" />
  <xsl:param name="ParamThumbnail" />

  <!-- Access frame behavior -->
  <!--                       -->
  <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
   <xsl:variable name="VarBehaviorFrame" select="key('wwbehaviors-frames-by-id', $ParamFrame/@id)[1]" />

   <!-- Resolve project properties -->
   <!--                            -->
   <xsl:variable name="VarResolvedPropertiesAsXML">
    <xsl:call-template name="Properties-ResolveContextRule">
     <xsl:with-param name="ParamDocumentContext" select="$ParamFrame" />
     <xsl:with-param name="ParamProperties" select="$ParamContextRule/wwproject:Properties/wwproject:Property" />
     <xsl:with-param name="ParamStyleName" select="$ParamFrame/@stylename" />
     <xsl:with-param name="ParamStyleType" select="'Graphic'" />
     <xsl:with-param name="ParamContextStyle" select="$ParamFrame" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

   <!-- FO properties -->
   <!--               -->
   <xsl:variable name="VarFOPropertiesAsXML">
    <xsl:call-template name="FO-TranslateProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarResolvedProperties[((@Name != 'width') and (@Name != 'height')) or (@Source = 'Explicit')]" />
     <xsl:with-param name="ParamStyleType" select="'Graphic'" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarFOProperties" select="msxsl:node-set($VarFOPropertiesAsXML)/wwproject:Property" />

   <!-- Width/Height -->
   <!--              -->
   <xsl:variable name="VarByReferenceGraphicsUseDocumentDimensionsOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'by-reference-use-document-dimensions']/@Value" />
   <xsl:variable name="VarByReferenceGraphicsUseDocumentDimensions" select="(string-length($VarByReferenceGraphicsUseDocumentDimensionsOption) = 0) or ($VarByReferenceGraphicsUseDocumentDimensionsOption = 'true')" />
   <xsl:variable name="VarWidth">
    <xsl:choose>
     <xsl:when test="count($VarResolvedProperties[@Name = 'width']) = 0">
      <xsl:value-of select="number($ParamImageInfo/@width)" />
     </xsl:when>

     <xsl:when test="$ParamThumbnail">
      <xsl:value-of select="number($ParamImageInfo/@width)" />
     </xsl:when>

     <xsl:when test="($ParamSplitsFrame/@byref = 'true') and (($VarByReferenceGraphicsUseDocumentDimensions) or (number($ParamImageInfo/@width) = 0))">
      <xsl:variable name="VarByReferenceFrame" select="$ParamFrame//wwdoc:Facet[@type = 'by-reference'][1]/../.." />

      <xsl:value-of select="$VarByReferenceFrame/wwdoc:Attribute[@name = 'width']/@value" />
      <xsl:if test="string-length(wwunits:UnitsSuffix($VarByReferenceFrame/wwdoc:Attribute[@name = 'width']/@value)) = 0">
       <xsl:text>pt</xsl:text>
      </xsl:if>
     </xsl:when>

     <xsl:otherwise>
      <!-- Property defined? -->
      <!--                   -->
      <xsl:variable name="VarOptionMaxDimensionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-width']/@Value" />
      <xsl:variable name="VarOptionMaxDimension" select="($VarOptionMaxDimensionValue != 'none') and (string-length($VarOptionMaxDimensionValue &gt; 0)) and (number($VarOptionMaxDimensionValue) &gt; 0)" />
      <xsl:variable name="VarOptionScaleValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />
      <xsl:variable name="VarOptionScale" select="($VarOptionScaleValue != 'none') and (string-length($VarOptionScaleValue &gt; 0)) and (number($VarOptionScaleValue) &gt; 0)" />
      <xsl:variable name="VarPropertyDimension" select="$VarResolvedProperties[@Name = 'width' and @Source = 'Explicit']/@Value" />
      <xsl:choose>
       <!-- Use property defined dimension -->
       <!--                                -->
       <xsl:when test="not($VarOptionMaxDimension) and not($VarOptionScale) and (string-length($VarPropertyDimension) &gt; 0)">
        <xsl:variable name="VarDimensionPrefix" select="wwunits:NumericPrefix($VarPropertyDimension)" />
        <xsl:variable name="VarDimensionSuffix" select="wwunits:UnitsSuffix($VarPropertyDimension)" />
        <xsl:choose>
         <xsl:when test="$VarDimensionSuffix = '%'">
          <xsl:value-of select="$VarPropertyDimension" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="wwunits:Convert($VarDimensionPrefix, $VarDimensionSuffix, 'pt')" />
          <xsl:text>pt</xsl:text>
         </xsl:otherwise>
        </xsl:choose>
       </xsl:when>

       <!-- Use image info dimension -->
       <!--                          -->
       <xsl:otherwise>
        <xsl:value-of select="number($ParamImageInfo/@width)" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <xsl:variable name="VarHeight">
    <xsl:choose>
     <xsl:when test="count($VarResolvedProperties[@Name = 'height']) = 0">
      <xsl:value-of select="number($ParamImageInfo/@height)" />
     </xsl:when>

     <xsl:when test="$ParamThumbnail">
      <xsl:value-of select="number($ParamImageInfo/@height)" />
     </xsl:when>

     <xsl:when test="($ParamSplitsFrame/@byref = 'true') and (($VarByReferenceGraphicsUseDocumentDimensions) or (number($ParamImageInfo/@height) = 0))">
      <xsl:variable name="VarByReferenceFrame" select="$ParamFrame//wwdoc:Facet[@type = 'by-reference'][1]/../.." />

      <xsl:value-of select="$VarByReferenceFrame/wwdoc:Attribute[@name = 'height']/@value" />
      <xsl:if test="string-length(wwunits:UnitsSuffix($VarByReferenceFrame/wwdoc:Attribute[@name = 'height']/@value)) = 0">
       <xsl:text>pt</xsl:text>
      </xsl:if>
     </xsl:when>

     <xsl:otherwise>
      <!-- Property defined? -->
      <!--                   -->
      <xsl:variable name="VarOptionMaxDimensionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-height']/@Value" />
      <xsl:variable name="VarOptionMaxDimension" select="($VarOptionMaxDimensionValue != 'none') and (string-length($VarOptionMaxDimensionValue &gt; 0)) and (number($VarOptionMaxDimensionValue) &gt; 0)" />
      <xsl:variable name="VarOptionScaleValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />
      <xsl:variable name="VarOptionScale" select="($VarOptionScaleValue != 'none') and (string-length($VarOptionScaleValue &gt; 0)) and (number($VarOptionScaleValue) &gt; 0)" />
      <xsl:variable name="VarPropertyDimension" select="$VarResolvedProperties[@Name = 'height' and @Source = 'Explicit']/@Value" />
      <xsl:choose>
       <!-- Use property defined dimension -->
       <!--                                -->
       <xsl:when test="not($VarOptionMaxDimension) and not($VarOptionScale) and (string-length($VarPropertyDimension) &gt; 0)">
        <xsl:variable name="VarDimensionPrefix" select="wwunits:NumericPrefix($VarPropertyDimension)" />
        <xsl:variable name="VarDimensionSuffix" select="wwunits:UnitsSuffix($VarPropertyDimension)" />
        <xsl:choose>
         <xsl:when test="$VarDimensionSuffix = '%'">
          <xsl:value-of select="$VarPropertyDimension" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="wwunits:Convert($VarDimensionPrefix, $VarDimensionSuffix, 'pt')" />
          <xsl:text>pt</xsl:text>
         </xsl:otherwise>
        </xsl:choose>
       </xsl:when>

       <!-- Use image info dimension -->
       <!--                          -->
       <xsl:otherwise>
        <xsl:value-of select="number($ParamImageInfo/@height)" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- SVG proportional constraint                                         -->
   <!-- Compute effective width in points for the FO viewport,              -->
   <!-- applying max-width/max-height and scale constraints proportionally. -->
   <!-- SVG viewBox units map 1:1 to points in FOP at default 72 DPI,      -->
   <!-- so ParamImageInfo/@width gives the intrinsic width in points.       -->
   <!-- Max-width/max-height option values are in the same unit system.     -->
   <!--                                                                     -->
   <xsl:variable name="VarSVGIntrinsicWidth" select="number($ParamImageInfo/@width)" />
   <xsl:variable name="VarSVGIntrinsicHeight" select="number($ParamImageInfo/@height)" />

   <xsl:variable name="VarSVGMaxWidth">
    <xsl:call-template name="Images-MaxSizeOption">
     <xsl:with-param name="ParamMaxSizeOptionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-width']/@Value" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarSVGMaxHeight">
    <xsl:call-template name="Images-MaxSizeOption">
     <xsl:with-param name="ParamMaxSizeOptionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-height']/@Value" />
    </xsl:call-template>
   </xsl:variable>

   <xsl:variable name="VarSVGScaleOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />

   <!-- Apply scale to intrinsic dimensions -->
   <!--                                     -->
   <xsl:variable name="VarSVGBaseWidth">
    <xsl:choose>
     <xsl:when test="(string-length($VarSVGScaleOption) &gt; 0) and ($VarSVGScaleOption != 'none') and (number($VarSVGScaleOption) &gt; 0)">
      <xsl:value-of select="$VarSVGIntrinsicWidth * number($VarSVGScaleOption) div 100" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="$VarSVGIntrinsicWidth" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <xsl:variable name="VarSVGBaseHeight">
    <xsl:choose>
     <xsl:when test="(string-length($VarSVGScaleOption) &gt; 0) and ($VarSVGScaleOption != 'none') and (number($VarSVGScaleOption) &gt; 0)">
      <xsl:value-of select="$VarSVGIntrinsicHeight * number($VarSVGScaleOption) div 100" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="$VarSVGIntrinsicHeight" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Compute proportionally-constrained effective width (points)         -->
   <!-- When both max-width and max-height are set, find the limiting       -->
   <!-- dimension and scale proportionally. Only scale DOWN (not up).       -->
   <!--                                                                     -->
   <xsl:variable name="VarSVGEffectiveWidth">
    <xsl:choose>
     <!-- Both max-width and max-height set: proportional fit -->
     <!--                                                     -->
     <xsl:when test="(number($VarSVGMaxWidth) &gt; 0) and (number($VarSVGMaxHeight) &gt; 0) and (number($VarSVGBaseWidth) &gt; 0) and (number($VarSVGBaseHeight) &gt; 0)">
      <xsl:variable name="VarScaleW" select="number($VarSVGMaxWidth) div number($VarSVGBaseWidth)" />
      <xsl:variable name="VarScaleH" select="number($VarSVGMaxHeight) div number($VarSVGBaseHeight)" />
      <xsl:variable name="VarMinScale">
       <xsl:choose>
        <xsl:when test="$VarScaleW &lt; $VarScaleH">
         <xsl:value-of select="$VarScaleW" />
        </xsl:when>
        <xsl:otherwise>
         <xsl:value-of select="$VarScaleH" />
        </xsl:otherwise>
       </xsl:choose>
      </xsl:variable>
      <xsl:choose>
       <xsl:when test="number($VarMinScale) &lt; 1">
        <xsl:value-of select="number($VarSVGBaseWidth) * number($VarMinScale)" />
       </xsl:when>
       <xsl:otherwise>
        <xsl:value-of select="number($VarSVGBaseWidth)" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:when>

     <!-- Only max-width set and image exceeds it -->
     <!--                                         -->
     <xsl:when test="(number($VarSVGMaxWidth) &gt; 0) and (number($VarSVGBaseWidth) &gt; number($VarSVGMaxWidth))">
      <xsl:value-of select="number($VarSVGMaxWidth)" />
     </xsl:when>

     <!-- Only max-height set and image exceeds it: compute proportional width -->
     <!--                                                                      -->
     <xsl:when test="(number($VarSVGMaxHeight) &gt; 0) and (number($VarSVGBaseHeight) &gt; number($VarSVGMaxHeight)) and (number($VarSVGBaseHeight) &gt; 0)">
      <xsl:value-of select="number($VarSVGBaseWidth) * (number($VarSVGMaxHeight) div number($VarSVGBaseHeight))" />
     </xsl:when>

     <!-- No constraint or within limits: use base width -->
     <!--                                                -->
     <xsl:otherwise>
      <xsl:value-of select="number($VarSVGBaseWidth)" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Content area width from page layout (for SVG viewport capping)          -->
   <!-- FOP requires fixed pt values for both width and height on SVG external- -->
   <!-- graphics. The min() FO expression and content-height="auto" both cause  -->
   <!-- FOP to use the SVG intrinsic viewBox height, creating dead space.       -->
   <!-- We compute the content area width here so we can cap oversized SVGs     -->
   <!-- and always output fixed pt viewport dimensions.                         -->
   <!--                                                                         -->
   <xsl:variable name="VarSVGPageRule" select="wwprojext:GetRule('Page', $ParamSplit/@stylename)" />

   <xsl:variable name="VarSVGPageWidthPt">
    <xsl:call-template name="SVG-PageDimensionPt">
     <xsl:with-param name="ParamPageRule" select="$VarSVGPageRule" />
     <xsl:with-param name="ParamPropertyName" select="'odd-master-page-width'" />
     <xsl:with-param name="ParamDefaultPt" select="612" />
    </xsl:call-template>
   </xsl:variable>

   <xsl:variable name="VarSVGPageMarginLeftPt">
    <xsl:call-template name="SVG-PageDimensionPt">
     <xsl:with-param name="ParamPageRule" select="$VarSVGPageRule" />
     <xsl:with-param name="ParamPropertyName" select="'odd-master-page-margin-left'" />
     <xsl:with-param name="ParamDefaultPt" select="18" />
    </xsl:call-template>
   </xsl:variable>

   <xsl:variable name="VarSVGPageMarginRightPt">
    <xsl:call-template name="SVG-PageDimensionPt">
     <xsl:with-param name="ParamPageRule" select="$VarSVGPageRule" />
     <xsl:with-param name="ParamPropertyName" select="'odd-master-page-margin-right'" />
     <xsl:with-param name="ParamDefaultPt" select="18" />
    </xsl:call-template>
   </xsl:variable>

   <xsl:variable name="VarSVGBodyMarginLeftPt">
    <xsl:call-template name="SVG-PageDimensionPt">
     <xsl:with-param name="ParamPageRule" select="$VarSVGPageRule" />
     <xsl:with-param name="ParamPropertyName" select="'odd-master-page-body-margin-left'" />
     <xsl:with-param name="ParamDefaultPt" select="54" />
    </xsl:call-template>
   </xsl:variable>

   <xsl:variable name="VarSVGBodyMarginRightPt">
    <xsl:call-template name="SVG-PageDimensionPt">
     <xsl:with-param name="ParamPageRule" select="$VarSVGPageRule" />
     <xsl:with-param name="ParamPropertyName" select="'odd-master-page-body-margin-right'" />
     <xsl:with-param name="ParamDefaultPt" select="54" />
    </xsl:call-template>
   </xsl:variable>

   <xsl:variable name="VarSVGContentAreaWidthPt" select="number($VarSVGPageWidthPt) - number($VarSVGPageMarginLeftPt) - number($VarSVGPageMarginRightPt) - number($VarSVGBodyMarginLeftPt) - number($VarSVGBodyMarginRightPt)" />

   <!-- Cap SVG effective width at content area width                            -->
   <!-- When the SVG intrinsic width exceeds the content area, cap so that       -->
   <!-- both viewport dimensions are known fixed values at XSLT time.            -->
   <!--                                                                          -->
   <xsl:variable name="VarSVGCappedWidth">
    <xsl:choose>
     <xsl:when test="(number($VarSVGContentAreaWidthPt) &gt; 0) and (number($VarSVGEffectiveWidth) &gt; number($VarSVGContentAreaWidthPt))">
      <xsl:value-of select="number($VarSVGContentAreaWidthPt)" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="number($VarSVGEffectiveWidth)" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Proportional height from capped width                                    -->
   <!--                                                                          -->
   <xsl:variable name="VarSVGCappedHeight">
    <xsl:choose>
     <xsl:when test="number($VarSVGBaseWidth) &gt; 0">
      <xsl:value-of select="number($VarSVGBaseHeight) * (number($VarSVGCappedWidth) div number($VarSVGBaseWidth))" />
     </xsl:when>
     <xsl:otherwise>
      <xsl:value-of select="number($VarSVGBaseHeight)" />
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Ensure SVG has width/height attributes for FOP/Batik -->
   <!--                                                      -->
   <xsl:variable name="VarSVGPatched" select="wwimaging:EnsureSVGDimensions(string($ParamImageInfo/@path))" />

   <!-- Src -->
   <!--     -->
   <xsl:variable name="VarSrc" select="wwuri:AsURI($ParamImageInfo/@path)" />

   <!-- Inline or block -->
   <!--                 -->
   <xsl:variable name="VarBlock" select="$VarResolvedProperties[(@Name = 'display') and (@Value = 'block')]/@Value = 'block'" />
   <xsl:choose>
    <!-- Block -->
    <!--       -->
    <xsl:when test="$VarBlock">
     <!-- center or right -->
     <!--                 -->
     <xsl:variable name="VarTextAlign" select="$VarResolvedProperties[(@Name = 'text-align') and ((@Value = 'center') or (@Value = 'right'))]/@Value" />

     <!-- left or right -->
     <!--               -->
     <xsl:variable name="VarFloat" select="$VarResolvedProperties[(@Name = 'float') and ((@Value = 'left') or (@Value = 'right'))]/@Value" />

     <xsl:choose>
      <!-- Float -->
      <!--       -->

      <xsl:when test="$VarFloat">
       <fo:float>
        <xsl:choose>
         <!-- left -->
         <!--      -->
         <xsl:when test="$VarFloat = 'left'">
          <xsl:attribute name="float">
           <xsl:text>start</xsl:text>
          </xsl:attribute>
         </xsl:when>

         <!-- right -->
         <!--       -->
         <xsl:otherwise>
          <xsl:attribute name="float">
           <xsl:text>end</xsl:text>
          </xsl:attribute>
         </xsl:otherwise>
        </xsl:choose>

        <fo:block>
         <!-- text-align -->
         <!--            -->
         <xsl:if test="$VarTextAlign">
          <xsl:attribute name="text-align">
           <xsl:value-of select="$VarTextAlign" />
          </xsl:attribute>
         </xsl:if>

         <xsl:call-template name="Frame-Markup-External-Graphic-With-Link">
          <xsl:with-param name="ParamFrame" select="$ParamFrame" />
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamCargo" select="$ParamCargo" />
          <xsl:with-param name="ParamLinks" select="$ParamLinks" />
          <xsl:with-param name="ParamSplit" select="$ParamSplit" />
          <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
          <xsl:with-param name="ParamSrc" select="$VarSrc" />
          <xsl:with-param name="ParamWidth" select="$VarSVGCappedWidth" />
          <xsl:with-param name="ParamHeight" select="$VarSVGCappedHeight" />
          <xsl:with-param name="ParamFOProperties" select="$VarFOProperties" />
         </xsl:call-template>
        </fo:block>
       </fo:float>
      </xsl:when>

      <xsl:otherwise>
       <fo:block>
        <!-- text-align -->
        <!--            -->
        <xsl:if test="$VarTextAlign">
         <xsl:attribute name="text-align">
          <xsl:value-of select="$VarTextAlign" />
         </xsl:attribute>
        </xsl:if>

        <xsl:call-template name="Frame-Markup-External-Graphic-With-Link">
         <xsl:with-param name="ParamFrame" select="$ParamFrame" />
         <xsl:with-param name="ParamSplits" select="$ParamSplits" />
         <xsl:with-param name="ParamCargo" select="$ParamCargo" />
         <xsl:with-param name="ParamLinks" select="$ParamLinks" />
         <xsl:with-param name="ParamSplit" select="$ParamSplit" />
         <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
         <xsl:with-param name="ParamSrc" select="$VarSrc" />
         <xsl:with-param name="ParamWidth" select="$VarSVGCappedWidth" />
         <xsl:with-param name="ParamHeight" select="$VarSVGCappedHeight" />
         <xsl:with-param name="ParamFOProperties" select="$VarFOProperties" />
        </xsl:call-template>
       </fo:block>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:when>

    <!-- Inline -->
    <!--        -->
    <xsl:otherwise>
     <fo:inline>
      <xsl:call-template name="Frame-Markup-External-Graphic-With-Link">
       <xsl:with-param name="ParamFrame" select="$ParamFrame" />
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
       <xsl:with-param name="ParamSrc" select="$VarSrc" />
       <xsl:with-param name="ParamWidth" select="$VarSVGCappedWidth" />
       <xsl:with-param name="ParamHeight" select="$VarSVGCappedHeight" />
       <xsl:with-param name="ParamFOProperties" select="$VarFOProperties" />
      </xsl:call-template>
     </fo:inline>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:for-each>
 </xsl:template>

 <xsl:template name="Frame-Markup-Instream-Foreign-Object">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamThumbnail" />
  <xsl:param name="ParamImagePath" />
  <xsl:param name="ParamWidth" />
  <xsl:param name="ParamHeight" />
  <xsl:param name="ParamFOProperties" />

  <!-- Graphic element -->
  <!--                 -->
  <fo:instream-foreign-object id="w{ParamSplit/@groupID}_{$ParamSplit/@documentID}_{$ParamFrame/@id}">
   <xsl:variable name="VarSvg" select="wwexsldoc:LoadXMLWithoutResolver($ParamImagePath)" />
   <xsl:copy-of select="$VarSvg"/>

   <!-- Iterate other props -->
   <!--                     -->
   <xsl:for-each select="$ParamFOProperties">
    <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
   </xsl:for-each>
  </fo:instream-foreign-object>

  <!-- Notes -->
  <!--       -->
  <xsl:choose>
   <!-- Thumbnail -->
   <!--           -->
   <xsl:when test="$ParamThumbnail">
    <!-- Nothing to do -->
    <!--               -->
   </xsl:when>

   <!-- Fullsize -->
   <!--          -->
   <xsl:otherwise>
    <!-- Frame Footnotes -->
    <!--                 -->
    <xsl:variable name="VarNotes" select="$ParamFrame//wwdoc:Note" />
    <xsl:call-template name="Content-Notes">
     <xsl:with-param name="ParamNotes" select="$VarNotes" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$ParamCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamTOCData" select="''" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="Frame-Markup-Raster">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamSplitsFrame" />
  <xsl:param name="ParamContextRule" />
  <xsl:param name="ParamImageInfo" />
  <xsl:param name="ParamThumbnail" />

  <!-- Access frame behavior -->
  <!--                       -->
  <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
   <xsl:variable name="VarBehaviorFrame" select="key('wwbehaviors-frames-by-id', $ParamFrame/@id)[1]" />

   <!-- Resolve project properties -->
   <!--                            -->
   <xsl:variable name="VarResolvedPropertiesAsXML">
    <xsl:call-template name="Properties-ResolveContextRule">
     <xsl:with-param name="ParamDocumentContext" select="$ParamFrame" />
     <xsl:with-param name="ParamProperties" select="$ParamContextRule/wwproject:Properties/wwproject:Property" />
     <xsl:with-param name="ParamStyleName" select="$ParamFrame/@stylename" />
     <xsl:with-param name="ParamStyleType" select="'Graphic'" />
     <xsl:with-param name="ParamContextStyle" select="$ParamFrame" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

   <!-- FO properties -->
   <!--               -->
   <xsl:variable name="VarFOPropertiesAsXML">
    <xsl:call-template name="FO-TranslateProjectProperties">
     <xsl:with-param name="ParamProperties" select="$VarResolvedProperties[((@Name != 'width') and (@Name != 'height')) or (@Source = 'Explicit')]" />
     <xsl:with-param name="ParamStyleType" select="'Graphic'" />
    </xsl:call-template>
   </xsl:variable>
   <xsl:variable name="VarFOProperties" select="msxsl:node-set($VarFOPropertiesAsXML)/wwproject:Property" />

   <!-- Width/Height -->
   <!--              -->
   <xsl:variable name="VarByReferenceGraphicsUseDocumentDimensionsOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'by-reference-use-document-dimensions']/@Value" />
   <xsl:variable name="VarByReferenceGraphicsUseDocumentDimensions" select="(string-length($VarByReferenceGraphicsUseDocumentDimensionsOption) = 0) or ($VarByReferenceGraphicsUseDocumentDimensionsOption = 'true')" />
   <xsl:variable name="VarWidth">
    <xsl:choose>
     <!-- Explicit Width Property set? Use it. -->
     <!--                                      -->
     <xsl:when test="count($VarResolvedProperties[@Name = 'width']) &gt; 0">
      <xsl:value-of select="$VarResolvedProperties[@Name = 'width']/@Value" />
     </xsl:when>

     <!-- Thumbnail set? Use Image width. -->
     <!--                                 -->
     <xsl:when test="$ParamThumbnail">
      <xsl:value-of select="number($ParamImageInfo/@width)" />
     </xsl:when>

     <!-- ByReference Image and Use Document dimensions option set? -->
     <!--                                                           -->
     <xsl:when test="($ParamSplitsFrame/@byref = 'true') and (($VarByReferenceGraphicsUseDocumentDimensions) or (number($ParamImageInfo/@width) = 0))">
      <xsl:variable name="VarByReferenceFrame" select="$ParamFrame//wwdoc:Facet[@type = 'by-reference'][1]/../.." />

      <xsl:value-of select="$VarByReferenceFrame/wwdoc:Attribute[@name = 'width']/@value" />
      <xsl:if test="string-length(wwunits:UnitsSuffix($VarByReferenceFrame/wwdoc:Attribute[@name = 'width']/@value)) = 0">
       <xsl:text>pt</xsl:text>
      </xsl:if>
     </xsl:when>

     <xsl:otherwise>
      <!-- Property defined? -->
      <!--                   -->
      <xsl:variable name="VarOptionMaxDimensionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-width']/@Value" />
      <xsl:variable name="VarOptionMaxDimension" select="($VarOptionMaxDimensionValue != 'none') and (string-length($VarOptionMaxDimensionValue &gt; 0)) and (number($VarOptionMaxDimensionValue) &gt; 0)" />
      <xsl:variable name="VarOptionScaleValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />
      <xsl:variable name="VarOptionScale" select="($VarOptionScaleValue != 'none') and (string-length($VarOptionScaleValue &gt; 0)) and (number($VarOptionScaleValue) &gt; 0)" />
      <xsl:variable name="VarPropertyDimension" select="$VarResolvedProperties[@Name = 'width' and @Source = 'Explicit']/@Value" />
      <xsl:choose>
       <!-- Use property defined dimension -->
       <!--                                -->
       <xsl:when test="not($VarOptionMaxDimension) and not($VarOptionScale) and (string-length($VarPropertyDimension) &gt; 0)">
        <xsl:variable name="VarDimensionPrefix" select="wwunits:NumericPrefix($VarPropertyDimension)" />
        <xsl:variable name="VarDimensionSuffix" select="wwunits:UnitsSuffix($VarPropertyDimension)" />
        <xsl:choose>
         <xsl:when test="$VarDimensionSuffix = '%'">
          <xsl:value-of select="$VarPropertyDimension" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="wwunits:Convert($VarDimensionPrefix, $VarDimensionSuffix, 'pt')" />
          <xsl:text>pt</xsl:text>
         </xsl:otherwise>
        </xsl:choose>
       </xsl:when>

       <!-- Use image info dimension -->
       <!--                          -->
       <xsl:otherwise>
        <xsl:value-of select="number($ParamImageInfo/@width)" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>
   <xsl:variable name="VarHeight">
    <xsl:choose>
     <!-- Explicit Height Property set? Use it. -->
     <!--                                       -->
     <xsl:when test="count($VarResolvedProperties[@Name = 'height']) &gt; 0">
      <xsl:value-of select="$VarResolvedProperties[@Name = 'height']/@Value" />
     </xsl:when>

     <!-- Thumbnail set? Use Image height. -->
     <!--                                  -->
     <xsl:when test="$ParamThumbnail">
      <xsl:value-of select="number($ParamImageInfo/@height)" />
     </xsl:when>

     <!-- ByReference Image and Use Document dimensions option set? -->
     <!--                                                           -->
     <xsl:when test="($ParamSplitsFrame/@byref = 'true') and (($VarByReferenceGraphicsUseDocumentDimensions) or (number($ParamImageInfo/@height) = 0))">
      <xsl:variable name="VarByReferenceFrame" select="$ParamFrame//wwdoc:Facet[@type = 'by-reference'][1]/../.." />

      <xsl:value-of select="$VarByReferenceFrame/wwdoc:Attribute[@name = 'height']/@value" />
      <xsl:if test="string-length(wwunits:UnitsSuffix($VarByReferenceFrame/wwdoc:Attribute[@name = 'height']/@value)) = 0">
       <xsl:text>pt</xsl:text>
      </xsl:if>
     </xsl:when>

     <xsl:otherwise>
      <!-- Property defined? -->
      <!--                   -->
      <xsl:variable name="VarOptionMaxDimensionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-height']/@Value" />
      <xsl:variable name="VarOptionMaxDimension" select="($VarOptionMaxDimensionValue != 'none') and (string-length($VarOptionMaxDimensionValue &gt; 0)) and (number($VarOptionMaxDimensionValue) &gt; 0)" />
      <xsl:variable name="VarOptionScaleValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />
      <xsl:variable name="VarOptionScale" select="($VarOptionScaleValue != 'none') and (string-length($VarOptionScaleValue &gt; 0)) and (number($VarOptionScaleValue) &gt; 0)" />
      <xsl:variable name="VarPropertyDimension" select="$VarResolvedProperties[@Name = 'height' and @Source = 'Explicit']/@Value" />
      <xsl:choose>
       <!-- Use property defined dimension -->
       <!--                                -->
       <xsl:when test="not($VarOptionMaxDimension) and not($VarOptionScale) and (string-length($VarPropertyDimension) &gt; 0)">
        <xsl:variable name="VarDimensionPrefix" select="wwunits:NumericPrefix($VarPropertyDimension)" />
        <xsl:variable name="VarDimensionSuffix" select="wwunits:UnitsSuffix($VarPropertyDimension)" />
        <xsl:choose>
         <xsl:when test="$VarDimensionSuffix = '%'">
          <xsl:value-of select="$VarPropertyDimension" />
         </xsl:when>

         <xsl:otherwise>
          <xsl:value-of select="wwunits:Convert($VarDimensionPrefix, $VarDimensionSuffix, 'pt')" />
          <xsl:text>pt</xsl:text>
         </xsl:otherwise>
        </xsl:choose>
       </xsl:when>

       <!-- Use image info dimension -->
       <!--                          -->
       <xsl:otherwise>
        <xsl:value-of select="number($ParamImageInfo/@height)" />
       </xsl:otherwise>
      </xsl:choose>
     </xsl:otherwise>
    </xsl:choose>
   </xsl:variable>

   <!-- Src -->
   <!--     -->
   <xsl:variable name="VarSrc" select="wwuri:AsURI($ParamImageInfo/@path)" />

   <!-- Inline or block -->
   <!--                 -->
   <xsl:variable name="VarBlock" select="$VarResolvedProperties[(@Name = 'display') and (@Value = 'block')]/@Value = 'block'" />
   <xsl:choose>
    <!-- Block -->
    <!--       -->
    <xsl:when test="$VarBlock">
     <!-- center or right -->
     <!--                 -->
     <xsl:variable name="VarTextAlign" select="$VarResolvedProperties[(@Name = 'text-align') and ((@Value = 'center') or (@Value = 'right'))]/@Value" />

     <!-- left or right -->
     <!--               -->
     <xsl:variable name="VarFloat" select="$VarResolvedProperties[(@Name = 'float') and ((@Value = 'left') or (@Value = 'right'))]/@Value" />
     <xsl:choose>
      <!-- Float -->
      <!--       -->

      <xsl:when test="$VarFloat">
       <fo:float>
        <xsl:choose>
         <!-- left -->
         <!--      -->
         <xsl:when test="$VarFloat = 'left'">
          <xsl:attribute name="float">
           <xsl:text>start</xsl:text>
          </xsl:attribute>
         </xsl:when>

         <!-- right -->
         <!--       -->
         <xsl:otherwise>
          <xsl:attribute name="float">
           <xsl:text>end</xsl:text>
          </xsl:attribute>
         </xsl:otherwise>
        </xsl:choose>

        <fo:block>
         <!-- text-align -->
         <!--            -->
         <xsl:if test="$VarTextAlign">
          <xsl:attribute name="text-align">
           <xsl:value-of select="$VarTextAlign" />
          </xsl:attribute>
         </xsl:if>

         <xsl:call-template name="Frame-Markup-External-Graphic-With-Link">
          <xsl:with-param name="ParamFrame" select="$ParamFrame" />
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
          <xsl:with-param name="ParamCargo" select="$ParamCargo" />
          <xsl:with-param name="ParamLinks" select="$ParamLinks" />
          <xsl:with-param name="ParamSplit" select="$ParamSplit" />
          <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
          <xsl:with-param name="ParamSrc" select="$VarSrc" />
          <xsl:with-param name="ParamWidth" select="$VarWidth" />
          <xsl:with-param name="ParamHeight" select="$VarHeight" />
          <xsl:with-param name="ParamFOProperties" select="$VarFOProperties" />
          <xsl:with-param name="ParamImageInfo" select="$ParamImageInfo" />
         </xsl:call-template>
        </fo:block>
       </fo:float>
      </xsl:when>

      <xsl:otherwise>
       <fo:block>
        <!-- text-align -->
        <!--            -->
        <xsl:if test="$VarTextAlign">
         <xsl:attribute name="text-align">
          <xsl:value-of select="$VarTextAlign" />
         </xsl:attribute>
        </xsl:if>

        <xsl:call-template name="Frame-Markup-External-Graphic-With-Link">
         <xsl:with-param name="ParamFrame" select="$ParamFrame" />
         <xsl:with-param name="ParamSplits" select="$ParamSplits" />
         <xsl:with-param name="ParamCargo" select="$ParamCargo" />
         <xsl:with-param name="ParamLinks" select="$ParamLinks" />
         <xsl:with-param name="ParamSplit" select="$ParamSplit" />
         <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
         <xsl:with-param name="ParamSrc" select="$VarSrc" />
         <xsl:with-param name="ParamWidth" select="$VarWidth" />
         <xsl:with-param name="ParamHeight" select="$VarHeight" />
         <xsl:with-param name="ParamFOProperties" select="$VarFOProperties" />
         <xsl:with-param name="ParamImageInfo" select="$ParamImageInfo" />
        </xsl:call-template>
       </fo:block>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:when>

    <!-- Inline -->
    <!--        -->
    <xsl:otherwise>
     <fo:inline>
      <xsl:call-template name="Frame-Markup-External-Graphic-With-Link">
       <xsl:with-param name="ParamFrame" select="$ParamFrame" />
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamCargo" select="$ParamCargo" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
       <xsl:with-param name="ParamSrc" select="$VarSrc" />
       <xsl:with-param name="ParamWidth" select="$VarWidth" />
       <xsl:with-param name="ParamHeight" select="$VarHeight" />
       <xsl:with-param name="ParamFOProperties" select="$VarFOProperties" />
       <xsl:with-param name="ParamImageInfo" select="$ParamImageInfo" />
      </xsl:call-template>
     </fo:inline>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:for-each>
 </xsl:template>

 <xsl:template name="Frame-Markup-External-Graphic-With-Link">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamThumbnail" />
  <xsl:param name="ParamSrc" />
  <xsl:param name="ParamWidth" />
  <xsl:param name="ParamHeight" />
  <xsl:param name="ParamFOProperties" />
  <xsl:param name="ParamImageInfo" />

  <!-- Check for link -->
  <!--                -->
  <xsl:variable name="VarLinkInfoAsXML">
   <xsl:choose>
    <xsl:when test="count($ParamFrame/wwdoc:Link[1]) = 1">
     <xsl:call-template name="LinkInfo">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamDocumentLink" select="$ParamFrame/wwdoc:Link" />
     </xsl:call-template>
    </xsl:when>

    <xsl:otherwise>
     <xsl:variable name="VarChildLinks" select="$ParamFrame//wwdoc:Link" />
     <xsl:variable name="VarChildLinksCount" select="count($VarChildLinks)" />
     <xsl:if test="$VarChildLinksCount &gt; 0">
      <xsl:call-template name="LinkInfo">
       <xsl:with-param name="ParamSplits" select="$ParamSplits" />
       <xsl:with-param name="ParamLinks" select="$ParamLinks" />
       <xsl:with-param name="ParamSplit" select="$ParamSplit" />
       <xsl:with-param name="ParamDocumentLink" select="$VarChildLinks[$VarChildLinksCount]" />
      </xsl:call-template>
     </xsl:if>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>
  <xsl:variable name="VarLinkInfo" select="msxsl:node-set($VarLinkInfoAsXML)/wwlinks:LinkInfo" />

  <!-- Emit markup -->
  <!--             -->
  <xsl:choose>
   <!-- Link exists? -->
   <!--              -->
   <xsl:when test="string-length($VarLinkInfo/@href) &gt; 0">
    <fo:basic-link>
     <xsl:attribute name="{$VarLinkInfo/@attribute-name}">
      <xsl:value-of select="$VarLinkInfo/@href" />
     </xsl:attribute>

     <xsl:call-template name="Frame-Markup-External-Graphic">
      <xsl:with-param name="ParamFrame" select="$ParamFrame" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
      <xsl:with-param name="ParamSrc" select="$ParamSrc" />
      <xsl:with-param name="ParamWidth" select="$ParamWidth" />
      <xsl:with-param name="ParamHeight" select="$ParamHeight" />
      <xsl:with-param name="ParamFOProperties" select="$ParamFOProperties" />
      <xsl:with-param name="ParamImageInfo" select="$ParamImageInfo" />
     </xsl:call-template>
    </fo:basic-link>
   </xsl:when>

   <!-- No link exists -->
   <!--                -->
   <xsl:otherwise>
    <xsl:call-template name="Frame-Markup-External-Graphic">
     <xsl:with-param name="ParamFrame" select="$ParamFrame" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$ParamCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
     <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
     <xsl:with-param name="ParamSrc" select="$ParamSrc" />
     <xsl:with-param name="ParamWidth" select="$ParamWidth" />
     <xsl:with-param name="ParamHeight" select="$ParamHeight" />
     <xsl:with-param name="ParamFOProperties" select="$ParamFOProperties" />
     <xsl:with-param name="ParamImageInfo" select="$ParamImageInfo" />
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <xsl:template name="Frame-Markup-External-Graphic">
  <xsl:param name="ParamFrame" />
  <xsl:param name="ParamSplits" />
  <xsl:param name="ParamCargo" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamSplit" />
  <xsl:param name="ParamThumbnail" />
  <xsl:param name="ParamSrc" />
  <xsl:param name="ParamWidth" />
  <xsl:param name="ParamHeight" />
  <xsl:param name="ParamFOProperties" />
  <xsl:param name="ParamImageInfo" />

  <!-- Graphic element -->
  <!--                 -->
  <fo:external-graphic id="w{$ParamSplit/@groupID}_{$ParamSplit/@documentID}_{$ParamFrame/@id}">
   <!-- Src attribute -->
   <!--               -->
   <xsl:attribute name="src">
    <xsl:text>url('</xsl:text>
    <xsl:value-of select="$ParamSrc" />
    <xsl:text>')</xsl:text>
   </xsl:attribute>

   <xsl:choose>
    <!-- Raster image: DPI normalization                                          -->
    <!-- Set viewport width to pixel dimensions normalized to 96 DPI (points),    -->
    <!-- capped at 100% of containing block via min() since FOP ignores max-width -->
    <!-- on external-graphic. Use scale-to-fit to fill the viewport.              -->
    <!--                                                                          -->
    <xsl:when test="$ParamImageInfo and (number($ParamImageInfo/@width) &gt; 0)">
     <xsl:attribute name="width">
      <xsl:text>min(</xsl:text>
      <xsl:value-of select="($ParamImageInfo/@width div 96) * 72" />
      <xsl:text>pt, 100%)</xsl:text>
     </xsl:attribute>
     <xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
     <xsl:attribute name="content-height">auto</xsl:attribute>

     <!-- Copy non-dimension FO properties -->
     <!--                                  -->
     <xsl:for-each select="$ParamFOProperties[@Name != 'direction'][@Name != 'float'][@Name != 'content-width'][@Name != 'content-height'][@Name != 'width'][@Name != 'height'][@Name != 'max-width'][@Name != 'max-height']">
      <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
     </xsl:for-each>
    </xsl:when>

    <!-- SVG or other: apply computed dimensions or use FO properties as-is -->
    <!--                                                                    -->
    <xsl:otherwise>
     <xsl:choose>
      <!-- SVG with computed dimensions (from Frame-Markup-Vector-SVG)            -->
      <!-- FOP requires both viewport width and height as fixed pt values for    -->
      <!-- SVG external-graphics. Using min(), %, or auto causes FOP to use the  -->
      <!-- SVG intrinsic viewBox height, creating dead space below the image.    -->
      <!--                                                                       -->
      <xsl:when test="(string(number($ParamWidth)) != 'NaN') and (number($ParamWidth) &gt; 0)">
       <xsl:attribute name="width">
        <xsl:value-of select="$ParamWidth" />
        <xsl:text>pt</xsl:text>
       </xsl:attribute>
       <xsl:if test="(string(number($ParamHeight)) != 'NaN') and (number($ParamHeight) &gt; 0)">
        <xsl:attribute name="height">
         <xsl:value-of select="$ParamHeight" />
         <xsl:text>pt</xsl:text>
        </xsl:attribute>
       </xsl:if>
       <xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
       <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
       <xsl:attribute name="scaling">uniform</xsl:attribute>

       <!-- Copy non-dimension FO properties -->
       <!--                                  -->
       <xsl:for-each select="$ParamFOProperties[@Name != 'direction'][@Name != 'float'][@Name != 'content-width'][@Name != 'content-height'][@Name != 'width'][@Name != 'height'][@Name != 'max-width'][@Name != 'max-height'][@Name != 'scaling']">
        <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
       </xsl:for-each>
      </xsl:when>

      <!-- Legacy: use FO properties as-is -->
      <!--                                 -->
      <xsl:otherwise>
       <xsl:for-each select="$ParamFOProperties[@Name != 'direction'][@Name != 'float']">
        <xsl:attribute name="{@Name}"><xsl:value-of select="@Value" /></xsl:attribute>
       </xsl:for-each>
      </xsl:otherwise>
     </xsl:choose>
    </xsl:otherwise>
   </xsl:choose>
  </fo:external-graphic>

  <!-- Notes -->
  <!--       -->
  <xsl:choose>
   <!-- Thumbnail -->
   <!--           -->
   <xsl:when test="$ParamThumbnail">
    <!-- Nothing to do -->
    <!--               -->
   </xsl:when>

   <!-- Fullsize -->
   <!--          -->
   <xsl:otherwise>
    <!-- Frame Footnotes -->
    <!--                 -->
    <xsl:variable name="VarNotes" select="$ParamFrame//wwdoc:Note" />
    <xsl:call-template name="Content-Notes">
     <xsl:with-param name="ParamNotes" select="$VarNotes" />
     <xsl:with-param name="ParamSplits" select="$ParamSplits" />
     <xsl:with-param name="ParamCargo" select="$ParamCargo" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamTOCData" select="''" />
     <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    </xsl:call-template>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>

 <!-- Process all valid text in TextRuns and nested TextRuns (depth first, in order). -->
 <!--                                                                                 -->
 <xsl:template match="wwdoc:TextRun" mode="wwmode:textrun_text">
  <xsl:variable name="VarTextRun" select="."/>
  <!-- Recurse to find nested TextRuns, Text, and LineBreaks -->
  <!--                                                       -->
  <xsl:apply-templates select="$VarTextRun/*" mode="wwmode:textrun_text"/>
 </xsl:template>

 <xsl:template match="wwdoc:Text" mode="wwmode:textrun_text">
  <xsl:value-of select="./@value"/>
 </xsl:template>

 <xsl:template match="wwdoc:LineBreak" mode="wwmode:textrun_text">
  <!-- Replace LineBreaks with a single space -->
  <!--                                        -->
  <xsl:text> </xsl:text>
 </xsl:template>

 <xsl:template match="* |text() | comment() | processing-instruction()" mode="wwmode:textrun_text">
  <!-- Ignore -->
  <!--        -->
 </xsl:template>
</xsl:stylesheet>
