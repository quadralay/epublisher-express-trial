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
 <xsl:variable name="GlobalJavaMemoryOptions">
  <xsl:choose>
   <xsl:when test="wwenv:JavaBits() = '64'">
    <xsl:text>-Xms512M -Xmx4g</xsl:text>
   </xsl:when>

   <xsl:otherwise>
    <xsl:text>-Xms128M -Xmx1024M</xsl:text>
   </xsl:otherwise>
  </xsl:choose>
 </xsl:variable>

 <xsl:template name="Compile">
  <xsl:param name="ParamFOPath" />
  <xsl:param name="ParamFopPDFPath" />

  <!-- Locate tools -->
  <!--              -->
  <xsl:variable name="VarJavaHome" select="wwfilesystem:GetShortPathName(wwenv:JREHome())" />
  <xsl:variable name="VarFopHome" select="wwfilesystem:GetShortPathName(wwuri:AsFilePath('wwhelper:apache-fop-2.8'))" />
  <xsl:variable name="VarFopConfigurationPath" select="wwfilesystem:GetShortPathName(wwuri:AsFilePath('wwhelper:apache-fop-2.8.xconf'))" />

  <!-- Get short path name for FO file -->
  <!--                                 -->
  <xsl:variable name="VarFOPath" select="wwfilesystem:GetShortPathName($ParamFOPath)" />

  <!-- Get short path name for PDF -->
  <!--                             -->
  <xsl:variable name="VarMakeDirectory" select="wwfilesystem:CreateDirectory(wwfilesystem:GetDirectoryName($ParamFopPDFPath))" />
  <xsl:variable name="VarFopPDFPath" select="wwfilesystem:Combine(wwfilesystem:GetShortPathName(wwfilesystem:GetDirectoryName($ParamFopPDFPath)), wwfilesystem:GetFileName($ParamFopPDFPath))" />

  <xsl:variable name="VarBatchTextAsXML">
set JAVA_HOME=<xsl:value-of select="$VarJavaHome" />
set FOP_HOME=<xsl:value-of select="$VarFopHome" />

set JAVACMD=%JAVA_HOME%\bin\java.exe

set JAVAOPTS=-Denv.windir=%WINDIR% <xsl:value-of select="$GlobalJavaMemoryOptions" />

set LOGCHOICE=-Dorg.apache.commons.logging.Log=org.apache.commons.logging.impl.SimpleLog
set LOGLEVEL=-Dorg.apache.commons.logging.simplelog.defaultlog=INFO

set CLASSPATH=%FOP_HOME%\build\fop.jar
set CLASSPATH=%CLASSPATH%;%FOP_HOME%\lib\batik-all-1.16.jar
set CLASSPATH=%CLASSPATH%;%FOP_HOME%\lib\commons-io-2.11.0.jar
set CLASSPATH=%CLASSPATH%;%FOP_HOME%\lib\commons-logging-1.0.4.jar
set CLASSPATH=%CLASSPATH%;%FOP_HOME%\lib\fontbox-2.0.24.jar
set CLASSPATH=%CLASSPATH%;%FOP_HOME%\lib\serializer-2.7.2.jar
set CLASSPATH=%CLASSPATH%;%FOP_HOME%\lib\xml-apis-1.4.01.jar
set CLASSPATH=%CLASSPATH%;%FOP_HOME%\lib\xml-apis-ext-1.3.04.jar
set CLASSPATH=%CLASSPATH%;%FOP_HOME%\lib\xmlgraphics-commons-2.8.jar

&quot;%JAVACMD%&quot; %JAVAOPTS% %LOGCHOICE% %LOGLEVEL% org.apache.fop.cli.Main -c &quot;<xsl:value-of select="$VarFopConfigurationPath" />&quot; -fo &quot;<xsl:value-of select="$VarFOPath" />&quot; -pdf &quot;<xsl:value-of select="$VarFopPDFPath" />&quot;

exit errorlevel
  </xsl:variable>
  <xsl:variable name="VarBatchText" select="msxsl:node-set($VarBatchTextAsXML)" />

  <!-- Determine correct encoding to use -->
  <!--                                   -->
  <xsl:variable name="VarCurrentUILocale" select="substring(wwenv:CurrentUILocale(), 1, 2)" />
  <xsl:variable name="VarEncoding">
   <xsl:choose>
    <xsl:when test="$VarCurrentUILocale = 'ja'">
     <xsl:text>Shift_JIS</xsl:text>
    </xsl:when>

    <xsl:otherwise>
     <xsl:text>Windows-1252</xsl:text>
    </xsl:otherwise>
   </xsl:choose>
  </xsl:variable>

  <xsl:variable name="VarBatchPath" select="concat($ParamFOPath, '.bat')" />
  <xsl:variable name="VarWriteBatchFile" select="wwexsldoc:Document($VarBatchText, $VarBatchPath, $VarEncoding, 'text')" />

  <xsl:call-template name="Execute_Batch_File">
   <xsl:with-param name="ParamBatchFilePath" select="$VarBatchPath" />
  </xsl:call-template>

  <!-- Clean up batch file -->
  <!--                     -->
  <xsl:variable name="VarDeleteBatch" select="wwfilesystem:DeleteFile($VarBatchPath)" />
 </xsl:template>

 <xsl:template name="Execute_Batch_File">
  <xsl:param name="ParamBatchFilePath" />

  <!-- Aborted? -->
  <!--          -->
  <xsl:choose>
   <!-- Process -->
   <!--         -->
   <xsl:when test="not(wwprogress:Abort())">
    <!-- Execute -->
    <!--         -->
    <xsl:variable name="VarExecuteResult" select="wwexec:ExecuteCommand($ParamBatchFilePath)" />

    <!-- Determine effective return code -->
    <!--                                 -->
    <xsl:variable name="VarEffectiveReturnCode">
     <!-- Trust return code -->
     <!--                   -->
     <xsl:value-of select="$VarExecuteResult/wwexec:Result/@retcode" />
    </xsl:variable>

    <!-- Log result -->
    <!--            -->
    <xsl:if test="string-length($VarExecuteResult/wwexec:Result/wwexec:Stream[@name = 'Output']/text()) &gt; 0">
     <xsl:choose>
      <xsl:when test="number($VarEffectiveReturnCode) = 0">
       <!-- Check error output -->
       <!--                    -->
       <xsl:choose>
        <xsl:when test="string-length($VarExecuteResult/wwexec:Result/wwexec:Stream[@name = 'Error']/text()) &gt; 0">
         <!-- Part of an error? -->
         <!--                   -->
         <xsl:variable name="VarLogWarning" select="wwlog:Warning(wwstring:Replace($VarExecuteResult/wwexec:Result/wwexec:Stream[@name = 'Output']/text(), '&#13;&#10;&#13;&#10;', '&#13;&#10;'))" />
        </xsl:when>

        <xsl:otherwise>
         <!-- Report -->
         <!--        -->
         <xsl:variable name="VarLogMessage" select="wwlog:Message(wwstring:Replace($VarExecuteResult/wwexec:Result/wwexec:Stream[@name = 'Output']/text(), '&#13;&#10;&#13;&#10;', '&#13;&#10;'))" />
        </xsl:otherwise>
       </xsl:choose>
      </xsl:when>

      <xsl:otherwise>
       <xsl:variable name="VarLogWarning" select="wwlog:Warning(wwstring:Replace($VarExecuteResult/wwexec:Result/wwexec:Stream[@name = 'Output']/text(), '&#13;&#10;&#13;&#10;', '&#13;&#10;'))" />
      </xsl:otherwise>
     </xsl:choose>
    </xsl:if>
    <xsl:if test="string-length($VarExecuteResult/wwexec:Result/wwexec:Stream[@name = 'Error']/text()) &gt; 0">
     <xsl:variable name="VarLogError" select="wwlog:Warning(wwstring:Replace($VarExecuteResult/wwexec:Result/wwexec:Stream[@name = 'Error']/text(), '&#13;&#10;&#13;&#10;', '&#13;&#10;'))" />
    </xsl:if>

    <!-- Return retcode -->
    <!--                -->
    <xsl:value-of select="$VarEffectiveReturnCode" />
   </xsl:when>

   <!-- Abort -->
   <!--       -->
   <xsl:otherwise>
    <!-- Return retcode -->
    <!--                -->
    <xsl:value-of select="-1" />
   </xsl:otherwise>
  </xsl:choose>
 </xsl:template>
</xsl:stylesheet>

