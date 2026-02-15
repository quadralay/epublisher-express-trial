<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwlocale="urn:WebWorks-Locale-Schema"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwdatetime="urn:WebWorks-XSLT-Extension-DateTimeUtilities"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              exclude-result-prefixes="xsl msxsl wwlinks wwfiles wwfilesystem wwuri wwstring wwprojext wwlog wwlocale wwexsldoc wwdatetime wwproject"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterEntryType" />
 <xsl:param name="ParameterUILocaleType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:strip-space elements="*" />

 <xsl:include href="wwtransform:common/files/utils.xsl" />

 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwlinks-files-by-groupid" match="wwlinks:File" use="@groupID" />


 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>

 <!-- UI Locale -->
 <!--           -->
 <xsl:variable name="GlobalUILocalePath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterUILocaleType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalUILocale" select="wwexsldoc:LoadXMLWithoutResolver($GlobalUILocalePath)" />


 <!-- Links -->
 <!--       -->
 <xsl:variable name="GlobalLinksPath">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterDependsType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>
 <xsl:variable name="GlobalLinks" select="wwexsldoc:LoadXMLWithoutResolver($GlobalLinksPath)" />


 <!-- Connect Entry Page -->
 <!--                    -->
 <xsl:variable name="GlobalEntryPage">
  <xsl:for-each select="$GlobalFiles[1]">
   <xsl:value-of select="key('wwfiles-files-by-type', $ParameterEntryType)[1]/@path" />
  </xsl:for-each>
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:variable name="VarIsGenerateEnabled" select="wwprojext:GetFormatSetting('sitemap-generate', 'true') = 'true'" />

   <xsl:if test="$VarIsGenerateEnabled">
    <xsl:variable name="VarOutputDirectoryPath" select="wwprojext:GetTargetOutputDirectoryPath()" />
    <xsl:variable name="VarSitemapIndexPath" select="wwfilesystem:Combine($VarOutputDirectoryPath, 'sitemap.xml')" />
    <xsl:variable name="VarBaseURL" select="wwprojext:GetFormatSetting('sitemap-base-url', '')" />
    <xsl:variable name="VarOutputUri" select="wwuri:AsURI(wwfilesystem:Combine($VarOutputDirectoryPath, 'dummy.component'))" />

    <xsl:if test="normalize-space($VarBaseURL) = ''">
     <xsl:variable name="VarWarningNoBaseURLDescription" select="$GlobalUILocale/wwlocale:Locale/wwlocale:Strings/wwlocale:String[@name = 'LogNoBaseURLForSiteMap']/@value"/>
     <xsl:variable name="LogNoBaseURL" select="wwlog:Warning($VarWarningNoBaseURLDescription)"/>
    </xsl:if>

    <!-- Last modified date -->
    <!--                   -->
    <xsl:variable name="VarLastModDate" select="wwdatetime:GetGenerateStart('yyyy-MM-dd')" />

    <!-- Get unique group IDs -->
    <!--                      -->
    <xsl:variable name="VarUniqueGroupsAsXML">
     <xsl:for-each select="$GlobalLinks/wwlinks:Links/wwlinks:File[generate-id(.) = generate-id(key('wwlinks-files-by-groupid', @groupID)[1])]">
      <group id="{@groupID}" />
     </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="VarUniqueGroups" select="msxsl:node-set($VarUniqueGroupsAsXML)" />

    <!-- Generate group sitemaps in group folders -->
    <!--                                          -->
    <xsl:for-each select="$VarUniqueGroups/group">
     <xsl:variable name="VarGroupID" select="@id" />
     <xsl:variable name="VarGroupFiles" select="$GlobalLinks/wwlinks:Links/wwlinks:File[@groupID = $VarGroupID]" />

     <!-- Get the directory of the first file in the group -->
     <!--                                                   -->
     <xsl:variable name="VarFirstFilePath" select="$VarGroupFiles[1]/@path" />
     <xsl:variable name="VarGroupDirectory" select="wwfilesystem:GetDirectoryName($VarFirstFilePath)" />
     <xsl:variable name="VarGroupSitemapPath" select="wwfilesystem:Combine($VarGroupDirectory, 'sitemap-pages.xml')" />

     <xsl:variable name="VarGroupSitemapAsXML">
      <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
       <xsl:for-each select="$VarGroupFiles">
        <xsl:variable name="VarFile" select="." />
        <xsl:variable name="VarFileUri" select="wwuri:AsURI($VarFile/@path)" />
        <xsl:variable name="VarRelPath" select="wwuri:GetRelativeTo($VarFileUri, $VarOutputUri)" />

        <xsl:if test="string-length($VarBaseURL) &gt; 0">
         <xsl:variable name="VarPageURL">
          <xsl:choose>
           <xsl:when test="substring($VarBaseURL, string-length($VarBaseURL)) = '/'">
            <xsl:value-of select="concat($VarBaseURL, $VarRelPath)" />
           </xsl:when>
           <xsl:otherwise>
            <xsl:value-of select="concat($VarBaseURL, '/', $VarRelPath)" />
           </xsl:otherwise>
          </xsl:choose>
         </xsl:variable>
         <url>
          <loc><xsl:value-of select="translate($VarPageURL, '\', '/')" /></loc>
          <lastmod><xsl:value-of select="$VarLastModDate" /></lastmod>
          <changefreq>monthly</changefreq>
          <priority>0.8</priority>
         </url>
        </xsl:if>
       </xsl:for-each>
      </urlset>
     </xsl:variable>
     <xsl:variable name="VarWriteGroupSitemap" select="wwexsldoc:Document($VarGroupSitemapAsXML, $VarGroupSitemapPath, 'utf-8', 'xml', '1.0', 'yes')" />

     <!-- Report group sitemap file -->
     <!--                           -->
     <wwfiles:File path="{$VarGroupSitemapPath}" displayname="" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarGroupSitemapPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarGroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}" category="navigation" use="{$ParameterUse}" deploy="{$ParameterDeploy}" />
    </xsl:for-each>

    <!-- Generate root sitemap-pages.xml for entry page -->
    <!--                                                 -->
    <xsl:variable name="VarRootSitemapPagesPath" select="wwfilesystem:Combine($VarOutputDirectoryPath, 'sitemap-pages.xml')" />

    <xsl:variable name="VarRootSitemapPagesAsXML">
     <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      <xsl:if test="string-length($GlobalEntryPage) &gt; 0 and string-length($VarBaseURL) &gt; 0">
       <xsl:variable name="VarEntryRelPath" select="wwfilesystem:GetRelativeTo($GlobalEntryPage, $VarRootSitemapPagesPath)" />
       <xsl:variable name="VarEntryURL">
        <xsl:choose>
         <xsl:when test="substring($VarBaseURL, string-length($VarBaseURL)) = '/'">
          <xsl:value-of select="concat($VarBaseURL, translate($VarEntryRelPath, '\', '/'))" />
         </xsl:when>
         <xsl:otherwise>
          <xsl:value-of select="concat($VarBaseURL, '/', translate($VarEntryRelPath, '\', '/'))" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:variable>
       <url>
        <loc><xsl:value-of select="$VarEntryURL" /></loc>
        <lastmod><xsl:value-of select="$VarLastModDate" /></lastmod>
        <changefreq>weekly</changefreq>
        <priority>1.0</priority>
       </url>
      </xsl:if>
     </urlset>
    </xsl:variable>
    <xsl:variable name="VarWriteRootSitemapPages" select="wwexsldoc:Document($VarRootSitemapPagesAsXML, $VarRootSitemapPagesPath, 'utf-8', 'xml', '1.0', 'yes')" />

    <!-- Report root sitemap-pages.xml file -->
    <!--                                    -->
    <wwfiles:File path="{$VarRootSitemapPagesPath}" displayname="" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarRootSitemapPagesPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}" category="merge" use="{$ParameterUse}" deploy="{$ParameterDeploy}" />

    <!-- Generate sitemap index -->
    <!--                        -->
    <xsl:variable name="VarSitemapIndexAsXML">
     <sitemapindex xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">

      <!-- Include root sitemap-pages.xml (for entry page) -->
      <!--                                                  -->
      <xsl:if test="string-length($GlobalEntryPage) &gt; 0 and string-length($VarBaseURL) &gt; 0">
       <xsl:variable name="VarRootSitemapRelPath" select="wwfilesystem:GetRelativeTo($VarRootSitemapPagesPath, $VarSitemapIndexPath)" />
       <xsl:variable name="VarRootSitemapRelPathEncoded" select="wwstring:EncodeURI(translate($VarRootSitemapRelPath, '\', '/'))" />
       <xsl:variable name="VarRootSitemapURL">
        <xsl:choose>
         <xsl:when test="substring($VarBaseURL, string-length($VarBaseURL)) = '/'">
          <xsl:value-of select="concat($VarBaseURL, $VarRootSitemapRelPathEncoded)" />
         </xsl:when>
         <xsl:otherwise>
          <xsl:value-of select="concat($VarBaseURL, '/', $VarRootSitemapRelPathEncoded)" />
         </xsl:otherwise>
        </xsl:choose>
       </xsl:variable>
       <sitemap>
        <loc><xsl:value-of select="$VarRootSitemapURL" /></loc>
        <lastmod><xsl:value-of select="$VarLastModDate" /></lastmod>
       </sitemap>
      </xsl:if>

      <!-- Reference all group sitemap-pages.xml files -->
      <!--                                             -->
      <xsl:for-each select="$VarUniqueGroups/group">
       <xsl:variable name="VarGroupID" select="@id" />
       <xsl:variable name="VarGroupFiles" select="$GlobalLinks/wwlinks:Links/wwlinks:File[@groupID = $VarGroupID]" />
       <xsl:variable name="VarFirstFilePath" select="$VarGroupFiles[1]/@path" />
       <xsl:variable name="VarGroupDirectory" select="wwfilesystem:GetDirectoryName($VarFirstFilePath)" />
       <xsl:variable name="VarGroupSitemapPath" select="wwfilesystem:Combine($VarGroupDirectory, 'sitemap-pages.xml')" />
       <xsl:variable name="VarGroupSitemapRelPath" select="wwfilesystem:GetRelativeTo($VarGroupSitemapPath, $VarSitemapIndexPath)" />
       <xsl:variable name="VarGroupSitemapRelPathEncoded" select="wwstring:EncodeURI(translate($VarGroupSitemapRelPath, '\', '/'))" />

       <xsl:if test="string-length($VarBaseURL) &gt; 0">
        <xsl:variable name="VarGroupSitemapURL">
         <xsl:choose>
          <xsl:when test="substring($VarBaseURL, string-length($VarBaseURL)) = '/'">
           <xsl:value-of select="concat($VarBaseURL, $VarGroupSitemapRelPathEncoded)" />
          </xsl:when>
          <xsl:otherwise>
           <xsl:value-of select="concat($VarBaseURL, '/', $VarGroupSitemapRelPathEncoded)" />
          </xsl:otherwise>
         </xsl:choose>
        </xsl:variable>
        <sitemap>
         <loc><xsl:value-of select="$VarGroupSitemapURL" /></loc>
         <lastmod><xsl:value-of select="$VarLastModDate" /></lastmod>
        </sitemap>
       </xsl:if>
      </xsl:for-each>
     </sitemapindex>
    </xsl:variable>
    <xsl:variable name="VarWriteSitemapIndex" select="wwexsldoc:Document($VarSitemapIndexAsXML, $VarSitemapIndexPath, 'utf-8', 'xml', '1.0', 'yes')" />

    <!-- Report sitemap index file -->
    <!--                           -->
    <wwfiles:File path="{$VarSitemapIndexPath}" displayname="" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarSitemapIndexPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}" category="merge" use="{$ParameterUse}" deploy="{$ParameterDeploy}" />

   </xsl:if>
  </wwfiles:Files>
 </xsl:template>

</xsl:stylesheet>
