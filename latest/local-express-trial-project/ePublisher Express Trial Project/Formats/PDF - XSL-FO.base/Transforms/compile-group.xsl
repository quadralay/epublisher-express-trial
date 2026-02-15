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

 <xsl:include href="wwformat:Transforms/compile.xsl" />

 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwsplits-files-by-type" match="wwsplits:File" use="@type" />

 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">


   <!-- Groups -->
   <!--        -->
    <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
    <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
    <xsl:for-each select="$VarProjectGroups">
     <xsl:variable name="VarProjectGroup" select="." />
     <xsl:variable name="VarProgressProjectGroupStart" select="wwprogress:Start(1)" />

     <!-- Aborted? -->
     <!--          -->
     <xsl:if test="not(wwprogress:Abort())">

      <!-- Access splits -->
      <!--               -->
      <xsl:for-each select="$GlobalInput[1]">
       <xsl:variable name="VarFilesNameInfo" select="key('wwfiles-files-by-type', $ParameterSplitsType)[@groupID = $VarProjectGroup/@GroupID]" />
       <xsl:for-each select="$VarFilesNameInfo[1]">
        <xsl:variable name="VarSplitsFileInfo" select="." />

        <!-- Load splits -->
        <!--             -->
        <xsl:variable name="VarSplits" select="wwexsldoc:LoadXMLWithoutResolver($VarSplitsFileInfo/@path)" />

        <!-- Iterate input documents -->
        <!--                         -->
        <xsl:for-each select="$GlobalInput[1]">
         <xsl:variable name="VarFilesByType" select="key('wwfiles-files-by-type', $ParameterDependsType)[@groupID = $VarProjectGroup/@GroupID]" />

         <xsl:variable name="VarProgressDocumentsStart" select="wwprogress:Start(count($VarFilesByType))" />

         <xsl:for-each select="$VarFilesByType">
          <xsl:variable name="VarFilesDocumentNode" select="." />

          <xsl:variable name="VarProgressDocumentStart" select="wwprogress:Start(1)" />

          <!-- Aborted? -->
          <!--          -->
          <xsl:if test="not(wwprogress:Abort())">
           <!-- Output Path -->
           <!--             -->
           <xsl:variable name="VarPath">
            <xsl:for-each select="$VarSplits[1]">
             <xsl:value-of select="key('wwsplits-files-by-type', $ParameterSplitFileType)[1]/@path" />
            </xsl:for-each>
           </xsl:variable>

           <!-- Up-to-date? -->
           <!--             -->
           <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPath, $GlobalProject/wwproject:Project/@ChangeID, $VarFilesDocumentNode/@groupID, $VarFilesDocumentNode/@documentID, $GlobalActionChecksum)" />
           <xsl:if test="not($VarUpToDate)">
            <!-- Load document -->
            <!--               -->
            <xsl:variable name="VarDocument" select="wwexsldoc:LoadXMLWithoutResolver($VarFilesDocumentNode/@path)" />

            <xsl:call-template name="Compile">
             <xsl:with-param name="ParamFOPath" select="$VarFilesDocumentNode/@path" />
             <xsl:with-param name="ParamFopPDFPath" select="$VarPath" />
            </xsl:call-template>
           </xsl:if>

           <!-- Aborted? -->
           <!--          -->
           <xsl:if test="not(wwprogress:Abort())">
            <wwfiles:File path="{$VarPath}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPath)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarFilesDocumentNode/@groupID}" documentID="{$VarFilesDocumentNode/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$VarFilesDocumentNode/@category}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
             <wwfiles:Depends path="{$VarSplitsFileInfo/@path}" checksum="{$VarSplitsFileInfo/@checksum}" groupID="{$VarSplitsFileInfo/@groupID}" documentID="{$VarSplitsFileInfo/@documentID}" />
             <wwfiles:Depends path="{$VarFilesDocumentNode/@path}" checksum="{$VarFilesDocumentNode/@checksum}" groupID="{$VarFilesDocumentNode/@groupID}" documentID="{$VarFilesDocumentNode/@documentID}" />
            </wwfiles:File>
           </xsl:if>
          </xsl:if>

          <xsl:variable name="VarProgressDocumentEnd" select="wwprogress:End()" />
         </xsl:for-each>

         <xsl:variable name="VarProgressDocumentsEnd" select="wwprogress:End()" />
        </xsl:for-each>
       </xsl:for-each>
      </xsl:for-each>
     </xsl:if>

     <xsl:variable name="VarProgressProjectGroupEnd" select="wwprogress:End()" />
    </xsl:for-each>

    <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />

  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>

