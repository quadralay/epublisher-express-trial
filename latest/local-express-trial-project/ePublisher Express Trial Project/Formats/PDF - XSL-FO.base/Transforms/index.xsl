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
                              exclude-result-prefixes="xsl msxsl wwindex wwlinks wwmode wwfiles wwdoc wwsplits wwbehaviors wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwfilesext wwprojext wwexsldoc"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterLinksType" />
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

 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Generate Index? -->
   <!--                 -->
   <xsl:if test="wwprojext:GetFormatSetting('index-generate', 'true') = 'true'">
    <!-- Iterate input documents -->
    <!--                         -->
    <xsl:for-each select="$GlobalFiles[1]">
     <xsl:variable name="VarLinksFile" select="key('wwfiles-files-by-type', $ParameterLinksType)" />
     <xsl:variable name="VarLinks" select="wwexsldoc:LoadXMLWithoutResolver($VarLinksFile/@path)" />

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
        <xsl:variable name="VarIndex" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesDocument/@path)" />

        <xsl:call-template name="Index">
         <xsl:with-param name="ParamIndex" select="$VarIndex" />
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
   </xsl:if>

  </wwfiles:Files>
 </xsl:template>


 <xsl:template name="Index">
  <xsl:param name="ParamIndex" />
  <xsl:param name="ParamLinks" />

  <fo:root>
   <xsl:variable name="VarStylePrefix" select="wwprojext:GetFormatSetting('index-style-prefix')" />

   <xsl:call-template name="Sections">
    <xsl:with-param name="ParamIndex" select="$ParamIndex/wwindex:Index" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamStylePrefix" select="$VarStylePrefix" />
   </xsl:call-template>
  </fo:root>
 </xsl:template>


 <xsl:template name="Sections">
  <xsl:param name="ParamIndex" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamStylePrefix" />

  <xsl:for-each select="$ParamIndex/wwindex:Section">
   <xsl:variable name="VarSection" select="." />

   <xsl:call-template name="Groups">
    <xsl:with-param name="ParamSection" select="$VarSection" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamStylePrefix" select="$ParamStylePrefix" />
   </xsl:call-template>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Groups">
  <xsl:param name="ParamSection" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamStylePrefix" />

  <xsl:for-each select="$ParamSection/wwindex:Group">
   <xsl:variable name="VarGroup" select="." />

   <fo:block>
    <xsl:variable name="VarGroupRuleName" select="concat($ParamStylePrefix, 'Group')" />
    <xsl:variable name="VarGroupRuleExists">
     <xsl:for-each select="$GlobalProject[1]">
      <xsl:variable name="VarGroupRuleHint" select="key('wwproject-rules-by-key', $VarGroupRuleName)[1]" />

      <xsl:choose>
       <xsl:when test="count($VarGroupRuleHint) = 1">
        <xsl:text>true</xsl:text>
       </xsl:when>
       <xsl:otherwise>
        <xsl:text>false</xsl:text>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:for-each>
    </xsl:variable>
 
    <!-- Emit style attributes -->
    <!--                       -->
    <xsl:choose>
     <xsl:when test="$VarGroupRuleExists = 'true'">
      <xsl:variable name="VarGroupRule" select="wwprojext:GetRule('Paragraph', $VarGroupRuleName)" />

      <xsl:variable name="VarResolvedRulePropertiesAsXML">
       <xsl:call-template name="Properties-ResolveRule">
        <xsl:with-param name="ParamDocumentContext" select="$ParamSection/wwdoc:NoContext" />
        <xsl:with-param name="ParamProperties" select="$VarGroupRule/wwproject:Properties/wwproject:Property" />
        <xsl:with-param name="ParamStyleName" select="$VarGroupRuleName" />
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
      <!-- Suitable defaults -->
      <!--                   -->
      <xsl:attribute name="font-size">18pt</xsl:attribute>
      <xsl:attribute name="font-weight">bold</xsl:attribute>
     </xsl:otherwise>
    </xsl:choose>

    <xsl:value-of select="$VarGroup/@name" />
   </fo:block>

   <xsl:call-template name="Entries">
    <xsl:with-param name="ParamParent" select="$VarGroup" />
    <xsl:with-param name="ParamLinks" select="$ParamLinks" />
    <xsl:with-param name="ParamLevel" select="1" />
    <xsl:with-param name="ParamStylePrefix" select="$ParamStylePrefix" />
   </xsl:call-template>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Entries">
  <xsl:param name="ParamParent" />
  <xsl:param name="ParamLinks" />
  <xsl:param name="ParamLevel" />
  <xsl:param name="ParamStylePrefix" />


  <xsl:for-each select="$ParamParent/wwindex:Entry">
   <xsl:variable name="VarEntry" select="." />

   <xsl:variable name="VarSee" select="$VarEntry/wwindex:See[1]" />

   <fo:block>
    <xsl:variable name="VarIndexRuleName" select="concat($ParamStylePrefix, $ParamLevel)" />
    <xsl:variable name="VarIndexRuleExists">
     <xsl:for-each select="$GlobalProject[1]">
      <xsl:variable name="VarIndexRuleHint" select="key('wwproject-rules-by-key', $VarIndexRuleName)[1]" />

      <xsl:choose>
       <xsl:when test="count($VarIndexRuleHint) = 1">
        <xsl:text>true</xsl:text>
       </xsl:when>
       <xsl:otherwise>
        <xsl:text>false</xsl:text>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:for-each>
    </xsl:variable>

    <!-- Emit style attributes -->
    <!--                       -->
    <xsl:choose>
     <xsl:when test="$VarIndexRuleExists = 'true'">
      <xsl:variable name="VarIndexRule" select="wwprojext:GetRule('Paragraph', $VarIndexRuleName)" />

      <xsl:variable name="VarResolvedRulePropertiesAsXML">
       <xsl:call-template name="Properties-ResolveRule">
        <xsl:with-param name="ParamDocumentContext" select="$ParamParent/wwdoc:NoContext" />
        <xsl:with-param name="ParamProperties" select="$VarIndexRule/wwproject:Properties/wwproject:Property" />
        <xsl:with-param name="ParamStyleName" select="$VarIndexRuleName" />
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
     </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
     <xsl:when test="count($VarSee) = 1">
      <!-- See/See Also -->
      <!--              -->
      <xsl:call-template name="Content">
       <xsl:with-param name="ParamContent" select="$VarEntry/wwdoc:Content[1]" />
      </xsl:call-template>
      
      <xsl:text> </xsl:text>

      <fo:basic-link internal-destination="index_{$VarSee/@entryID}">
       <fo:page-number-citation ref-id="index_{$VarSee/@entryID}" />
      </fo:basic-link>
     </xsl:when>

     <xsl:otherwise>
      <!-- Regular entry -->
      <!--               -->
      <xsl:variable name="VarLinks" select="$VarEntry/wwindex:Link" />

      <xsl:choose>
       <xsl:when test="count($VarLinks) = 0">
        <!-- Emit entry without any links -->
        <!--                              -->
        <xsl:choose>
         <xsl:when test="string-length($VarEntry/@id) &gt; 0">
          <fo:inline id="index_{$VarEntry/@id}">
           <xsl:call-template name="Content">
            <xsl:with-param name="ParamContent" select="$VarEntry/wwdoc:Content[1]" />
           </xsl:call-template>
          </fo:inline>
         </xsl:when>

         <xsl:otherwise>
          <xsl:call-template name="Content">
           <xsl:with-param name="ParamContent" select="$VarEntry/wwdoc:Content[1]" />
          </xsl:call-template>
         </xsl:otherwise>
        </xsl:choose>
       </xsl:when>

       <xsl:when test="(count($VarLinks) = 1) and (count($VarLinks[1]/wwdoc:Content[1]) = 0)">
        <!-- Wrap link directly around entry -->
        <!--                                 -->
        <xsl:variable name="VarLink" select="$VarLinks[1]" />

        <!-- Make link target -->
        <!--                  -->
        <xsl:variable name="VarLinkTarget">
         <xsl:for-each select="$ParamLinks[1]">
          <xsl:variable name="VarLinksFile" select="key('wwlinks-files-by-path', $VarLink/@href)[1]" />

          <xsl:text>w</xsl:text>
          <xsl:value-of select="$VarLinksFile/@groupID" />
          <xsl:text>_</xsl:text>
          <xsl:value-of select="$VarLinksFile/@documentID" />
          <xsl:text>_</xsl:text>
          <xsl:value-of select="$VarLink/@anchor" />
         </xsl:for-each>
        </xsl:variable>

        <xsl:call-template name="Content">
         <xsl:with-param name="ParamContent" select="$VarEntry/wwdoc:Content[1]" />
        </xsl:call-template>

        <xsl:text> </xsl:text>

        <fo:basic-link internal-destination="{$VarLinkTarget}">
         <fo:page-number-citation ref-id="{$VarLinkTarget}" />
        </fo:basic-link>
       </xsl:when>

       <xsl:otherwise>
        <!-- Emit entry followed by links -->
        <!--                              -->
        <xsl:choose>
         <xsl:when test="string-length($VarEntry/@id) &gt; 0">
          <fo:inline id="index_{$VarEntry/@id}">
           <xsl:call-template name="Content">
            <xsl:with-param name="ParamContent" select="$VarEntry/wwdoc:Content[1]" />
           </xsl:call-template>
          </fo:inline>
         </xsl:when>

         <xsl:otherwise>
          <xsl:call-template name="Content">
           <xsl:with-param name="ParamContent" select="$VarEntry/wwdoc:Content[1]" />
          </xsl:call-template>
         </xsl:otherwise>
        </xsl:choose>

        <xsl:text>&#160;</xsl:text>

        <!-- Links -->
        <!--       -->
        <xsl:for-each select="$VarLinks">
         <xsl:variable name="VarLink" select="." />

         <!-- Space things out a bit -->
         <!--                        -->
         <xsl:if test="position() &gt; 1">
          <xsl:text>,</xsl:text>
         </xsl:if>
         <xsl:text> </xsl:text>

         <!-- Make link target -->
         <!--                  -->
         <xsl:variable name="VarLinkTarget">
          <xsl:for-each select="$ParamLinks[1]">
           <xsl:variable name="VarLinksFile" select="key('wwlinks-files-by-path', $VarLink/@href)[1]" />

           <xsl:text>w</xsl:text>
           <xsl:value-of select="$VarLinksFile/@groupID" />
           <xsl:text>_</xsl:text>
           <xsl:value-of select="$VarLinksFile/@documentID" />
           <xsl:text>_</xsl:text>
           <xsl:value-of select="$VarLink/@anchor" />
          </xsl:for-each>
         </xsl:variable>

         <xsl:choose>
          <xsl:when test="count($VarLink/wwdoc:Content[1]) = 1">
           <!-- Link has explicit text to show -->
           <!--                                -->
           <xsl:variable name="VarLinkSee" select="$VarLink/wwdoc:See[1]" />
           <xsl:choose>
            <xsl:when test="count($VarLinkSee) = 1">
             <!-- See/See Also link redirect -->
             <!--                            -->
             <xsl:call-template name="Content">
              <xsl:with-param name="ParamContent" select="$VarLink/wwdoc:Content[1]" />
             </xsl:call-template>
             
             <fo:basic-link internal-destination="index_{$VarLinkSee/@entryID}">
              <fo:page-number-citation ref-id="index_{$VarLinkSee/@entryID}" />
             </fo:basic-link>
            </xsl:when>

            <xsl:otherwise>
             <xsl:call-template name="Content">
              <xsl:with-param name="ParamContent" select="$VarLink/wwdoc:Content[1]" />
             </xsl:call-template>

             <fo:basic-link internal-destination="{$VarLinkTarget}">
              <fo:page-number-citation ref-id="{$VarLinkTarget}" />
             </fo:basic-link>
            </xsl:otherwise>
           </xsl:choose>
          </xsl:when>

          <xsl:otherwise>
           <!-- Emit numbered entry -->
           <!--                     -->
           <fo:basic-link internal-destination="{$VarLinkTarget}">
            <fo:page-number-citation ref-id="{$VarLinkTarget}"/>
           </fo:basic-link>
          </xsl:otherwise>
         </xsl:choose>
        </xsl:for-each>
       </xsl:otherwise>
      </xsl:choose>
     </xsl:otherwise>
    </xsl:choose>

   </fo:block>

   <!-- Process children -->
   <!--                  -->
   <xsl:for-each select="$VarEntry/wwindex:Entry[1]">
    <xsl:call-template name="Entries">
     <xsl:with-param name="ParamParent" select="$VarEntry" />
     <xsl:with-param name="ParamLinks" select="$ParamLinks" />
     <xsl:with-param name="ParamLevel" select="$ParamLevel + 1" />
     <xsl:with-param name="ParamStylePrefix" select="$ParamStylePrefix" />
    </xsl:call-template>
   </xsl:for-each>
  </xsl:for-each>
 </xsl:template>


 <xsl:template name="Content">
  <xsl:param name="ParamContent" />

  <!-- Simple processing for now -->
  <!--                           -->
  <xsl:for-each select="$ParamContent/wwdoc:TextRun/wwdoc:Text">
   <xsl:value-of select="@value" />
  </xsl:for-each>
 </xsl:template>
</xsl:stylesheet>
