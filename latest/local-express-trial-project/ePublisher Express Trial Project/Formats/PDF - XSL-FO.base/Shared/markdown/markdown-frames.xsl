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
  xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
  xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
  xmlns:wwimaging="urn:WebWorks-XSLT-Extension-Imaging"
  xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
  exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwbehaviors wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc html"
>

  <!-- Shared named templates for Frame rendering and Image Maps.
       These are extracted from format content transforms to reduce duplication.
       Assumptions:
       - Callers include required common modules (properties, css, links, images, uri, units, etc.)
       - Match templates for wwdoc:Frame in appropriate modes remain in caller and invoke name="Frame".
  -->

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
        <xsl:for-each select="$GlobalFiles[1]">

          <!-- Emit markup -->
          <!--             -->
          <xsl:call-template name="Frame-Markup">
            <xsl:with-param name="ParamFrame" select="$ParamFrame" />
            <xsl:with-param name="ParamSplits" select="$ParamSplits" />
            <xsl:with-param name="ParamCargo" select="$ParamCargo" />
            <xsl:with-param name="ParamLinks" select="$ParamLinks" />
            <xsl:with-param name="ParamSplit" select="$ParamSplit" />
            <xsl:with-param name="ParamSplitsFrame" select="$VarSplitsFrame" />
            <xsl:with-param name="ParamThumbnail" select="false()" />
          </xsl:call-template>
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
      <!-- Video or Object? -->
      <!--                  -->
      <xsl:variable name="VarVideoFacet" select="$ParamFrame//wwdoc:Facet[@type = 'video'][1]" />
      <xsl:choose>
        <!-- Video -->
        <!--       -->
        <xsl:when test="(count($VarVideoFacet) = 1) and ((count($ParamSplitsFrame/wwsplits:Media[1]) = 1) or (string-length($VarVideoFacet/wwdoc:Attribute[@name = 'src'][1]/@value) > 0))">
          <xsl:call-template name="Frame-Markup-Video">
            <xsl:with-param name="ParamFrame" select="$ParamFrame" />
            <xsl:with-param name="ParamSplits" select="$ParamSplits" />
            <xsl:with-param name="ParamCargo" select="$ParamCargo" />
            <xsl:with-param name="ParamLinks" select="$ParamLinks" />
            <xsl:with-param name="ParamSplit" select="$ParamSplit" />
            <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
            <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
            <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
          </xsl:call-template>
        </xsl:when>

        <!-- Object -->
        <!--        -->
        <xsl:when test="count($ParamFrame//wwdoc:Facet[@type = 'object'][1]) = 1">
          <xsl:call-template name="Frame-Markup-Object">
            <xsl:with-param name="ParamFrame" select="$ParamFrame" />
            <xsl:with-param name="ParamSplits" select="$ParamSplits" />
            <xsl:with-param name="ParamCargo" select="$ParamCargo" />
            <xsl:with-param name="ParamLinks" select="$ParamLinks" />
            <xsl:with-param name="ParamSplit" select="$ParamSplit" />
            <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
            <xsl:with-param name="ParamContextRule" select="$VarContextRule" />
            <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
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

  <xsl:template name="Frame-Markup-Video">
    <xsl:param name="ParamFrame" />
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />
    <xsl:param name="ParamSplitsFrame" />
    <xsl:param name="ParamContextRule" />
    <xsl:param name="ParamThumbnail" />

    <!-- Determine media source -->
    <!--                        -->
    <xsl:variable name="VarSplitsMedia" select="$ParamSplitsFrame/wwsplits:Media[1]" />
    <xsl:variable name="VarVideoFacet" select="$ParamFrame//wwdoc:Facet[@type = 'video'][1]" />
    <xsl:variable name="VarVideoSrcURI">
      <xsl:choose>
        <xsl:when test="count($VarSplitsMedia) > 0">
          <xsl:value-of select="wwuri:GetRelativeTo($VarSplitsMedia/@path, $ParamSplit/@path)" />
        </xsl:when>

        <xsl:otherwise>
          <xsl:value-of select="$VarVideoFacet/wwdoc:Attribute[@name = 'src'][1]/@value" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Emit video tag? -->
    <!--                 -->
    <xsl:element name="video" namespace="">
      <!-- Class -->
      <!--       -->
      <xsl:if test="string-length(wwstring:CSSClassName($ParamFrame/@stylename)) > 0">
        <xsl:attribute name="class">
          <xsl:value-of select="wwstring:CSSClassName($ParamFrame/@stylename)" />
        </xsl:attribute>
      </xsl:if>

      <!-- @src (only if type is missing) -->
      <!--                                -->
      <xsl:if test="string-length($VarVideoFacet/wwdoc:Attribute[@name = 'type']/@value) = 0">
        <xsl:attribute name="src">
          <xsl:value-of select="$VarVideoSrcURI" />
        </xsl:attribute>
      </xsl:if>

      <!-- @width -->
      <!--        -->
      <xsl:if test="string-length($ParamFrame/@width) > 0">
        <xsl:attribute name="width">
          <xsl:value-of select="floor(wwunits:Convert(wwunits:NumericPrefix($ParamFrame/@width), wwunits:UnitsSuffix($ParamFrame/@width), 'px'))" />
        </xsl:attribute>
      </xsl:if>

      <!-- @height -->
      <!--         -->
      <xsl:if test="string-length($ParamFrame/@height) > 0">
        <xsl:attribute name="height">
          <xsl:value-of select="floor(wwunits:Convert(wwunits:NumericPrefix($ParamFrame/@height), wwunits:UnitsSuffix($ParamFrame/@height), 'px'))" />
        </xsl:attribute>
      </xsl:if>

      <!-- @controls -->
      <!--           -->
      <xsl:if test="$VarVideoFacet/wwdoc:Attribute[@name = 'controls']/@value = 'controls'">
        <xsl:attribute name="controls">
          <xsl:text>controls</xsl:text>
        </xsl:attribute>
      </xsl:if>

      <!-- @poster -->
      <!--         -->
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
      <xsl:if test="wwfilesystem:FileExists($VarImagePath)">
        <xsl:attribute name="poster">
          <xsl:value-of select="wwuri:GetRelativeTo($VarImagePath, $ParamSplit/@path)" />
        </xsl:attribute>
      </xsl:if>

      <!-- Source -->
      <!--        -->
      <xsl:if test="string-length($VarVideoFacet/wwdoc:Attribute[@name = 'type']/@value) > 0">
        <xsl:element name="source" namespace="">
          <xsl:attribute name="src">
            <xsl:value-of select="$VarVideoSrcURI" />
          </xsl:attribute>
          <xsl:attribute name="type">
            <xsl:value-of select="$VarVideoFacet/wwdoc:Attribute[@name = 'type']/@value" />
          </xsl:attribute>
        </xsl:element>
      </xsl:if>

      <!-- Emit fallback elements -->
      <!--                        -->
      <xsl:variable name="VarObjectFacet" select="$ParamFrame//wwdoc:Facet[@type = 'object'][1]" />
      <xsl:choose>
        <!-- Emit object markup -->
        <!--                    -->
        <xsl:when test="count($VarObjectFacet) = 1">
          <xsl:call-template name="Frame-Markup-Object">
            <xsl:with-param name="ParamFrame" select="$ParamFrame" />
            <xsl:with-param name="ParamSplits" select="$ParamSplits" />
            <xsl:with-param name="ParamCargo" select="$ParamCargo" />
            <xsl:with-param name="ParamLinks" select="$ParamLinks" />
            <xsl:with-param name="ParamSplit" select="$ParamSplit" />
            <xsl:with-param name="ParamSplitsFrame" select="$ParamSplitsFrame" />
            <xsl:with-param name="ParamContextRule" select="$ParamContextRule" />
            <xsl:with-param name="ParamThumbnail" select="$ParamThumbnail" />
          </xsl:call-template>
        </xsl:when>

        <!-- Emit document image -->
        <!--                     -->
        <xsl:otherwise>
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
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>

  <xsl:template name="Frame-Markup-Object">
    <xsl:param name="ParamFrame" />
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />
    <xsl:param name="ParamSplitsFrame" />
    <xsl:param name="ParamContextRule" />
    <xsl:param name="ParamThumbnail" />

    <!-- Locate object facet -->
    <!--                     -->
    <xsl:variable name="VarObjectFacet" select="$ParamFrame//wwdoc:Facet[@type = 'object'][1]" />

    <!-- Convert object to target namespace -->
    <!--                                    -->
    <xsl:for-each select="$VarObjectFacet/wwdoc:object[1]">
      <xsl:variable name="VarObject" select="." />

      <!-- Determine src -->
      <!--               -->
      <xsl:variable name="VarSplitsMedia" select="$ParamSplitsFrame/wwsplits:Media[1]" />
      <xsl:variable name="VarSrcURI">
        <xsl:choose>
          <xsl:when test="count($VarSplitsMedia) > 0">
            <xsl:value-of select="wwuri:GetRelativeTo($VarSplitsMedia/@path, $ParamSplit/@path)" />
          </xsl:when>

          <xsl:otherwise>
            <xsl:value-of select="$VarObject/@data" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="VarFLVPlayerURI">
        <xsl:if test="($VarObject/@type = 'webworks-video/x-flv') and (count($VarSplitsMedia) > 0) and (string-length($VarSrcURI) > 0)">
          <xsl:variable name="VarFLVPlayerFilePath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarSplitsMedia/@path), 'player_flv_maxi.swf')" />

          <xsl:value-of select="wwuri:GetRelativeTo($VarFLVPlayerFilePath, $ParamSplit/@path)" />
        </xsl:if>
      </xsl:variable>

      <!-- Determine type -->
      <!--                -->
      <xsl:variable name="VarType">
        <xsl:choose>
          <xsl:when test="string-length($VarFLVPlayerURI) > 0">
            <xsl:text>application/x-shockwave-flash</xsl:text>
          </xsl:when>

          <xsl:otherwise>
            <xsl:value-of select="$VarObject/@type" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:element name="object" namespace="">
        <xsl:copy-of select="@*[(name() != 'data') and (name() != 'type')]" />

        <!-- @data -->
        <!--       -->
        <xsl:if test="string-length($VarSrcURI) > 0">
          <xsl:attribute name="data">
            <xsl:choose>
              <xsl:when test="string-length($VarFLVPlayerURI) > 0">
                <xsl:value-of select="$VarFLVPlayerURI" />
              </xsl:when>

              <xsl:otherwise>
                <xsl:value-of select="$VarSrcURI" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>

        <!-- @type -->
        <!--       -->
        <xsl:if test="string-length($VarType) > 0">
          <xsl:attribute name="type">
            <xsl:value-of select="$VarType" />
          </xsl:attribute>
        </xsl:if>

        <!-- param elements -->
        <!--                -->
        <xsl:for-each select="$VarObject/wwdoc:param[(wwstring:ToLower(@name) != 'flashvars') or (wwstring:ToLower(@name) != 'allowfullscreen')]">
          <xsl:variable name="VarParam" select="." />

          <xsl:variable name="VarValue">
            <xsl:choose>
              <xsl:when test="(($VarParam/@name = 'src') or ($VarParam/@name = 'filename') or ($VarParam/@name = 'movie') or ($VarParam/@name = 'mediafile')) and (string-length($VarSrcURI) > 0)">
                <xsl:choose>
                  <xsl:when test="string-length($VarFLVPlayerURI) > 0">
                    <xsl:value-of select="$VarFLVPlayerURI" />
                  </xsl:when>

                  <xsl:otherwise>
                    <xsl:value-of select="$VarSrcURI" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>

              <xsl:otherwise>
                <xsl:value-of select="$VarParam/@value" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:element name="param" namespace="">
            <xsl:attribute name="name">
              <xsl:value-of select="$VarParam/@name" />
            </xsl:attribute>
            <xsl:attribute name="value">
              <xsl:value-of select="$VarValue"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:for-each>

        <!-- allowFullScreen param -->
        <!--                       -->
        <xsl:variable name="VarAllowFullScreen">
          <xsl:choose>
            <xsl:when test="string-length($VarObject/wwdoc:param[wwstring:ToLower(@name) = 'allowfullscreen']/@value) > 0">
              <xsl:value-of select="$VarObject/wwdoc:param[wwstring:ToLower(@name) = 'allowfullscreen']/@value" />
            </xsl:when>

            <xsl:otherwise>
              <xsl:text>true</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="string-length($VarAllowFullScreen) > 0">
          <xsl:element name="param" namespace="">
            <xsl:attribute name="name">
              <xsl:text>allowFullScreen</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="value">
              <xsl:value-of select="$VarAllowFullScreen"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:if>

        <!-- FlashVars param -->
        <!--                 -->
        <xsl:choose>
          <xsl:when test="string-length($VarFLVPlayerURI) > 0">
            <!-- Flash movie -->
            <!--             -->
            <xsl:variable name="VarFLVURI" select="wwfilesystem:GetFileName($VarSplitsMedia/@path)" />

            <!-- startimage -->
            <!--            -->
            <xsl:variable name="VarStartImage">
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

                <xsl:text>&amp;startimage=</xsl:text>
                <xsl:value-of select="wwuri:GetRelativeTo($VarImagePath, $ParamSplit/@path)" />
              </xsl:if>
            </xsl:variable>

            <xsl:element name="param" namespace="">
              <xsl:attribute name="name">
                <xsl:text>FlashVars</xsl:text>
              </xsl:attribute>
              <xsl:attribute name="value">
                <xsl:value-of select="flv=wwstring:EncodeURIComponent($VarFLVURI)" />
                <xsl:value-of select="$VarStartImage" />
                <xsl:text>&amp;autoplay=0&amp;autoload=0&amp;showvolume=1&amp;showfullscreen=1</xsl:text>
              </xsl:attribute>
            </xsl:element>
          </xsl:when>

          <xsl:otherwise>
            <xsl:copy-of select="$VarObject/wwdoc:param[wwstring:ToLower(@name) = 'flashvars']" />
          </xsl:otherwise>
        </xsl:choose>

        <!-- Emit document image -->
        <!--                     -->
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
      </xsl:element>
    </xsl:for-each>
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

      <!-- Width/Height -->
      <!--              -->
      <xsl:variable name="VarByReferenceGraphicsUseDocumentDimensionsOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'by-reference-use-document-dimensions']/@Value" />
      <xsl:variable name="VarByReferenceGraphicsUseDocumentDimensions" select="(string-length($VarByReferenceGraphicsUseDocumentDimensionsOption) = 0) or ($VarByReferenceGraphicsUseDocumentDimensionsOption = 'true')" />
      <xsl:variable name="VarWidth">
        <xsl:choose>
          <xsl:when test="count($VarResolvedProperties[@Name = 'width']) = 0">
            <xsl:value-of select="0" />
          </xsl:when>

          <xsl:when test="$ParamThumbnail">
            <xsl:value-of select="number($ParamImageInfo/@width)" />
          </xsl:when>

          <xsl:when test="($ParamSplitsFrame/@byref = 'true') and (($VarByReferenceGraphicsUseDocumentDimensions) or (number($ParamImageInfo/@width) = 0))">
            <xsl:variable name="VarByReferenceFrame" select="$ParamFrame//wwdoc:Facet[@type = 'by-reference'][1]/../.." />

            <xsl:value-of select="floor(wwunits:Convert(wwunits:NumericPrefix($VarByReferenceFrame/wwdoc:Attribute[@name = 'width']/@value), 'pt', 'px'))" />
          </xsl:when>

          <xsl:otherwise>
            <!-- Property defined? -->
            <!--                   -->
            <xsl:variable name="VarOptionMaxDimensionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-width']/@Value" />
            <xsl:variable name="VarOptionMaxDimension" select="($VarOptionMaxDimensionValue != 'none') and (string-length($VarOptionMaxDimensionValue > 0)) and (number($VarOptionMaxDimensionValue) > 0)" />
            <xsl:variable name="VarOptionScaleValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />
            <xsl:variable name="VarOptionScale" select="($VarOptionScaleValue != 'none') and (string-length($VarOptionScaleValue > 0)) and (number($VarOptionScaleValue) > 0)" />
            <xsl:variable name="VarPropertyDimension" select="$VarResolvedProperties[@Name = 'width' and @Source = 'Explicit']/@Value" />
            <xsl:choose>
              <!-- Use property defined dimension -->
              <!--                                -->
              <xsl:when test="not($VarOptionMaxDimension) and not($VarOptionScale) and (string-length($VarPropertyDimension) > 0)">
                <xsl:variable name="VarDimensionPrefix" select="wwunits:NumericPrefix($VarPropertyDimension)" />
                <xsl:variable name="VarDimensionSuffix" select="wwunits:UnitsSuffix($VarPropertyDimension)" />
                <xsl:choose>
                  <xsl:when test="$VarDimensionSuffix = '%'">
                    <xsl:value-of select="$VarPropertyDimension" />
                  </xsl:when>

                  <xsl:otherwise>
                    <xsl:value-of select="floor(wwunits:Convert($VarDimensionPrefix, $VarDimensionSuffix, 'px'))" />
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
            <xsl:value-of select="0" />
          </xsl:when>

          <xsl:when test="$ParamThumbnail">
            <xsl:value-of select="number($ParamImageInfo/@height)" />
          </xsl:when>

          <xsl:when test="($ParamSplitsFrame/@byref = 'true') and (($VarByReferenceGraphicsUseDocumentDimensions) or (number($ParamImageInfo/@height) = 0))">
            <xsl:variable name="VarByReferenceFrame" select="$ParamFrame//wwdoc:Facet[@type = 'by-reference'][1]/../.." />

            <xsl:value-of select="floor(wwunits:Convert(wwunits:NumericPrefix($VarByReferenceFrame/wwdoc:Attribute[@name = 'height']/@value), 'pt', 'px'))" />
          </xsl:when>

          <xsl:otherwise>
            <!-- Property defined? -->
            <!--                   -->
            <xsl:variable name="VarOptionMaxDimensionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-height']/@Value" />
            <xsl:variable name="VarOptionMaxDimension" select="($VarOptionMaxDimensionValue != 'none') and (string-length($VarOptionMaxDimensionValue > 0)) and (number($VarOptionMaxDimensionValue) > 0)" />
            <xsl:variable name="VarOptionScaleValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />
            <xsl:variable name="VarOptionScale" select="($VarOptionScaleValue != 'none') and (string-length($VarOptionScaleValue > 0)) and (number($VarOptionScaleValue) > 0)" />
            <xsl:variable name="VarPropertyDimension" select="$VarResolvedProperties[@Name = 'height' and @Source = 'Explicit']/@Value" />
            <xsl:choose>
              <!-- Use property defined dimension -->
              <!--                                -->
              <xsl:when test="not($VarOptionMaxDimension) and not($VarOptionScale) and (string-length($VarPropertyDimension) > 0)">
                <xsl:variable name="VarDimensionPrefix" select="wwunits:NumericPrefix($VarPropertyDimension)" />
                <xsl:variable name="VarDimensionSuffix" select="wwunits:UnitsSuffix($VarPropertyDimension)" />
                <xsl:choose>
                  <xsl:when test="$VarDimensionSuffix = '%'">
                    <xsl:value-of select="$VarPropertyDimension" />
                  </xsl:when>

                  <xsl:otherwise>
                    <xsl:value-of select="floor(wwunits:Convert($VarDimensionPrefix, $VarDimensionSuffix, 'px'))" />
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

      <!-- Responsive image? -->
      <!--                   -->
      <xsl:variable name="VarOptionResponsiveImageSize" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'responsive-image-size']/@Value" />
      <xsl:variable name="VarResponsiveImageSize" select="($VarWidth != '0') and ($VarOptionResponsiveImageSize = 'true')" />

      <!-- CSS properties -->
      <!--                -->
      <xsl:variable name="VarCSSPropertiesAsXML">
        <xsl:call-template name="CSS-TranslateImageObjectProjectProperties">
          <xsl:with-param name="ParamProperties" select="$VarResolvedProperties[(@Name != 'width') and (@Name != 'height')]" />
          <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplit/@path" />
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        </xsl:call-template>

        <xsl:if test="$VarResponsiveImageSize">
          <xsl:if test="$VarWidth != '0'">
            <wwproject:Property Name="max-width" Value="{$VarWidth}px" />
          </xsl:if>
          <xsl:if test="$VarHeight != '0'">
            <wwproject:Property Name="max-height" Value="{$VarHeight}px" />
          </xsl:if>
        </xsl:if>
      </xsl:variable>
      <xsl:variable name="VarCSSProperties" select="msxsl:node-set($VarCSSPropertiesAsXML)/wwproject:Property" />
      <xsl:variable name="VarInlineCSSProperties">
        <xsl:call-template name="CSS-InlineProperties">
          <xsl:with-param name="ParamProperties" select="$VarCSSProperties[string-length(@Value) > 0]" />
        </xsl:call-template>
      </xsl:variable>

      <!-- Src -->
      <!--     -->
      <xsl:variable name="VarSrc" select="wwuri:GetRelativeTo($ParamImageInfo/@path, $ParamSplit/@path)" />

      <!-- Alt Text -->
      <!--          -->
      <xsl:variable name="VarAltText">
        <xsl:call-template name="Images-AltText">
          <xsl:with-param name="ParamFrame" select="$ParamFrame" />
          <xsl:with-param name="ParamBehaviorFrame" select="$VarBehaviorFrame" />
        </xsl:call-template>
      </xsl:variable>


      <!-- Graphic element -->
      <!--                 -->
      <xsl:element name="object" namespace="">
        <!-- Type attribute -->
        <!--                -->
        <xsl:attribute name="type">
          <xsl:text>image/svg+xml</xsl:text>
        </xsl:attribute>

        <!-- Data attribute -->
        <!--                -->
        <xsl:attribute name="data">
          <xsl:value-of select="$VarSrc" />
        </xsl:attribute>

        <!-- Width attribute -->
        <!--                 -->
        <xsl:choose>
          <xsl:when test="$VarResponsiveImageSize">
            <xsl:attribute name="width">
              <xsl:text>100%</xsl:text>
            </xsl:attribute>
          </xsl:when>

          <xsl:otherwise>
            <xsl:if test="$VarWidth != '0'">
              <xsl:attribute name="width">
                <xsl:value-of select="$VarWidth"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>

        <!-- Height attribute -->
        <!--                  -->
        <xsl:if test="not($VarResponsiveImageSize)">
          <xsl:if test="$VarHeight != '0'">
            <xsl:attribute name="height">
              <xsl:value-of select="$VarHeight"/>
            </xsl:attribute>
          </xsl:if>
        </xsl:if>

        <!-- Style attribute -->
        <!--                 -->
        <xsl:if test="string-length($VarInlineCSSProperties) > 0">
          <xsl:attribute name="style">
            <xsl:value-of select="$VarInlineCSSProperties" />
          </xsl:attribute>
        </xsl:if>

        <!-- Title attribute -->
        <!--                 -->
        <xsl:choose>
          <xsl:when test="string-length($VarAltText) > 0">
            <xsl:attribute name="title">
              <xsl:value-of select="$VarAltText" />
            </xsl:attribute>
          </xsl:when>

          <xsl:when test="string-length($ParamSplitsFrame/@title) > 0">
            <xsl:attribute name="title">
              <xsl:value-of select="$ParamSplitsFrame/@title" />
            </xsl:attribute>
          </xsl:when>
        </xsl:choose>

        <!-- Src parameter -->
        <!--               -->
        <xsl:element name="param">
          <xsl:attribute name="name">
            <xsl:text>src</xsl:text>
          </xsl:attribute>
          <xsl:attribute name="value">
            <xsl:value-of select="$VarSrc" />
          </xsl:attribute>
          <xsl:attribute name="valuetype">
            <xsl:text>data</xsl:text>
          </xsl:attribute>
        </xsl:element>
      </xsl:element>

    </xsl:for-each>
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

      <!-- Override Rule -->
      <!--               -->
      <xsl:variable name="VarOverrideRule" select="wwprojext:GetOverrideRule('Graphic', $ParamSplitsFrame/@stylename, $ParamSplitsFrame/@documentID, $ParamSplitsFrame/@id)" />

      <!-- Resolve project properties -->
      <!--                            -->
      <xsl:variable name="VarResolvedPropertiesAsXML">
        <xsl:call-template name="Properties-ResolveOverrideRule">
          <xsl:with-param name="ParamProperties" select="$VarOverrideRule/wwproject:Properties/wwproject:Property" />
          <xsl:with-param name="ParamContextStyle" select="$ParamFrame" />
          <xsl:with-param name="ParamStyleType" select="'Graphic'" />
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="VarResolvedProperties" select="msxsl:node-set($VarResolvedPropertiesAsXML)/wwproject:Property" />

      <!-- Width/Height -->
      <!--              -->
      <xsl:variable name="VarByReferenceGraphicsUseDocumentDimensionsOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'by-reference-use-document-dimensions']/@Value" />
      <xsl:variable name="VarByReferenceGraphicsUseDocumentDimensions" select="(string-length($VarByReferenceGraphicsUseDocumentDimensionsOption) = 0) or ($VarByReferenceGraphicsUseDocumentDimensionsOption = 'true')" />
      <xsl:variable name="VarWidth">
        <xsl:choose>
          <xsl:when test="count($VarResolvedProperties[@Name = 'width']) = 0">
            <xsl:value-of select="0" />
          </xsl:when>

          <xsl:when test="$ParamThumbnail">
            <xsl:value-of select="number($ParamImageInfo/@width)" />
          </xsl:when>

          <xsl:when test="($ParamSplitsFrame/@byref = 'true') and (($VarByReferenceGraphicsUseDocumentDimensions) or (number($ParamImageInfo/@width) = 0))">
            <xsl:variable name="VarByReferenceFrame" select="$ParamFrame//wwdoc:Facet[@type = 'by-reference'][1]/../.." />

            <xsl:value-of select="floor(wwunits:Convert(wwunits:NumericPrefix($VarByReferenceFrame/wwdoc:Attribute[@name = 'width']/@value), 'pt', 'px'))" />
          </xsl:when>

          <xsl:otherwise>
            <!-- Property defined? -->
            <!--                   -->
            <xsl:variable name="VarOptionMaxDimensionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-width']/@Value" />
            <xsl:variable name="VarOptionMaxDimension" select="($VarOptionMaxDimensionValue != 'none') and (string-length($VarOptionMaxDimensionValue > 0)) and (number($VarOptionMaxDimensionValue) > 0)" />
            <xsl:variable name="VarOptionScaleValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />
            <xsl:variable name="VarOptionScale" select="($VarOptionScaleValue != 'none') and (string-length($VarOptionScaleValue > 0)) and (number($VarOptionScaleValue) > 0)" />
            <xsl:variable name="VarPropertyDimension" select="$VarResolvedProperties[@Name = 'width' and @Source = 'Explicit']/@Value" />
            <xsl:choose>
              <!-- Use property defined dimension -->
              <!--                                -->
              <xsl:when test="not($VarOptionMaxDimension) and not($VarOptionScale) and (string-length($VarPropertyDimension) > 0)">
                <xsl:variable name="VarDimensionPrefix" select="wwunits:NumericPrefix($VarPropertyDimension)" />
                <xsl:variable name="VarDimensionSuffix" select="wwunits:UnitsSuffix($VarPropertyDimension)" />
                <xsl:choose>
                  <xsl:when test="$VarDimensionSuffix = '%'">
                    <xsl:value-of select="$VarPropertyDimension" />
                  </xsl:when>

                  <xsl:otherwise>
                    <xsl:value-of select="floor(wwunits:Convert($VarDimensionPrefix, $VarDimensionSuffix, 'px'))" />
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
            <xsl:value-of select="0" />
          </xsl:when>

          <xsl:when test="$ParamThumbnail">
            <xsl:value-of select="number($ParamImageInfo/@height)" />
          </xsl:when>

          <xsl:when test="($ParamSplitsFrame/@byref = 'true') and (($VarByReferenceGraphicsUseDocumentDimensions) or (number($ParamImageInfo/@height) = 0))">
            <xsl:variable name="VarByReferenceFrame" select="$ParamFrame//wwdoc:Facet[@type = 'by-reference'][1]/../.." />

            <xsl:value-of select="floor(wwunits:Convert(wwunits:NumericPrefix($VarByReferenceFrame/wwdoc:Attribute[@name = 'height']/@value), 'pt', 'px'))" />
          </xsl:when>

          <xsl:otherwise>
            <!-- Property defined? -->
            <!--                   -->
            <xsl:variable name="VarOptionMaxDimensionValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'max-height']/@Value" />
            <xsl:variable name="VarOptionMaxDimension" select="($VarOptionMaxDimensionValue != 'none') and (string-length($VarOptionMaxDimensionValue > 0)) and (number($VarOptionMaxDimensionValue) > 0)" />
            <xsl:variable name="VarOptionScaleValue" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'scale']/@Value" />
            <xsl:variable name="VarOptionScale" select="($VarOptionScaleValue != 'none') and (string-length($VarOptionScaleValue > 0)) and (number($VarOptionScaleValue) > 0)" />
            <xsl:variable name="VarPropertyDimension" select="$VarResolvedProperties[@Name = 'height' and @Source = 'Explicit']/@Value" />
            <xsl:choose>
              <!-- Use property defined dimension -->
              <!--                                -->
              <xsl:when test="not($VarOptionMaxDimension) and not($VarOptionScale) and (string-length($VarPropertyDimension) > 0)">
                <xsl:variable name="VarDimensionPrefix" select="wwunits:NumericPrefix($VarPropertyDimension)" />
                <xsl:variable name="VarDimensionSuffix" select="wwunits:UnitsSuffix($VarPropertyDimension)" />
                <xsl:choose>
                  <xsl:when test="$VarDimensionSuffix = '%'">
                    <xsl:value-of select="$VarPropertyDimension" />
                  </xsl:when>

                  <xsl:otherwise>
                    <xsl:value-of select="floor(wwunits:Convert($VarDimensionPrefix, $VarDimensionSuffix, 'px'))" />
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

      <!-- Responsive image? -->
      <!--                   -->
      <xsl:variable name="VarOptionResponsiveImageSize" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'responsive-image-size']/@Value" />
      <xsl:variable name="VarResponsiveImageSize" select="($VarWidth != '0') and ($VarOptionResponsiveImageSize = 'true')" />

      <!-- CSS properties -->
      <!--                -->
      <xsl:variable name="VarCSSPropertiesAsXML">
        <xsl:call-template name="CSS-TranslateImageObjectProjectProperties">
          <xsl:with-param name="ParamProperties" select="$VarResolvedProperties[(@Name != 'width') and (@Name != 'height')]" />
          <xsl:with-param name="ParamFromAbsoluteURI" select="$ParamSplit/@path" />
          <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        </xsl:call-template>

        <xsl:if test="$VarResponsiveImageSize">
          <xsl:if test="$VarWidth != '0'">
            <wwproject:Property Name="max-width" Value="{$VarWidth}px" />
          </xsl:if>
          <xsl:if test="$VarHeight != '0'">
            <wwproject:Property Name="max-height" Value="{$VarHeight}px" />
          </xsl:if>
        </xsl:if>
      </xsl:variable>
      <xsl:variable name="VarCSSProperties" select="msxsl:node-set($VarCSSPropertiesAsXML)/wwproject:Property" />
      <xsl:variable name="VarInlineCSSProperties">
        <xsl:call-template name="CSS-InlineProperties">
          <xsl:with-param name="ParamProperties" select="$VarCSSProperties[string-length(@Value) > 0]" />
        </xsl:call-template>
      </xsl:variable>

      <!-- Src -->
      <!--     -->
      <xsl:variable name="VarSrc" select="wwuri:GetRelativeTo($ParamImageInfo/@path, $ParamSplit/@path)" />

      <!-- Define Use Map -->
      <!--                -->
      <xsl:variable name="VarUseMap">
        <xsl:choose>
          <xsl:when test="($ParamThumbnail) or (count($ParamFrame//wwdoc:Link) > 0)">
            <xsl:text>#</xsl:text>
            <xsl:value-of select="$ParamSplitsFrame/@documentID" />
            <xsl:text>_</xsl:text>
            <xsl:value-of select="$ParamSplitsFrame/@id" />
          </xsl:when>

          <xsl:otherwise>
            <xsl:value-of select="''" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <!-- Alt Text -->
      <!--          -->
      <xsl:variable name="VarAltText">
        <xsl:call-template name="Images-AltText">
          <xsl:with-param name="ParamFrame" select="$ParamFrame" />
          <xsl:with-param name="ParamBehaviorFrame" select="$VarBehaviorFrame" />
        </xsl:call-template>
      </xsl:variable>

      <!-- Use StyleName? -->
      <!--                -->
      <xsl:variable name="VarUseStyleNameOption" select="$ParamContextRule/wwproject:Options/wwproject:Option[@Name = 'markdown++-style-name']/@Value" />
      <xsl:variable name="VarUseStyleName" select="(string-length($ParamFrame[1]/@stylename) > 0) and
                                               ($VarUseStyleNameOption = 'true')" />
      <xsl:variable name="VarStyleName">
        <xsl:if test="$VarUseStyleName">
          <xsl:for-each select="$GlobalDefaultGraphicStyles">
            <xsl:variable name="VarStyle" select="key('wwmddefaults-graphic-styles-by-name', $ParamFrame[1]/@stylename)" />
            <xsl:if test="count($VarStyle) = 0">
              <xsl:value-of select="$ParamFrame[1]/@stylename" />
            </xsl:if>
          </xsl:for-each>
        </xsl:if>
      </xsl:variable>

      <xsl:call-template name="Markdown-ImageLink">
        <xsl:with-param name="ParamAltText" select="$VarAltText" />
        <xsl:with-param name="ParamSrc" select="$VarSrc" />
        <xsl:with-param name="ParamTitleText" select="$VarAltText" />
        <xsl:with-param name="ParamStyleName" select="$VarStyleName" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="ImageMap">
    <xsl:param name="ParamFrame" />
    <xsl:param name="ParamSplits" />
    <xsl:param name="ParamCargo" />
    <xsl:param name="ParamParentBehavior" />
    <xsl:param name="ParamLinks" />
    <xsl:param name="ParamSplit" />
    <xsl:param name="ParamHorizontalScaling" />
    <xsl:param name="ParamVerticalScaling" />

    <!-- Process child frames first -->
    <!--                            -->
    <xsl:for-each select="$ParamFrame/wwdoc:Content//wwdoc:Frame[count($ParamFrame | ancestor::wwdoc:Frame[1]) = 1]">
      <xsl:call-template name="ImageMap">
        <xsl:with-param name="ParamFrame" select="." />
        <xsl:with-param name="ParamSplits" select="$ParamSplits" />
        <xsl:with-param name="ParamCargo" select="$ParamCargo" />
        <xsl:with-param name="ParamParentBehavior" select="$ParamParentBehavior" />
        <xsl:with-param name="ParamLinks" select="$ParamLinks" />
        <xsl:with-param name="ParamSplit" select="$ParamSplit" />
        <xsl:with-param name="ParamHorizontalScaling" select="$ParamHorizontalScaling" />
        <xsl:with-param name="ParamVerticalScaling" select="$ParamVerticalScaling" />
      </xsl:call-template>
    </xsl:for-each>

    <!-- Get link -->
    <!--          -->
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
          <xsl:variable name="VarChildLinks" select="$ParamFrame/wwdoc:Content//wwdoc:Link[count($ParamFrame | ancestor::wwdoc:Frame[1]) = 1]" />
          <xsl:variable name="VarChildLinksCount" select="count($VarChildLinks)" />
          <xsl:if test="$VarChildLinksCount > 0">
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

    <xsl:if test="string-length($VarLinkInfo/@href) > 0">
      <!-- Get coords attribute -->
      <!--                      -->
      <xsl:variable name="VarLeftAsPixels">
        <xsl:variable name="VarOrigLeftAsPixels" select="string(floor(wwunits:Convert(wwunits:NumericPrefix($ParamFrame/wwdoc:Attribute[@name = 'left']/@value), 'pt', 'px')))" />
        <xsl:choose>
          <xsl:when test="$ParamHorizontalScaling != 1">
            <xsl:value-of select="number($VarOrigLeftAsPixels) * number($ParamHorizontalScaling)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$VarOrigLeftAsPixels" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="VarTopAsPixels">
        <xsl:variable name="VarOrigTopAsPixels" select="string(floor(wwunits:Convert(wwunits:NumericPrefix($ParamFrame/wwdoc:Attribute[@name = 'top']/@value), 'pt', 'px')))" />
        <xsl:choose>
          <xsl:when test="$ParamVerticalScaling != 1">
            <xsl:value-of select="number($VarOrigTopAsPixels) * number($ParamVerticalScaling)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$VarOrigTopAsPixels" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="VarWidthAsPixels">
        <xsl:variable name="VarOrigWidthAsPixels" select="string(floor(wwunits:Convert(wwunits:NumericPrefix($ParamFrame/wwdoc:Attribute[@name = 'width']/@value), 'pt', 'px')))" />
        <xsl:choose>
          <xsl:when test="$ParamHorizontalScaling != 1">
            <xsl:value-of select="number($VarOrigWidthAsPixels) * number($ParamHorizontalScaling)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$VarOrigWidthAsPixels" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="VarHeightAsPixels">
        <xsl:variable name="VarOrigHeightAsPixels" select="string(floor(wwunits:Convert(wwunits:NumericPrefix($ParamFrame/wwdoc:Attribute[@name = 'height']/@value), 'pt', 'px')))" />
        <xsl:choose>
          <xsl:when test="$ParamVerticalScaling != 1">
            <xsl:value-of select="number($VarOrigHeightAsPixels) * number($ParamVerticalScaling)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$VarOrigHeightAsPixels" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <!-- coords -->
      <!--        -->
      <xsl:variable name="VarCoordsString">
        <xsl:choose>
          <xsl:when test="string-length($VarLeftAsPixels) > 0">
            <xsl:value-of select="$VarLeftAsPixels" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'0'" />
          </xsl:otherwise>
        </xsl:choose>

        <xsl:value-of select="','"/>

        <xsl:choose>
          <xsl:when test="string-length($VarTopAsPixels) > 0">
            <xsl:value-of select="$VarTopAsPixels" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'0'" />
          </xsl:otherwise>
        </xsl:choose>

        <xsl:value-of select="','"/>

        <xsl:choose>
          <xsl:when test="string-length($VarWidthAsPixels) > 0">
            <xsl:value-of select="string(number($VarWidthAsPixels) + number($VarLeftAsPixels))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'0'" />
          </xsl:otherwise>
        </xsl:choose>

        <xsl:value-of select="','"/>

        <xsl:choose>
          <xsl:when test="string-length($VarHeightAsPixels) > 0">
            <xsl:value-of select="string(number($VarHeightAsPixels) + number($VarTopAsPixels))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'0'" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <!-- alt -->
      <!--     -->
      <xsl:variable name="VarAltText">
        <xsl:call-template name="Images-ImageAreaAltText">
          <xsl:with-param name="ParamParentBehavior" select="$ParamParentBehavior" />
          <xsl:with-param name="ParamFrame" select="$ParamFrame" />
        </xsl:call-template>
      </xsl:variable>

      <!-- area -->
      <!--      -->
      <xsl:element name="area" namespace="">
        <xsl:attribute name="href">
          <xsl:value-of select="$VarLinkInfo/@href" />
        </xsl:attribute>
        <xsl:attribute name="coords">
          <xsl:value-of select="$VarCoordsString" />
        </xsl:attribute>
        <xsl:attribute name="shape">
          <xsl:text>rect</xsl:text>
        </xsl:attribute>

        <!-- target -->
        <!--        -->
        <xsl:if test="string-length($VarLinkInfo/@target) > 0">
          <xsl:attribute name="target">
            <xsl:value-of select="$VarLinkInfo/@target" />
          </xsl:attribute>
        </xsl:if>

        <!-- alt/title -->
        <!--           -->
        <xsl:attribute name="alt">
          <xsl:value-of select="$VarAltText" />
        </xsl:attribute>
        <xsl:attribute name="title">
          <xsl:value-of select="$VarAltText" />
        </xsl:attribute>
      </xsl:element>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
