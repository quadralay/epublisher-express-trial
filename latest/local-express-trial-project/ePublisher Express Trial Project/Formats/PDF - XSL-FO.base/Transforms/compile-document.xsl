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
 <xsl:param name="ParameterDocumentType" />
 <xsl:param name="ParameterType" />
 <xsl:param name="ParameterUse" />
 <xsl:param name="ParameterDeploy" />

 <xsl:output method="xml" encoding="UTF-8" indent="yes" />
 <xsl:namespace-alias stylesheet-prefix="html" result-prefix="#default" />
 <xsl:strip-space elements="*" />

 <xsl:include href="wwformat:Transforms/compile.xsl" />
 
 <xsl:key name="wwfiles-files-by-type" match="wwfiles:File" use="@type" />
 <xsl:key name="wwfiles-files-by-groupid-type" match="wwfiles:File" use="concat(@groupID, ':', @type)" />
 <xsl:key name="wwsplits-files-by-documentid" match="wwsplits:File" use="@documentID" />

 <xsl:variable name="GlobalActionChecksum">
  <xsl:variable name="VarTransformChecksums">
   <xsl:value-of select="concat(wwuri:AsFilePath('wwtransform:self'), ':', wwfilesystem:GetChecksum(wwuri:AsFilePath('wwtransform:self')))" />
  </xsl:variable>
  <xsl:value-of select="wwstring:MD5Checksum($VarTransformChecksums)" />
 </xsl:variable>


 <xsl:template match="/">
  <wwfiles:Files version="1.0">

   <xsl:if test="wwprojext:GetFormatSetting('generate-per-document-result') = 'true'">
    <!-- Groups -->
    <!--        -->
    <xsl:variable name="VarProjectGroups" select="$GlobalProject/wwproject:Project/wwproject:Groups/wwproject:Group" />
    <xsl:variable name="VarProgressProjectGroupsStart" select="wwprogress:Start(count($VarProjectGroups))" />
    <xsl:for-each select="$VarProjectGroups">
     <xsl:variable name="VarProjectGroup" select="." />

     <!-- ParameterSplitsType File -->
     <!--                          -->
     <xsl:variable name="VarSplitsTypeAsXML">
      <xsl:for-each select="$GlobalInput[1]">
       <xsl:copy-of select="key('wwfiles-files-by-type', $ParameterSplitsType)[@groupID = $VarProjectGroup/@GroupID][1]"/>
      </xsl:for-each>
     </xsl:variable>
     <xsl:variable name="VarSplitsType" select="msxsl:node-set($VarSplitsTypeAsXML)" />
     <xsl:variable name="VarSplitsTypeFile" select="$VarSplitsType/wwfiles:File[1]"/>

     <!-- Load Splits UniqueNames from ParameterSplitsType Path -->
     <!--                                                       -->
     <xsl:variable name="VarSplitsUniqueNames" select="wwexsldoc:LoadXMLWithoutResolver($VarSplitsTypeFile/@path)" />

     <!-- Documents -->
     <!--           -->
     <xsl:for-each select="$GlobalInput[1]">
      <xsl:variable name="VarDocuments" select="key('wwfiles-files-by-groupid-type', concat($VarProjectGroup/@GroupID, ':', $ParameterDocumentType))" />
      <xsl:variable name="VarProgressDocumentsStart" select="wwprogress:Start(count($VarDocuments))" />
      <xsl:for-each select="$VarDocuments">
       <xsl:variable name="VarDocument" select="."/>

       <xsl:variable name="VarProgressDocumentStart" select="wwprogress:Start(1)" />

       <!-- FO File -->
       <!--         -->
       <xsl:variable name="VarFOFilesAsXML">
        <xsl:variable name="VarStitchDocumentAsXML">
         <xsl:for-each select="$GlobalInput[1]">
          <xsl:copy-of select="key('wwfiles-files-by-type', $ParameterDependsType)[@documentID = $VarDocument/@documentID][1]"/>
         </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="VarStitchDocument" select="msxsl:node-set($VarStitchDocumentAsXML)"/>
        <xsl:copy-of select="$VarStitchDocument/wwfiles:File"/>
       </xsl:variable>
       <xsl:variable name="VarFOFiles" select="msxsl:node-set($VarFOFilesAsXML)" />
       <xsl:variable name="VarFOFile" select="$VarFOFiles/wwfiles:File[1]" />

       <!-- PDF File -->
       <!--          -->
       <xsl:variable name="VarSplitsAsXML">
        <xsl:for-each select="$VarSplitsUniqueNames[1]">
         <xsl:copy-of select="key('wwsplits-files-by-documentid', $VarDocument/@documentID)[@type = $ParameterSplitFileType][1]"/>
        </xsl:for-each>
       </xsl:variable>
       <xsl:variable name="VarSplits" select="msxsl:node-set($VarSplitsAsXML)"/>
       <xsl:variable name="VarPDFFile" select="$VarSplits/wwsplits:File[1]"/>

       <!-- Aborted? -->
       <!--          -->
       <xsl:if test="not(wwprogress:Abort())">
        <!-- Up-to-date? -->
        <!--             -->
        <xsl:variable name="VarUpToDate" select="wwfilesext:UpToDate($VarPDFFile/@path, $GlobalProject/wwproject:Project/@ChangeID, $VarDocument/@groupID, $VarDocument/@documentID, $GlobalActionChecksum)" />
        <xsl:if test="not($VarUpToDate)">
         <xsl:call-template name="Compile">
          <xsl:with-param name="ParamFOPath" select="$VarFOFile/@path" />
          <xsl:with-param name="ParamFopPDFPath" select="$VarPDFFile/@path" />
         </xsl:call-template>

         <wwfiles:File path="{$VarPDFFile/@path}" type="{$ParameterType}" checksum="{wwfilesystem:GetChecksum($VarPDFFile/@path)}" projectchecksum="{$GlobalProject/wwproject:Project/@ChangeID}" groupID="{$VarPDFFile/@groupID}" documentID="{$VarPDFFile/@documentID}" actionchecksum="{$GlobalActionChecksum}" category="{$VarFOFile/@category}" use="{$ParameterUse}" deploy="{$ParameterDeploy}">
          <wwfiles:Depends path="{$VarSplitsTypeFile/@path}" checksum="{$VarSplitsTypeFile/@checksum}" groupID="{$VarSplitsTypeFile/@groupID}" documentID="{$VarDocument/@documentID}" />
          <wwfiles:Depends path="{$VarFOFile/@path}" checksum="{$VarFOFile/@checksum}" groupID="{$VarFOFile/@groupID}" documentID="{$VarFOFile/@documentID}" />
         </wwfiles:File>
        </xsl:if>
       </xsl:if>

       <xsl:variable name="VarProgressDocumentEnd" select="wwprogress:End()" />

      </xsl:for-each>
     </xsl:for-each>
     <xsl:variable name="VarProgressDocumentsEnd" select="wwprogress:End()" />
     <!-- Documents End -->

    </xsl:for-each>
    <xsl:variable name="VarProgressProjectGroupsEnd" select="wwprogress:End()" />
    <!-- Groups End -->

   </xsl:if>

  </wwfiles:Files>
 </xsl:template>
</xsl:stylesheet>

