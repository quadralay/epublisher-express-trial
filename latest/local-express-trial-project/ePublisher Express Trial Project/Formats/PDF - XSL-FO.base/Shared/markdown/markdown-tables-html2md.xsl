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

  <!-- Shared Table adapter: builds a lightweight HTML-like table structure then defers to Markdown-Table. -->
  <xsl:template name="Table">
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />
    <xsl:param name="ParamTable" />
    <xsl:param name="ParamStyleName" />
    <xsl:param name="ParamOverrideRule" />
    <xsl:param name="ParamTableBehavior" />

    <!-- Notes -->
    <xsl:variable name="VarNotes" select="$ParamTable//wwdoc:Note[not(ancestor::wwdoc:Frame)]" />

    <!-- Note numbering -->
    <xsl:variable name="VarNoteNumberingAsXML">
      <xsl:call-template name="Notes-Number">
        <xsl:with-param name="ParamNotes" select="$VarNotes" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarNoteNumbering" select="msxsl:node-set($VarNoteNumberingAsXML)" />

    <!-- Cargo for recursion -->
    <xsl:variable name="VarCargo" select="$ParamCargo/*[local-name() != 'NoteNumbering']/.. | $VarNoteNumbering" />

    <!-- Resolve project properties -->
    <xsl:variable name="VarResolvedPropertiesAsXML">
      <xsl:call-template name="Properties-ResolveOverrideRule">
        <xsl:with-param name="ParamProperties" select="$ParamOverrideRule/wwproject:Properties/wwproject:Property" />
        <xsl:with-param name="ParamContextStyle" select="$ParamTable/wwdoc:Style" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

    <xsl:variable name="VarContextRule" select="wwprojext:GetContextRule('Table', $ParamTable/@stylename, $ParamSplit/@documentID, $ParamTable/@id)" />

    <!-- Resolve project properties -->
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

    <!-- caption -->
    <xsl:for-each select="$ParamTable/wwdoc:Caption[1][count(./wwdoc:*[local-name() != 'Style'][1]) > 0]">
      <xsl:apply-templates select="./*" mode="wwmode:content">
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$VarCargo" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
      </xsl:apply-templates>
    </xsl:for-each>

    <!-- Use StyleName? -->
    <xsl:variable name="VarUseStyleNameOption" select="$VarContextRule/wwproject:Options/wwproject:Option[@Name = 'markdown++-style-name']/@Value" />
    <xsl:variable name="VarUseStyleName" select="(string-length($ParamTable[1]/@stylename) > 0) and ($VarUseStyleNameOption = 'true')" />
    <xsl:variable name="VarStyleName2">
      <xsl:if test="$VarUseStyleName">
        <xsl:for-each select="$GlobalDefaultTableStyles">
          <xsl:variable name="VarStyle" select="key('wwmddefaults-table-styles-by-name', $ParamTable[1]/@stylename)" />
          <xsl:if test="count($VarStyle) = 0">
            <xsl:value-of select="$ParamTable[1]/@stylename" />
          </xsl:if>
        </xsl:for-each>
      </xsl:if>
    </xsl:variable>

    <!-- Process table without caption -->
    <xsl:variable name="VarTableAsXML">
      <xsl:element name="table" namespace="">
        <xsl:for-each select="$ParamTable/wwdoc:TableHead|$ParamTable/wwdoc:TableBody|$ParamTable/wwdoc:TableFoot">
          <xsl:variable name="VarSection" select="." />
          <xsl:variable name="VarSectionPosition" select="position()" />

          <!-- Resolve section properties -->
          <xsl:variable name="VarResolvedSectionPropertiesAsXML">
            <xsl:call-template name="Properties-Table-Section-ResolveContextRule">
              <xsl:with-param name="ParamProperties" select="$VarContextRule/wwproject:Properties/wwproject:Property" />
              <xsl:with-param name="ParamDocumentContext" select="$ParamTable" />
              <xsl:with-param name="ParamTable" select="$ParamTable" />
              <xsl:with-param name="ParamSection" select="$VarSection" />
            </xsl:call-template>
          </xsl:variable>
          <xsl:variable name="VarResolvedSectionProperties" select="msxsl:node-set($VarResolvedSectionPropertiesAsXML)/wwproject:Property" />

          <!-- Process section rows -->
          <xsl:for-each select="$VarSection/wwdoc:TableRow">
            <xsl:variable name="VarTableRow" select="." />
            <xsl:variable name="VarRowPosition" select="position()" />

            <xsl:element name="tr" namespace="">
              <xsl:for-each select="$VarTableRow/wwdoc:TableCell">
                <xsl:variable name="VarTableCell" select="." />
                <xsl:variable name="VarCellPosition" select="position()" />

                <!-- Calculate row span -->
                <xsl:variable name="VarRowSpan">
                  <xsl:variable name="VarRowSpanHint" select="$VarTableCell/wwdoc:Style/wwdoc:Attribute[@name = 'row-span']/@value" />
                  <xsl:choose>
                    <xsl:when test="string-length($VarRowSpanHint) > 0">
                      <xsl:value-of select="$VarRowSpanHint" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>

                <!-- Calculate column span -->
                <xsl:variable name="VarColumnSpan">
                  <xsl:variable name="VarColumnSpanHint" select="$VarTableCell/wwdoc:Style/wwdoc:Attribute[@name = 'column-span']/@value" />
                  <xsl:choose>
                    <xsl:when test="string-length($VarColumnSpanHint) > 0">
                      <xsl:value-of select="$VarColumnSpanHint" />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="'0'" />
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>

                <!-- Emit cell with proper th/td tagging -->
                <xsl:variable name="VarCellTag">
                  <xsl:choose>
                    <xsl:when test="($VarSectionPosition = 1) and ($VarRowPosition = 1)">
                      <xsl:text>th</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>td</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>

                <xsl:element name="{$VarCellTag}" namespace="">
                  <!-- Row span attribute -->
                  <xsl:if test="number($VarRowSpan) > 0">
                    <xsl:attribute name="rowspan">
                      <xsl:value-of select="$VarRowSpan" />
                    </xsl:attribute>
                  </xsl:if>

                  <!-- Column span attribute -->
                  <xsl:if test="number($VarColumnSpan) > 0">
                    <xsl:attribute name="colspan">
                      <xsl:value-of select="$VarColumnSpan" />
                    </xsl:attribute>
                  </xsl:if>

                  <!-- Recurse -->
                  <xsl:apply-templates select="./*" mode="wwmode:content">
                    <xsl:with-param name="ParamSplits" select="$ParamSplits" />
                    <xsl:with-param name="ParamCargo" select="$VarCargo" />
                    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
                    <xsl:with-param name="ParamSplit" select="$ParamSplit" />
                  </xsl:apply-templates>
                </xsl:element>
              </xsl:for-each>

            </xsl:element>
          </xsl:for-each>
        </xsl:for-each>

      </xsl:element>
    </xsl:variable>
    <xsl:variable name="VarTable2" select="msxsl:node-set($VarTableAsXML)" />

    <xsl:call-template name="Markdown-Table">
      <xsl:with-param name="ParamTable" select="$VarTable2" />
      <xsl:with-param name="ParamStyleName" select="$ParamStyleName" />
    </xsl:call-template>

    <!-- Table Footnotes -->
    <xsl:call-template name="Content-Notes">
      <xsl:with-param name="ParamNotes" select="$VarNotes" />
      <xsl:with-param name="ParamSplits" select="$ParamSplits" />
      <xsl:with-param name="ParamCargo" select="$VarCargo" />
      <xsl:with-param name="ParamLinks" select="$ParamLinks" />
      <xsl:with-param name="ParamSplit" select="$ParamSplit" />
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
