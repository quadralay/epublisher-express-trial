<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwlinks="urn:WebWorks-Engine-Links-Schema"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
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
                              xmlns:wwdatetime="urn:WebWorks-XSLT-Extension-DateTimeUtilities"
                              xmlns:wwlandmarks="urn:WebWorks-XSLT-Extension-Landmarks"
                              exclude-result-prefixes="xsl msxsl wwmode wwlinks wwfiles wwdoc wwtoc wwbehaviors wwvars wwnotes wwproject wwpage wwlocale wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwimaging wwexsldoc wwdatetime wwlandmarks"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterSplitsType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterCategory" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />


 <xsl:variable name="GlobalDefaultNamespace" select="'http://www.w3.org/1999/xhtml'" />

 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-documentid" match="wwfiles:File" use="@documentID" />
 <xsl:key name="wwdoc-paragraphstyle-by-name" match="wwdoc:ParagraphStyle" use="@name" />

 <xsl:key name="landmarks-entry-by-file" match="wwlandmarks:Entry" use="substring-before(concat(@path,'#'), '#')"/>
 <xsl:key name="landmarks-entry-by-anchor" match="wwlandmarks:Entry" use="substring-after(@path,'#')"/>

 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
 <xsl:strip-space elements="*" />
 <xsl:preserve-space elements="html:script" />

 <xsl:include href="wwtransform:common/files/utils.xsl" />
 <xsl:include href="wwtransform:common/landmarks/landmarks-core.xsl" />

 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
   <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/files/utils.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/files/utils.xsl')))" />
	 <xsl:value-of select="concat(',', wwuri:AsFilePath('wwtransform:common/landmarks/landmarks-core.xsl'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:common/landmarks/landmarks-core.xsl')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>

 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:call-template name="LandmarksJSON">
    <xsl:with-param name="ParamInput" select="$GlobalInput" />
    <xsl:with-param name="ParamFiles" select="$GlobalFiles" />
    <xsl:with-param name="ParamDependsType" select="$ParameterDependsType" />
    <xsl:with-param name="ParamSplitsType" select="$ParameterSplitsType" />
   </xsl:call-template>

  </wwfiles:Files>
 </xsl:template>


 <!-- Template to determine if a paragraph should generate a landmark ID -->
 <!--                                                                    -->
 <xsl:template name="LandmarksJSON">
  <xsl:param name="ParamInput" />
  <xsl:param name="ParamFiles" />
  <xsl:param name="ParamDependsType" />
  <xsl:param name="ParamSplitsType" />

  <!-- Iterate through groups -->
  <!--                        -->
  <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
  <xsl:value-of select="wwprogress:Start(count($VarProjectGroups))" />

  <xsl:for-each select="$VarProjectGroups">
   <xsl:variable name="VarProjectGroup" select="." />
   <xsl:value-of select="wwprogress:Start(1)" />

   <!-- Determine group output directory path -->
   <!--                                       -->
   <xsl:variable name="VarReplacedGroupName">
    <xsl:call-template name="ReplaceGroupNameSpacesWith">
     <xsl:with-param name="ParamText" select="$VarProjectGroup/@Name" />
    </xsl:call-template>
   </xsl:variable>

   <!-- Landmarks file path -->
   <!--                     -->
   <xsl:variable name="VarLandmarksFilePath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), concat(wwstring:ReplaceWithExpression($VarReplacedGroupName, $GlobalInvalidPathCharactersExpression, '_'), '_lx.js'))" />

   <!-- Get all documents in this group -->
   <!--                                 -->
   <xsl:for-each select="$ParamFiles[1]">
    <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParamDependsType)[@groupID = $VarProjectGroup/@GroupID]" />

    <!-- Load splits for this group -->
    <!--                            -->
    <xsl:variable name="VarFilesSplits" select="key('wwfiles-files-by-type', $ParamSplitsType)[@groupID = $VarProjectGroup/@GroupID]" />
    <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesSplits/@path)" />

    <xsl:variable name="VarLandmarksEntriesAsXML">
     <xsl:call-template name="Landmarks-GenerateEntries">
      <xsl:with-param name="ParamProject" select="$GlobalProject" />
      <xsl:with-param name="ParamLandmarksFilePath" select="$VarLandmarksFilePath"/>
      <xsl:with-param name="ParamFilesByType" select="$VarFilesByType" />
      <xsl:with-param name="ParamSplits" select="$VarSplits"/>
     </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="VarLandmarksEntries" select="msxsl:node-set($VarLandmarksEntriesAsXML)/wwlandmarks:Entries"/>

    <xsl:variable name="VarLandmarksFilesAsXML">
     <wwlandmarks:Files>
      <xsl:for-each select="$VarLandmarksEntries/wwlandmarks:Entry[
                             generate-id() = generate-id(key('landmarks-entry-by-file', substring-before(concat(@path, '#'), '#'))[1])
                            ]">
       <xsl:sort select="substring-before(concat(@path, '#'), '#')"/>
       <wwlandmarks:File i="{position()-1}" k="{substring-before(concat(@path, '#'), '#')}"/>
      </xsl:for-each>
     </wwlandmarks:Files>
    </xsl:variable>
    <xsl:variable name="VarLandmarksFiles" select="msxsl:node-set($VarLandmarksFilesAsXML)/wwlandmarks:Files"/>

    <xsl:variable name="VarLandmarksAnchorsAsXML">
     <wwlandmarks:Anchors>
      <wwlandmarks:Anchor i="0" k=""/>
      <xsl:for-each select="$VarLandmarksEntries/wwlandmarks:Entry[
                             substring-after(@path, '#') != '' and generate-id() = generate-id(key('landmarks-entry-by-anchor', substring-after(@path, '#'))[1])
                            ]">
       <xsl:sort select="substring-after(@path, '#')"/>
       <wwlandmarks:Anchor i="{position()}" k="{substring-after(@path, '#')}"/>
      </xsl:for-each>
     </wwlandmarks:Anchors>
    </xsl:variable>
    <xsl:variable name="VarLandmarksAnchors" select="msxsl:node-set($VarLandmarksAnchorsAsXML)/wwlandmarks:Anchors"/>

    <xsl:variable name="VarLandmarksFileContent">
     <xsl:text>var landmarks = {</xsl:text>

     <!-- 'f' section, unique file paths -->
     <!--                                -->
     <xsl:text>&#10;</xsl:text>
     <xsl:text>  "f": [</xsl:text>
     <xsl:for-each select="$VarLandmarksFiles/wwlandmarks:File">
      <xsl:if test="position() &gt; 1">,<xsl:text/></xsl:if>
      <xsl:text>"</xsl:text><xsl:value-of select="@k"/><xsl:text>"</xsl:text>
     </xsl:for-each>
     <xsl:text>],</xsl:text>

     <!-- 'a' section, unique anchors -->
     <!--                             -->
     <xsl:text>&#10;</xsl:text>
     <xsl:text>  "a": [</xsl:text>
     <xsl:for-each select="$VarLandmarksAnchors/wwlandmarks:Anchor">
      <xsl:if test="position() &gt; 1">,<xsl:text/></xsl:if>
      <xsl:text>"</xsl:text><xsl:value-of select="@k"/><xsl:text>"</xsl:text>
     </xsl:for-each>
     <xsl:text>],</xsl:text>

     <!-- 'e' section, all entries; ties paths and anchors to landmarks -->
     <!--                                                               -->
     <xsl:text>&#10;</xsl:text>
     <xsl:text>  "e": [</xsl:text>
     <xsl:for-each select="$VarLandmarksEntries/wwlandmarks:Entry">
      <xsl:sort select="substring-before(concat(@path,'#'),'#')"/>
      <xsl:sort select="substring-after(@path,'#')"/>

      <xsl:variable name="VarPathBasePart" select="substring-before(concat(@path,'#'),'#')"/>
      <xsl:variable name="VarPathAnchorPart" select="substring-after(@path,'#')"/>

      <xsl:variable name="VarFile" select="$VarLandmarksFiles/wwlandmarks:File[@k=$VarPathBasePart]/@i"/>
      <xsl:variable name="VarAnchor" select="$VarLandmarksAnchors/wwlandmarks:Anchor[@k=$VarPathAnchorPart]/@i"/>

      <xsl:if test="position() &gt; 1">,<xsl:text/></xsl:if>
      <xsl:text>[</xsl:text>
      <xsl:value-of select="$VarFile"/>
      <xsl:text>,</xsl:text>
      <xsl:value-of select="$VarAnchor"/>
      <xsl:text>,"</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>"]</xsl:text>
     </xsl:for-each>
     <xsl:text>]&#10;};Landmarks.Advance(landmarks);&#10;</xsl:text>
    </xsl:variable>

    <!-- Write landmarks file -->
    <!--                      -->
    <xsl:variable name="VarWriteResult" select="wwexsldoc:Document($VarLandmarksFileContent, $VarLandmarksFilePath, 'utf-8', 'text')" />

    <!-- Report file -->
    <!--             -->
    <wwfiles:File path="{$VarLandmarksFilePath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarLandmarksFilePath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarProjectGroup/@GroupID}" documentID="" actionchecksum="{$GlobalActionChecksum}" category="{$ParameterCategory}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
     <xsl:for-each select="$VarFilesByType">
      <wwfiles:Depends path="{@path}" checksum="{@checksum}" groupID="{@groupID}" documentID="{@documentID}" />
     </xsl:for-each>
     <wwfiles:Depends path="{$VarFilesSplits/@path}" checksum="{$VarFilesSplits/@checksum}" groupID="{$VarFilesSplits/@groupID}" documentID="{$VarFilesSplits/@documentID}" />
    </wwfiles:File>
   </xsl:for-each>

   <xsl:value-of select="wwprogress:End()" />
  </xsl:for-each>

  <xsl:value-of select="wwprogress:End()" />
 </xsl:template>
</xsl:stylesheet>
