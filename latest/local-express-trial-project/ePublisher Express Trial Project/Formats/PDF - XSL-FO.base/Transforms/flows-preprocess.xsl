<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Format"
                              xmlns:fo="http://www.w3.org/1999/XSL/Format"
                              xmlns:flo="urn:WebWorks-XSLT-Flow-Schema"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwtoc="urn:WebWorks-Engine-TOC-Schema"
                              xmlns:wwbehaviors="urn:WebWorks-Behaviors-Schema"
                              xmlns:wwvars="urn:WebWorks-Variables-Schema"
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
                              exclude-result-prefixes="fo flo xsl msxsl wwmode wwlinks wwfiles wwdoc wwsplits wwtoc wwbehaviors wwvars wwnotes wwproject wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterPageTemplateURI" />
 <xsl:param name="ParameterType" />


 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="fo" result-prefix="#default" />
 <xsl:strip-space elements="*" />


 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />

 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <!-- Page Template -->
 <!--               -->
 <xsl:variable name="GlobalPageTemplatePath" select="wwuri:AsFilePath($ParameterPageTemplateURI)" />
 <xsl:variable name="GlobalPageTemplate" select="wwexsldoc:LoadXMLWithoutResolver($GlobalPageTemplatePath)" />

 <xsl:template match="/">
  <!-- Determine page template dependency checksum -->
  <!--                                             -->
  <xsl:variable name="VarPageTemplateDependenciesAsXML">
   <xsl:apply-templates select="$GlobalPageTemplate" mode="wwmode:depends" />
  </xsl:variable>
  <xsl:variable name="VarPageTemplateDependencies" select="msxsl:node-set($VarPageTemplateDependenciesAsXML)" />
  <xsl:variable name="VarPageTemplateDependenciesChecksums">
   <xsl:for-each select="$VarPageTemplateDependencies">
    <xsl:value-of select="@path" />
    <xsl:text>:</xsl:text>
    <xsl:value-of select="@checksum" />
   </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="VarPageTemplateDependenciesChecksum" select="wwstring:MD5Checksum($VarPageTemplateDependenciesChecksums)" />
  <xsl:variable name="VarProjectChecksum">
   <xsl:value-of select="$GlobalProject/wwproject:Project/@ChangeID" />
   <xsl:text>:</xsl:text>
   <xsl:value-of select="$VarPageTemplateDependenciesChecksum" />
  </xsl:variable>

  <wwfiles:Files version="1.0">
   <xsl:for-each select="$GlobalFiles[1]">
    <!-- Group Splits -->
    <!--              -->
    <xsl:variable name="VarFiles" select="key('wwfiles-files-by-type', $ParameterDependsType)" />

    <xsl:for-each select="$VarFiles">
     <xsl:variable name="VarFile" select="." />
     <xsl:variable name="VarFlows" select="wwexsldoc:LoadXMLWithoutResolver($VarFile/@path)" />

     <!-- Aborted? -->
     <!--          -->
     <xsl:if test="not(wwprogress:Abort())">
      <xsl:for-each select="$GlobalFiles[1]">
       <xsl:variable name="VarPath" select="wwfilesystem:Combine(wwfilesystem:GetDirectoryName($VarFile/@path), concat(translate($ParameterType, ':', '_'), '.xml'))" />

       <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $VarProjectChecksum, $VarFile/@groupID, $VarFile/@documentID, $GlobalActionChecksum)" />
       <xsl:if test="not($VarUpToDate)">
        <xsl:variable name="VarResultAsXML">
         <xsl:apply-templates select="$GlobalPageTemplate/*" mode="wwmode:preprocess">
          <xsl:with-param name="ParamFlows" select="$VarFlows" />
         </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="VarResult" select="msxsl:node-set($VarResultAsXML)" />
        <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarResult, $VarPath, wwprojext:GetFormatSetting('encoding', 'utf-8'), 'xml', '1.0', 'yes')" />
       </xsl:if>

       <!-- Record files -->
       <!--              -->
       <wwfiles:File path="{$VarPath}"
                     type="{$ParameterType}"
                     checksum="{wwfilesystem:GetChecksum($VarPath)}"
                     projectchecksum="{$VarProjectChecksum}"
                     groupID="{$VarFile/@groupID}"
                     documentID="{$VarFile/@documentID}"
                     actionchecksum="{$GlobalActionChecksum}">
        <wwfiles:Depends path="{$VarFile/@path}" checksum="{$VarFile/@checksum}" groupID="{$VarFile/@groupID}" documentID="{$VarFile/@documentID}" />
        <wwfiles:Depends path="{$GlobalPageTemplatePath}" checksum="{wwfilesystem:GetChecksum($GlobalPageTemplatePath)}" groupID="" documentID="" />
        <xsl:for-each select="$VarPageTemplateDependencies">
         <xsl:copy-of select="." />
        </xsl:for-each>
       </wwfiles:File>
      </xsl:for-each>
     </xsl:if>
    </xsl:for-each>
   </xsl:for-each>
  </wwfiles:Files>
 </xsl:template>


 <!-- wwmode:depends -->
 <!--                -->

 <xsl:template match="*" mode="wwmode:depends">
  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:depends" />
 </xsl:template>

 <xsl:template match="wwpage:Macro[string-length(@source) &gt; 0]" mode="wwmode:depends">
  <!-- Emit depends element for referenced macro -->
  <!--                                           -->
  <xsl:variable name="VarSourceURI" select="wwuri:MakeAbsolute($ParameterPageTemplateURI, @source)" />
  <xsl:variable name="VarSourcePath" select="wwuri:AsFilePath($VarSourceURI)" />
  <wwfiles:Depends path="{$VarSourcePath}" checksum="{wwfilesystem:GetChecksum($VarSourcePath)}" groupID="" documentID="" />

  <!-- Process children -->
  <!--                  -->
  <xsl:apply-templates mode="wwmode:depends" />
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:depends">
  <!-- Nothing to do -->
  <!--               -->
 </xsl:template>


 <!-- wwmode:preprocess -->
 <!--                   -->

 <xsl:template match="*" mode="wwmode:preprocess">
  <xsl:param name="ParamFlows" />

  <xsl:copy>
   <xsl:copy-of select="@*" />

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:preprocess">
    <xsl:with-param name="ParamFlows" select="$ParamFlows" />
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="wwpage:Macro[@action = 'copy-layout-masters']" mode="wwmode:preprocess">
  <xsl:param name="ParamFlows" />

  <xsl:variable name="VarSourceURI" select="wwuri:MakeAbsolute($ParameterPageTemplateURI, @source)" />
  <xsl:variable name="VarSourcePath" select="wwuri:AsFilePath($VarSourceURI)" />
  <xsl:variable name="VarSource" select="wwexsldoc:LoadXMLWithoutResolver($VarSourcePath)" />

  <xsl:copy-of select="$VarSource/fo:root/fo:layout-master-set/*" />
 </xsl:template>

 <xsl:template match="wwpage:Macro[@action = 'generate-layout-masters']" mode="wwmode:preprocess">
  <xsl:param name="ParamFlows" />

  <xsl:variable name="VarSourceURI" select="wwuri:MakeAbsolute($ParameterPageTemplateURI, @source)" />
  <xsl:variable name="VarSourcePath" select="wwuri:AsFilePath($VarSourceURI)" />
  <xsl:variable name="VarSource" select="wwexsldoc:LoadXMLWithoutResolver($VarSourcePath)" />

  <xsl:for-each select="$ParamFlows/flo:Flows/flo:Flow">
   <xsl:variable name="VarFlow" select="." />

   <xsl:apply-templates select="$VarSource/fo:root/fo:layout-master-set/*" mode="wwmode:body-replace">
    <xsl:with-param name="ParamBodyReplacement" select="$VarFlow/@name" />
    <xsl:with-param name="ParamSetInitialPageNumber" select="false()" />
   </xsl:apply-templates>
  </xsl:for-each>
 </xsl:template>

 <xsl:template match="wwpage:Macro[@action = 'copy-page-sequences']" mode="wwmode:preprocess">
  <xsl:param name="ParamFlows" />

  <xsl:variable name="VarSourceURI" select="wwuri:MakeAbsolute($ParameterPageTemplateURI, @source)" />
  <xsl:variable name="VarSourcePath" select="wwuri:AsFilePath($VarSourceURI)" />
  <xsl:variable name="VarSource" select="wwexsldoc:LoadXMLWithoutResolver($VarSourcePath)" />

  <xsl:copy-of select="$VarSource/fo:root/fo:page-sequence" />
 </xsl:template>

 <xsl:template match="wwpage:Macro[@action = 'generate-page-sequences']" mode="wwmode:preprocess">
  <xsl:param name="ParamFlows" />

  <xsl:variable name="VarSourceURI" select="wwuri:MakeAbsolute($ParameterPageTemplateURI, @source)" />
  <xsl:variable name="VarSourcePath" select="wwuri:AsFilePath($VarSourceURI)" />
  <xsl:variable name="VarSource" select="wwexsldoc:LoadXMLWithoutResolver($VarSourcePath)" />

  <xsl:for-each select="$ParamFlows/flo:Flows/flo:Flow">
   <xsl:variable name="VarFlow" select="." />

   <xsl:apply-templates select="$VarSource/fo:root/fo:page-sequence" mode="wwmode:body-replace">
    <xsl:with-param name="ParamBodyReplacement" select="$VarFlow/@name" />
    <xsl:with-param name="ParamSetInitialPageNumber" select="position() = 1" />
   </xsl:apply-templates>
  </xsl:for-each>
 </xsl:template>

 <xsl:template match="wwpage:Macro[@name = 'layouts']" mode="wwmode:preprocess">
  <xsl:param name="ParamFlows" />

  <xsl:for-each select="$ParamFlows/flo:Flows/flo:Flow">
   <xsl:variable name="VarFlow" select="." />

   <fo:simple-page-master
    wwpage:replace="{$VarFlow/@name}-odd-master-page"
    master-name="{$VarFlow/@name}-odd-master-page"
    page-height="11in"
    page-width="8.5in"
    margin-top="0in"
    margin-bottom="0in"
    margin-left="0in"
    margin-right="0in"
   >
    <fo:region-body
     region-name="{$VarFlow/@name}-body"
     margin-top="1in"
     margin-bottom="1in"
     margin-left="1in"
     margin-right="1in"
    />
    <fo:region-before
     extent="1in"
     region-name="{$VarFlow/@name}-odd-header"
    />
    <fo:region-after
     extent="1in"
     region-name="{$VarFlow/@name}-odd-footer"
    />
   </fo:simple-page-master>

   <fo:simple-page-master
    wwpage:replace="{$VarFlow/@name}-even-master-page"
    master-name="{$VarFlow/@name}-even-master-page"
    page-height="11in"
    page-width="8.5in"
    margin-top="0in"
    margin-bottom="0in"
    margin-left="0in"
    margin-right="0in"
   >
    <fo:region-body
     region-name="{$VarFlow/@name}-body"
     margin-top="1in"
     margin-bottom="1in"
     margin-left="1in"
     margin-right="1in"
    />
    <fo:region-before
     extent="1in"
     region-name="{$VarFlow/@name}-even-header"
    />
    <fo:region-after
     extent="1in"
     region-name="{$VarFlow/@name}-even-footer"
    />
   </fo:simple-page-master>

   <fo:page-sequence-master master-name="{$VarFlow/@name}-pages">
    <fo:repeatable-page-master-alternatives>
     <fo:conditional-page-master-reference
      odd-or-even="even"
      master-reference="{$VarFlow/@name}-even-master-page"
     />
     <fo:conditional-page-master-reference
      odd-or-even="odd"
      master-reference="{$VarFlow/@name}-odd-master-page"
     />
    </fo:repeatable-page-master-alternatives>
   </fo:page-sequence-master>

  </xsl:for-each>
 </xsl:template>

 <xsl:template match="wwpage:Macro[@name = 'page-sequences']" mode="wwmode:preprocess">
  <xsl:param name="ParamFlows" />

  <xsl:for-each select="$ParamFlows/flo:Flows/flo:Flow">
   <xsl:variable name="VarFlow" select="." />

   <!-- Body page sequence -->
   <!--                    -->
   <fo:page-sequence master-reference="{$VarFlow/@name}-pages">
    <xsl:if test="position() = 1">
     <xsl:attribute name="initial-page-number">1</xsl:attribute>
    </xsl:if>

    <!-- Footnote separator -->
    <!--                    -->
    <xsl:comment>Footnote separator</xsl:comment>
    <fo:static-content flow-name="xsl-footnote-separator">
     <fo:block width="100%"><fo:leader leader-pattern="rule" /></fo:block>
    </fo:static-content>

    <!-- Even header -->
    <!--             -->
    <xsl:comment>Even header</xsl:comment>
    <fo:static-content flow-name="{$VarFlow/@name}-even-header" wwpage:condition="{$VarFlow/@name}-even-header-exists">
     <fo:block
      text-align="left"
      font-size="8pt"
      margin-top="10pt"
      margin-right="10pt"
      margin-bottom="10pt"
      margin-left="10pt"
      wwpage:replace="{$VarFlow/@name}-even-header"
     >
      webworks.com
     </fo:block>
    </fo:static-content>

    <!-- Odd header -->
    <!--            -->
    <xsl:comment>Odd header</xsl:comment>
    <fo:static-content flow-name="{$VarFlow/@name}-odd-header" wwpage:condition="{$VarFlow/@name}-odd-header-exists">
     <fo:block
      text-align="right"
      font-size="8pt"
      margin-top="10pt"
      margin-right="10pt"
      margin-bottom="10pt"
      margin-left="10pt"
      wwpage:replace="{$VarFlow/@name}-odd-header"
     >
      webworks.com
     </fo:block>
    </fo:static-content>

    <!-- Even footer -->
    <!--             -->
    <xsl:comment>Even footer</xsl:comment>
    <fo:static-content flow-name="{$VarFlow/@name}-even-footer" wwpage:condition="{$VarFlow/@name}-even-footer-exists">
     <fo:block
      text-align="left"
      font-size="8pt"
      margin-top="10pt"
      margin-right="10pt"
      margin-bottom="10pt"
      margin-left="10pt"
      wwpage:replace="{$VarFlow/@name}-even-footer"
     >
      webworks.com - Page <fo:page-number/>
     </fo:block>
    </fo:static-content>

    <!-- Odd footer -->
    <!--            -->
    <xsl:comment>Odd footer</xsl:comment>
    <fo:static-content flow-name="{$VarFlow/@name}-odd-footer" wwpage:condition="{$VarFlow/@name}-odd-footer-exists">
     <fo:block
      text-align="right"
      font-size="8pt"
      margin-top="10pt"
      margin-right="10pt"
      margin-bottom="10pt"
      margin-left="10pt"
      wwpage:replace="{$VarFlow/@name}-odd-footer"
     >
      Page <fo:page-number/> - webworks.com
     </fo:block>
    </fo:static-content>

    <xsl:comment>Flow</xsl:comment>
    <fo:flow flow-name="{$VarFlow/@name}-body">
     <fo:block wwpage:replace="{$VarFlow/@name}">
      Page content...
     </fo:block>
    </fo:flow>
   </fo:page-sequence>
  </xsl:for-each>
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:preprocess">
  <xsl:param name="ParamFlows" />

  <xsl:copy />
 </xsl:template>


 <!-- wwmode:body-replace -->
 <!--                     -->

 <xsl:template match="*" mode="wwmode:body-replace">
  <xsl:param name="ParamBodyReplacement" />
  <xsl:param name="ParamSetInitialPageNumber" />

  <!-- Preserve element -->
  <!--                  -->
  <xsl:copy>
   <!-- Replace 'body' in attributes -->
   <!--                              -->
   <xsl:apply-templates select="@*" mode="wwmode:body-replace-attributes">
    <xsl:with-param name="ParamBodyReplacement" select="$ParamBodyReplacement" />
    <xsl:with-param name="ParamSetInitialPageNumber" select="$ParamSetInitialPageNumber" />
   </xsl:apply-templates>

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:body-replace">
    <xsl:with-param name="ParamBodyReplacement" select="$ParamBodyReplacement" />
    <xsl:with-param name="ParamSetInitialPageNumber" select="$ParamSetInitialPageNumber" />
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="fo:page-sequence" mode="wwmode:body-replace">
  <xsl:param name="ParamBodyReplacement" />
  <xsl:param name="ParamSetInitialPageNumber" />

  <!-- Preserve element -->
  <!--                  -->
  <xsl:copy>
   <!-- Replace 'body' in attributes -->
   <!--                              -->
   <xsl:apply-templates select="@*" mode="wwmode:body-replace-attributes">
    <xsl:with-param name="ParamBodyReplacement" select="$ParamBodyReplacement" />
    <xsl:with-param name="ParamSetInitialPageNumber" select="$ParamSetInitialPageNumber" />
   </xsl:apply-templates>

   <!-- Initial page number set? -->
   <!--                          -->
   <xsl:if test="$ParamSetInitialPageNumber">
    <xsl:if test="count(@*[name() = 'initial-page-number']) = 0">
     <xsl:attribute name="initial-page-number">1</xsl:attribute>
    </xsl:if>
   </xsl:if>

   <!-- Process children -->
   <!--                  -->
   <xsl:apply-templates mode="wwmode:body-replace">
    <xsl:with-param name="ParamBodyReplacement" select="$ParamBodyReplacement" />
    <xsl:with-param name="ParamSetInitialPageNumber" select="$ParamSetInitialPageNumber" />
   </xsl:apply-templates>
  </xsl:copy>
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:body-replace">
  <xsl:param name="ParamBodyReplacement" />
  <xsl:param name="ParamSetInitialPageNumber" />

  <xsl:copy />
 </xsl:template>


 <!-- wwmode:body-replace-attributes -->
 <!--                                -->

 <xsl:template match="*" mode="wwmode:body-replace-attributes">
  <xsl:param name="ParamBodyReplacement" />
  <xsl:param name="ParamSetInitialPageNumber" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>

 <xsl:template match="@*" mode="wwmode:body-replace-attributes">
  <xsl:param name="ParamBodyReplacement" />
  <xsl:param name="ParamSetInitialPageNumber" />

  <!-- Replace 'body' in attribute value -->
  <!--                                   -->
  <xsl:attribute name="{name(.)}">
   <xsl:variable name="VarValue" select="." />

   <xsl:choose>
    <xsl:when test="starts-with($VarValue, 'body')">
     <xsl:value-of select="$ParamBodyReplacement" />
     <xsl:value-of select="substring-after($VarValue, 'body')" />
    </xsl:when>

    <xsl:otherwise>
     <xsl:value-of select="$VarValue" />
    </xsl:otherwise>
   </xsl:choose>
  </xsl:attribute>
 </xsl:template>

 <xsl:template match="text() | comment() | processing-instruction()" mode="wwmode:body-replace-attributes">
  <xsl:param name="ParamBodyReplacement" />
  <xsl:param name="ParamSetInitialPageNumber" />

  <!-- Ignore -->
  <!--        -->
 </xsl:template>
</xsl:stylesheet>
