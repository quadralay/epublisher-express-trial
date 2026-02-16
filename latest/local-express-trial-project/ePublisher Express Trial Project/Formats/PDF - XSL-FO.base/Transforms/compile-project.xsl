<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
                              xmlns:html="http://www.w3.org/1999/xhtml"
                              xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:msxsl="urn:schemas-microsoft-com:xslt"
                              xmlns:wwmode="urn:WebWorks-Engine-Mode"
                              xmlns:wwfiles="urn:WebWorks-Engine-Files-Schema"
                              xmlns:wwdoc="urn:WebWorks-Document-Schema"
                              xmlns:wwsplits="urn:WebWorks-Engine-Splits-Schema"
                              xmlns:wwproject="urn:WebWorks-Publish-Project"
                              xmlns:wwprogress="urn:WebWorks-XSLT-Extension-Progress"
                              xmlns:wwlog="urn:WebWorks-XSLT-Extension-Log"
                              xmlns:wwfilesystem="urn:WebWorks-XSLT-Extension-FileSystem"
                              xmlns:wwuri="urn:WebWorks-XSLT-Extension-URI"
                              xmlns:wwstring="urn:WebWorks-XSLT-Extension-StringUtilities"
                              xmlns:wwunits="urn:WebWorks-XSLT-Extension-Units"
                              xmlns:wwfilesext="urn:WebWorks-XSLT-Extension-Files"
                              xmlns:wwprojext="urn:WebWorks-XSLT-Extension-Project"
                              xmlns:wwexsldoc="urn:WebWorks-XSLT-Extension-Document"
                              xmlns:wwexec="urn:WebWorks-XSLT-Extension-Execute"
                              xmlns:wwenv="urn:WebWorks-XSLT-Extension-Environment"
                              xmlns:wwstageinfo="urn:WebWorks-XSLT-Extension-StageInfo"
                              exclude-result-prefixes="xsl msxsl wwmode wwfiles wwdoc wwsplits wwproject wwprogress wwlog wwfilesystem wwuri wwstring wwunits wwfilesext wwprojext wwexsldoc wwexec wwenv"
>
 <xsl:param name="GlobalInput" />
 <xsl:param name="GlobalPipelineName" />
 <xsl:param name="GlobalProject" />
 <xsl:param name="GlobalFiles" />
 <xsl:param name="ParameterDependsType" />
 <xsl:param name="ParameterSplitsType" />
 <xsl:param name="ParameterSplitFileType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />

 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
 <xsl:strip-space elements="*" />

 <xsl:include href="wwtransform:common/files/utils.xsl" />
 <xsl:include href="wwformat:Transforms/compile.xsl" />

 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwproject-formatconfigurations-by-targetid" match="wwproject:FormatConfiguration" use="@TargetID" />

 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <!-- Process Project level PDF -->
   <!--                           -->
   <xsl:for-each select="$GlobalInput[1]">
    <xsl:variable name="VarProjectFOFile" select="key('wwfiles-files-by-type', $ParameterDependsType)[1]" />
    <xsl:for-each select="$VarProjectFOFile">
     <!-- Project FO path -->
     <!--                 -->
     <xsl:variable name="VarFOPath" select="$VarProjectFOFile/@path" />

     <!-- Project result path -->
     <!--                     -->
     <xsl:variable name="VarProjectTitle">
      <xsl:for-each select="$GlobalProject[1]">
       <xsl:variable name="VarFormatConfiguration" select="key('wwproject-formatconfigurations-by-targetid', wwprojext:GetFormatID())[1]" />
       <xsl:variable name="VarMergeSettings" select="$VarFormatConfiguration/wwproject:MergeSettings" />

       <xsl:choose>
        <xsl:when test="string-length($VarMergeSettings/@Title) &gt; 0">
         <xsl:value-of select="$VarMergeSettings/@Title" />
        </xsl:when>

        <xsl:otherwise>
         <xsl:value-of select="wwprojext:GetFormatName()" />
        </xsl:otherwise>
       </xsl:choose>
      </xsl:for-each>
     </xsl:variable>

     <xsl:variable name="VarReplacedProjectName">
      <xsl:call-template name="ReplaceGroupNameSpacesWith">
       <xsl:with-param name="ParamText" select="$VarProjectTitle" />
      </xsl:call-template>
     </xsl:variable>

     <xsl:variable name="VarFopPDFPath" select="wwfilesystem:Combine(wwprojext:GetTargetOutputDirectoryPath(), concat($VarReplacedProjectName, '.pdf'))" />

     <!-- Up-to-date? -->
     <!--             -->
     <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarFopPDFPath, $GlobalProject/wwproject:Project/@ChangeID, '', '', $GlobalActionChecksum)" />
     <xsl:if test="not($VarUpToDate)">
      <xsl:call-template name="Compile">
       <xsl:with-param name="ParamFOPath" select="$VarFOPath" />
       <xsl:with-param name="ParamFopPDFPath" select="$VarFopPDFPath" />
      </xsl:call-template>
     </xsl:if>

     <wwfiles:File path="{$VarFopPDFPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarFopPDFPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="" documentID="" actionchecksum="{$GlobalActionChecksum}" category="merge" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
      <wwfiles:Depends path="{$VarFOPath}" checksum="{wwfilesystem:GetChecksum($VarFOPath)}" groupID="" documentID="" />
     </wwfiles:File>
    </xsl:for-each>
   </xsl:for-each>
  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>

