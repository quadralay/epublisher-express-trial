<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:msxsl="urn:schemas-microsoft-com:xslt"
  xmlns:wwmode="urn:WebWorks-Engine-Mode"
  xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
  xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
  xmlns:wwdoc="urn:WebWorks-Document-Schema"
  xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
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
  xmlns:wwfilesext="urn:WebWorks-Engine-Files-Schema"
  xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
  xmlns:wwimaging="urn:WebWorks-XSLT-Extension-Imaging"
  xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
  exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwbehaviors wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc html"
>


  <!-- Core adapters shared by Markdown++ and KB -->

  <xsl:template name="Content-Content">
    <xsl:param name="ParamContent" />
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />

    <xsl:apply-templates select="$ParamContent" mode="wwmode:content">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="Content-Notes">
    <xsl:param name="ParamNotes" />
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />

    <xsl:if test="count($ParamNotes[1]) = 1">
      <xsl:call-template name="Markdown-FNotes">
        <xsl:with-param name="ParamNotes" select="$ParamNotes" />
      </xsl:call-template>
    </xsl:if>
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

  <xsl:template match="wwdoc:List" mode="wwmode:content">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />

    <xsl:variable name="VarList" select="." />
    <xsl:if test="not(wwprogress:Abort())">
      <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarList/@stylename, $ParamSplit/@documentID, $VarList/@id)" />
      <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
      <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
      <xsl:if test="$VarGenerateOutput">
        <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
          <xsl:variable name="VarListBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarList/@id)[1]" />
          <xsl:call-template name="List">
            <xsl:with-param name="ParamSplits" select="$ParamSplits" />
            <xsl:with-param name="ParamCargo" select="$ParamCargo" />
            <xsl:with-param name="ParamLinks" select="$ParamLinks" />
            <xsl:with-param name="ParamSplit" select="$ParamSplit" />
            <xsl:with-param name="ParamList" select="$VarList" />
            <xsl:with-param name="ParamStyleName" select="$VarList/@stylename" />
            <xsl:with-param name="ParamOverrideRule" select="$VarOverrideRule" />
            <xsl:with-param name="ParamListBehavior" select="$VarListBehavior" />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="List">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />
    <xsl:param name="ParamList" />
    <xsl:param name="ParamStyleName" />
    <xsl:param name="ParamOverrideRule" />
    <xsl:param name="ParamListBehavior" />

    <xsl:apply-templates select="$ParamList/*" mode="wwmode:content">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="wwdoc:ListItem" mode="wwmode:content">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />

    <xsl:variable name="VarListItem" select="." />
    <xsl:if test="not(wwprogress:Abort())">
      <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarListItem/@stylename, $ParamSplit/@documentID, $VarListItem/@id)" />
      <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
      <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
      <xsl:if test="$VarGenerateOutput">
        <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
          <xsl:variable name="VarListItemBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarListItem/@id)[1]" />
          <xsl:call-template name="ListItem">
            <xsl:with-param name="ParamSplits" select="$ParamSplits" />
            <xsl:with-param name="ParamCargo" select="$ParamCargo" />
            <xsl:with-param name="ParamLinks" select="$ParamLinks" />
            <xsl:with-param name="ParamSplit" select="$ParamSplit" />
            <xsl:with-param name="ParamListItem" select="$VarListItem" />
            <xsl:with-param name="ParamStyleName" select="$VarListItem/@stylename" />
            <xsl:with-param name="ParamOverrideRule" select="$VarOverrideRule" />
            <xsl:with-param name="ParamListItemBehavior" select="$VarListItemBehavior" />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="ListItem">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />
    <xsl:param name="ParamListItem" />
    <xsl:param name="ParamStyleName" />
    <xsl:param name="ParamOverrideRule" />
    <xsl:param name="ParamListItemBehavior" />

    <xsl:apply-templates select="$ParamListItem/*" mode="wwmode:content">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="wwdoc:Block" mode="wwmode:content">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />

    <xsl:variable name="VarBlock" select="." />
    <xsl:if test="not(wwprogress:Abort())">
      <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarBlock/@stylename, $ParamSplit/@documentID, $VarBlock/@id)" />
      <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
      <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
      <xsl:if test="$VarGenerateOutput">
        <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
          <xsl:variable name="VarBlockBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarBlock/@id)[1]" />
          <xsl:call-template name="Block">
            <xsl:with-param name="ParamSplits" select="$ParamSplits" />
            <xsl:with-param name="ParamCargo" select="$ParamCargo" />
            <xsl:with-param name="ParamLinks" select="$ParamLinks" />
            <xsl:with-param name="ParamSplit" select="$ParamSplit" />
            <xsl:with-param name="ParamBlock" select="$VarBlock" />
            <xsl:with-param name="ParamStyleName" select="$VarBlock/@stylename" />
            <xsl:with-param name="ParamOverrideRule" select="$VarOverrideRule" />
            <xsl:with-param name="ParamBlockBehavior" select="$VarBlockBehavior" />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="Block">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />
    <xsl:param name="ParamBlock" />
    <xsl:param name="ParamStyleName" />
    <xsl:param name="ParamOverrideRule" />
    <xsl:param name="ParamBlockBehavior" />

    <xsl:apply-templates select="$ParamBlock/*" mode="wwmode:content">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="wwdoc:Paragraph" mode="wwmode:content">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />

    <xsl:variable name="VarParagraph" select="." />
    <xsl:if test="not(wwprogress:Abort())">
      <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Paragraph', $VarParagraph/@stylename, $ParamSplit/@documentID, $VarParagraph/@id)" />
      <xsl:variable name="VarGenerateOutputOption" select="$VarOverrideRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
      <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
      <xsl:if test="$VarGenerateOutput">
        <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
          <xsl:variable name="VarParagraphBehavior" select="key('wwbehaviors-paragraphs-by-id', $VarParagraph/@id)[1]" />
          <xsl:call-template name="Paragraph">
            <xsl:with-param name="ParamSplits" select="$ParamSplits" />
            <xsl:with-param name="ParamCargo" select="$ParamCargo" />
            <xsl:with-param name="ParamLinks" select="$ParamLinks" />
            <xsl:with-param name="ParamSplit" select="$ParamSplit" />
            <xsl:with-param name="ParamParagraph" select="$VarParagraph" />
            <xsl:with-param name="ParamStyleName" select="$VarParagraph/@stylename" />
            <xsl:with-param name="ParamOverrideRule" select="$VarOverrideRule" />
            <xsl:with-param name="ParamParagraphBehavior" select="$VarParagraphBehavior" />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="Paragraph">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />
    <xsl:param name="ParamParagraph" />
    <xsl:param name="ParamStyleName" />
    <xsl:param name="ParamOverrideRule" />
    <xsl:param name="ParamParagraphBehavior" />

    <xsl:variable name="VarPreserveEmptyOption" select="$ParamOverrideRule/wwproject:Options/wwproject:Option[@Name = 'preserve-empty']/@Value" />
    <xsl:variable name="VarPreserveEmpty" select="(string-length($VarPreserveEmptyOption) = 0) or ($VarPreserveEmptyOption = 'true')" />

    <xsl:variable name="VarTextRuns" select="$ParamParagraph/wwdoc:TextRun[count(child::wwdoc:TextRun[1] | child::wwdoc:Text[1] | child::wwdoc:Frame[1] | child::wwdoc:Note[1] | child::wwdoc:LineBreak[1] | child::wwdoc:Marker[1]) > 0]" />

    <xsl:if test="($VarPreserveEmpty) or (count($VarTextRuns[1]) = 1)">
      <xsl:variable name="VarPassThrough">
        <xsl:variable name="VarPassThroughOption" select="$ParamOverrideRule/wwproject:Options/wwproject:Option[@Name = 'pass-through']/@Value" />
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
            <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
            <xsl:with-param name="ParamStyleName" select="$ParamStyleName" />
            <xsl:with-param name="ParamOverrideRule" select="$ParamOverrideRule" />
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
    <xsl:param name="ParamParagraph" />
    <xsl:param name="ParamStyleName" />
    <xsl:param name="ParamOverrideRule" />
    <xsl:param name="ParamParagraphBehavior" />

    <xsl:variable name="VarResolvedPropertiesAsXML">
      <xsl:call-template name="Properties-ResolveOverrideRule">
        <xsl:with-param name="ParamProperties" select="$ParamOverrideRule/wwproject:Properties/wwproject:Property" />
        <xsl:with-param name="ParamContextStyle" select="$ParamParagraph/wwdoc:Style" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

    <xsl:variable name="VarCSSPropertiesAsXML">
      <xsl:call-template name="CSS-TranslateProjectProperties">
        <xsl:with-param name="ParamProperties" select="$VarResolvedProperties" />
        <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplit/@path" />
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarCSSProperties" select="msxsl:node-set($VarCSSPropertiesAsXML)/wwproject:Property" />

    <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Paragraph', $ParamParagraph/@stylename, $ParamSplit/@documentID, $ParamParagraph/@id)" />

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

    <xsl:variable name="VarCSSContextPropertiesAsXML">
      <xsl:call-template name="CSS-TranslateProjectProperties">
        <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
        <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplit/@path" />
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarCSSContextProperties" select="msxsl:node-set($VarCSSContextPropertiesAsXML)/wwproject:Property" />

    <xsl:variable name="VarUseNumberingOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'use-numbering']/@Value" />
    <xsl:variable name="VarUseNumbering" select="(string-length($VarUseNumberingOption) = 0) or ($VarUseNumberingOption = 'true')" />

    <xsl:variable name="VarTextIndent">
      <xsl:if test="$VarUseNumbering">
        <xsl:variable name="VarOverrideTextIndent" select="$VarCSSProperties[@Name = 'text-indent']/@Value" />
        <xsl:choose>
          <xsl:when test="string-length($VarOverrideTextIndent) > 0">
            <xsl:value-of select="$VarOverrideTextIndent" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="VarContextTextIndent" select="$VarCSSContextProperties[@Name = 'text-indent']/@Value" />
            <xsl:if test="string-length($VarContextTextIndent) > 0">
              <xsl:value-of select="$VarContextTextIndent" />
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="VarTextIndentNumericPrefix" select="wwunits:NumericPrefix($VarTextIndent)" />
    <xsl:variable name="VarTextIndentLessThanZero" select="(string-length($VarTextIndentNumericPrefix) &gt; 0) and (number($VarTextIndentNumericPrefix) &lt; 0)" />

    <xsl:variable name="VarBulletCharacter" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-character']/@Value" />
    <xsl:variable name="VarBulletImage" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-image']/@Value" />
    <xsl:variable name="VarBulletSeparator" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-separator']/@Value" />
    <xsl:variable name="VarBulletStyle" select="$VarContextRule/wwproject:Properties/wwproject:Property[@Name = 'bullet-style']/@Value" />
    <xsl:variable name="VarIgnoreDocumentNumber" select="(string-length($VarBulletCharacter) > 0) or (string-length($VarBulletImage) > 0)" />

    <xsl:variable name="VarIsNumberedParagraph" select="($VarTextIndentLessThanZero = true()) and ((count($ParamParagraph/wwdoc:Number[1]) = 1) or (string-length($VarBulletCharacter) > 0) or (string-length($VarBulletImage) > 0))" />

    <xsl:variable name="VarCitation">
      <xsl:call-template name="Behaviors-Options-OptionMarker">
        <xsl:with-param name="ParamContainer" select="$ParamParagraph" />
        <xsl:with-param name="ParamCargo" select="$ParamCargo" />
        <xsl:with-param name="ParamParagraphID" select="$ParamParagraph/@id" />
        <xsl:with-param name="ParamRule" select="$VarContextRule" />
        <xsl:with-param name="ParamOption" select="'citation'" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="VarTagProperty" select="$VarResolvedContextProperties[@Name = 'tag']/@Value" />
    <xsl:variable name="VarTag">
      <xsl:choose>
        <xsl:when test="string-length($VarTagProperty) > 0">
          <xsl:value-of select="$VarTagProperty" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'div'" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="VarOuterTag">
      <xsl:choose>
        <xsl:when test="$VarIsNumberedParagraph = true()">
          <xsl:value-of select="'div'" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$VarTag" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="VarUseCharacterStylesOption" select="$ParamOverrideRule/wwproject:Options/wwproject:Option[@Name = 'use-character-styles']/@Value" />
    <xsl:variable name="VarUseCharacterStyles" select="(string-length($VarUseCharacterStylesOption) = 0) or ($VarUseCharacterStylesOption = 'true')" />

    <xsl:variable name="VarPreserveEmptyOption" select="$ParamOverrideRule/wwproject:Options/wwproject:Option[@Name = 'preserve-empty']/@Value" />
    <xsl:variable name="VarPreserveEmpty" select="(string-length($VarPreserveEmptyOption) = 0) or ($VarPreserveEmptyOption = 'true')" />

    <xsl:variable name="VarMarkdownPropertiesAsXML">
      <xsl:call-template name="Markdown-TranslateParagraphStyleProperties">
        <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
        <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarMarkdownProperties" select="msxsl:node-set($VarMarkdownPropertiesAsXML)/wwproject:Property" />

    <xsl:variable name="VarParagraphNumberAsXML">
      <xsl:if test="$VarUseNumbering and (count($ParamParagraph/wwdoc:Number[1]) > 0)">
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
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="VarParagraphNumber" select="msxsl:node-set($VarParagraphNumberAsXML)" />

    <xsl:variable name="VarParagraphContentAsXML">
      <xsl:call-template name="ParagraphTextRuns">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$ParamCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamPreserveEmpty" select="$VarPreserveEmpty" />
        <xsl:with-param name="ParamUseCharacterStyles" select="$VarUseCharacterStyles" />
        <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarParagraphContent" select="msxsl:node-set($VarParagraphContentAsXML)" />
    <xsl:variable name="VarIsTableCell" select="count($ParamParagraph/ancestor::wwdoc:TableCell[1]) = 1" />


    <xsl:choose>
      <xsl:when test="$VarIsTableCell">
        <xsl:variable name="VarTableStyleName" select="$ParamParagraph/ancestor::wwdoc:Table[1]/@stylename" />
        <xsl:variable name="VarTableRule" select="wwprojext:GetRule('Table', $VarTableStyleName)" />
        <xsl:variable name="VarRenderingOption" select="$VarTableRule/wwproject:Options/wwproject:Option[@Name = 'table-rendering']/@Value" />

        <xsl:choose>
          <xsl:when test="$VarRenderingOption = 'pipes'">
            <xsl:call-template name="Markdown-Paragraph-TableCell">
              <xsl:with-param name="ParamNumber" select="$VarParagraphNumber" />
              <xsl:with-param name="ParamContent" select="$VarParagraphContent" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="Markdown-Paragraph">
              <xsl:with-param name="ParamProperties" select="$VarMarkdownProperties" />
              <xsl:with-param name="ParamNumber" select="$VarParagraphNumber" />
              <xsl:with-param name="ParamContent" select="$VarParagraphContent" />
              <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
              <xsl:with-param name="ParamRule" select="$VarContextRule" />
              <xsl:with-param name="ParamParagraphBehavior" select="$ParamParagraphBehavior" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
        <xsl:call-template name="Markdown-Paragraph">
          <xsl:with-param name="ParamProperties" select="$VarMarkdownProperties" />
          <xsl:with-param name="ParamNumber" select="$VarParagraphNumber" />
          <xsl:with-param name="ParamContent" select="$VarParagraphContent" />
          <xsl:with-param name="ParamParagraph" select="$ParamParagraph" />
          <xsl:with-param name="ParamRule" select="$VarContextRule" />
          <xsl:with-param name="ParamParagraphBehavior" select="$ParamParagraphBehavior" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
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

    <xsl:call-template name="Markdown-ParaNumber">
      <xsl:with-param name="ParamNumber" select="$ParamParagraph/wwdoc:Number[1]" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="ParagraphTextRuns">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />
    <xsl:param name="ParamPreserveEmpty" />
    <xsl:param name="ParamUseCharacterStyles" />
    <xsl:param name="ParamParagraph" />

    <wwexsldoc:NoBreak />

    <xsl:variable name="VarTextRuns" select="$ParamParagraph/wwdoc:TextRun[count(child::wwdoc:TextRun[1] | child::wwdoc:Text[1] | child::wwdoc:Frame[1] | child::wwdoc:Note[1] | child::wwdoc:LineBreak[1] | child::wwdoc:Marker[1]) > 0]" />

    <xsl:choose>
      <xsl:when test="count($VarTextRuns[1]) = 1">
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
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="LinkInfo">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />
    <xsl:param name="ParamDocumentLink" />

    <xsl:element name="LinkInfo" namespace="urn:WebWorks-Engine-Links-Schema">
      <xsl:if test="count($ParamDocumentLink) > 0">
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

        <xsl:if test="string-length($VarResolvedLinkInfo/@title) > 0">
          <xsl:attribute name="title">
            <xsl:value-of select="$VarResolvedLinkInfo/@title" />
          </xsl:attribute>
        </xsl:if>

        <xsl:choose>
          <xsl:when test="$VarResolvedLinkInfo/@type = 'baggage'">
            <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($VarResolvedLinkInfo/@path, $ParamSplit/@path)" />
            <xsl:attribute name="href"><xsl:value-of select="$VarRelativePath" /></xsl:attribute>
            <xsl:variable name="VarTarget" select="wwprojext:GetFormatSetting('baggage-file-target')" />
            <xsl:if test="(string-length($VarTarget) > 0) and ($VarTarget != 'none')">
              <xsl:attribute name="target"><xsl:value-of select="$VarTarget" /></xsl:attribute>
            </xsl:if>
          </xsl:when>

          <xsl:when test="($VarResolvedLinkInfo/@type = 'document') or ($VarResolvedLinkInfo/@type = 'group') or ($VarResolvedLinkInfo/@type = 'project')">
            <xsl:attribute name="href">
              <xsl:variable name="VarRelativePath" select="wwuri:GetRelativeTo($VarResolvedLinkInfo/@path, $ParamSplit/@path)" />
              <xsl:value-of select="$VarRelativePath" />
              <xsl:text>#</xsl:text>
              <xsl:if test="(string-length($ParamDocumentLink/@anchor) > 0) and ($VarResolvedLinkInfo/@first != 'true') and (string-length($VarResolvedLinkInfo/@linkid) > 0)">
                <xsl:value-of select="$VarResolvedLinkInfo/@linkid" />
              </xsl:if>
            </xsl:attribute>
          </xsl:when>

          <xsl:when test="$VarResolvedLinkInfo/@type = 'url'">
            <xsl:attribute name="href"><xsl:value-of select="$VarResolvedLinkInfo/@url" /></xsl:attribute>
            <xsl:if test="not(wwuri:IsFile($VarResolvedLinkInfo/@url))">
              <xsl:variable name="VarTarget" select="wwprojext:GetFormatSetting('external-url-target', 'external_window')" />
              <xsl:if test="(string-length($VarTarget) > 0) and ($VarTarget != 'none')">
                <xsl:attribute name="target"><xsl:value-of select="$VarTarget" /></xsl:attribute>
              </xsl:if>
            </xsl:if>
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

    <xsl:variable name="VarStyleName">
      <xsl:choose>
        <xsl:when test="string-length($ParamCargo/wwproject:BulletProperties/wwproject:Property[@Name = 'bullet-style']/@Value) > 0">
          <xsl:value-of select="$ParamCargo/wwproject:BulletProperties/wwproject:Property[@Name = 'bullet-style']/@Value" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$ParamTextRun/@stylename" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="VarRule" select="wwprojext:GetRule('Character', $VarStyleName)" />
    <xsl:variable name="VarGenerateOutputOption" select="$VarRule/wwproject:Options/wwproject:Option[@Name = 'generate-output']/@Value" />
    <xsl:variable name="VarGenerateOutput" select="(string-length($VarGenerateOutputOption) = 0) or ($VarGenerateOutputOption != 'false')" />
    <xsl:if test="$VarGenerateOutput">
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
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="TextRun-PassThrough">
    <xsl:param name="ParamTextRun" />
    <wwexsldoc:Text disable-output-escaping="yes">
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

    <xsl:variable name="VarStyleName" select="$ParamTextRun/@stylename"/>
    <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Character', $VarStyleName, $ParamSplit/@documentID, $ParamTextRun/@id)" />

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

    <xsl:variable name="VarMarkdownPropertiesAsXML">
      <xsl:call-template name="Markdown-TranslateCharacterStyleProperties">
        <xsl:with-param name="ParamProperties" select="$VarResolvedContextProperties" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarMarkdownProperties" select="msxsl:node-set($VarMarkdownPropertiesAsXML)/wwproject:Property" />

    <xsl:variable name="VarTextRunContent">
      <xsl:call-template name="TextRunChildren">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$ParamCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamParagraphID" select="$ParamParagraphID" />
        <xsl:with-param name="ParamTextRun" select="$ParamTextRun" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:call-template name="Markdown-TextRun">
      <xsl:with-param name="ParamProperties" select="$VarMarkdownProperties" />
      <xsl:with-param name="ParamTextRunContent" select="$VarTextRunContent" />
      <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
      <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="TextRunChildren">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />
    <xsl:param name="ParamParagraphID" />
    <xsl:param name="ParamTextRun" />

    <wwexsldoc:NoBreak />

    <xsl:variable name="VarLinkInfoAsXML">
      <xsl:call-template name="LinkInfo">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamDocumentLink" select="$ParamTextRun/wwdoc:Link" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarLinkInfo" select="msxsl:node-set($VarLinkInfoAsXML)/wwlinks:LinkInfo" />

    <xsl:call-template name="Markdown-LinkPrefix">
      <xsl:with-param name="ParamLinkInfo" select="$VarLinkInfo" />
    </xsl:call-template>

    <xsl:apply-templates select="$ParamTextRun/*" mode="wwmode:textrun">
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$ParamCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    </xsl:apply-templates>

    <xsl:call-template name="Markdown-LinkSuffix">
      <xsl:with-param name="ParamLinkInfo" select="$VarLinkInfo" />
    </xsl:call-template>
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
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="wwdoc:Note" mode="wwmode:textrun">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />
    <xsl:variable name="VarContext" select="." />

    <xsl:for-each select="$ParamCargo/wwnotes:NoteNumbering[1]">
      <xsl:variable name="VarNoteNumber" select="key('wwnotes-notes-by-id', $VarContext/@id)/@number" />
      <wwexsldoc:NoBreak />
      <xsl:call-template name="Markdown-FNoteRef">
        <xsl:with-param name="ParamNoteNumber" select="$VarNoteNumber" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="wwdoc:LineBreak" mode="wwmode:textrun">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />
    <xsl:call-template name="Markdown-ParaLineBreak">
      <xsl:with-param name="ParamLineBreak" select="." />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="wwdoc:IndexMarker" mode="wwmode:textrun">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />
    <!-- ignore -->
  </xsl:template>

  <xsl:template match="wwdoc:Marker" mode="wwmode:textrun">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />

    <xsl:variable name="VarMarker" select="." />
    <xsl:for-each select="$ParamCargo/wwbehaviors:Behaviors[1]">
      <xsl:variable name="VarMarkerBehavior" select="key('wwbehaviors-markers-by-id', $VarMarker/@id)[1]" />
      <xsl:if test="$VarMarkerBehavior/@behavior = 'pass-through'">
        <xsl:for-each select="$VarMarker/wwdoc:TextRun">
          <xsl:variable name="VarTextRun" select="." />
          <xsl:call-template name="TextRun-PassThrough">
            <xsl:with-param name="ParamTextRun" select="$VarTextRun" />
          </xsl:call-template>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="wwdoc:Text" mode="wwmode:textrun">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />
    <xsl:value-of select="@value" />
  </xsl:template>

</xsl:stylesheet>
