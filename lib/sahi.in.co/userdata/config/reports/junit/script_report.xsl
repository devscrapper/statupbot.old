<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	version="1.0">
	<xsl:output method="text" indent="no" />
	<xsl:param name="useDBURL" select="false" />
	<xsl:template match="/">
<xsl:text>&lt;?xml version="1.0" encoding="UTF-8"?&gt;</xsl:text>
		<xsl:apply-templates />
<xsl:text>
&lt;/testcase&gt;
&lt;/testsuite&gt;</xsl:text>
	</xsl:template>

	<xsl:template match="steps|STEPS">
		<xsl:for-each select="step">
			<xsl:param name="ix" select="position()" />
			<xsl:param name="className" select="MESSAGETYPE" />
			<xsl:param name="debugInfo" select="DEBUGINFO" />
			<xsl:param name="failureMsg" select="FAILUREMESSAGE" />
			<xsl:param name="result" select="MESSAGE" />
			<xsl:choose>
			
				<xsl:when test="$className=&quot;ERROR&quot;">
<xsl:text>
&lt;error message="Assertion Failed"&gt;</xsl:text>	
<xsl:text>&lt;![CDATA[</xsl:text>
<xsl:value-of select="$failureMsg" />
<xsl:text>]]&gt;</xsl:text>
<xsl:text>&lt;/error&gt;</xsl:text>	
				</xsl:when>
				
				<xsl:when test="$className=&quot;FAILURE&quot;">
<xsl:text>
&lt;failure message="Assertion Failed"&gt;</xsl:text>
<xsl:value-of select="$failureMsg" />
<xsl:text>&lt;/failure&gt;</xsl:text>
				</xsl:when>
				
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="testCaseSummaries"></xsl:template>
	<xsl:template match="summary">
		<xsl:param name="failures" select="number(failures|FAILURES)" />
		<xsl:param name="errors" select="number(errors|ERRORS)" />
		<xsl:param name="timeTaken" select="number(TIMETAKEN div 1000)" /> 
		<xsl:param name="scriptName" select="SCRIPTNAME" /> 
		<xsl:variable name="suiteName">
		  <xsl:choose>
		    <xsl:when test="SUITENAME='null'">default</xsl:when>
		    <xsl:when test="SUITENAME=''">default</xsl:when>
		    <xsl:otherwise><xsl:value-of select="SUITENAME" /></xsl:otherwise>
		  </xsl:choose>
		</xsl:variable>
		
		<xsl:text>
&lt;testsuite errors="</xsl:text>
		<xsl:value-of select="$errors" />
		<xsl:text>" failures="</xsl:text>
		<xsl:value-of select="$failures" />
		<xsl:text>" name="</xsl:text>
		<xsl:value-of select="$suiteName" />
		<xsl:text>.</xsl:text>
		<xsl:value-of select="substring-before($scriptName, '.sah')" />
		<xsl:text>" tests="</xsl:text>
		<xsl:text>1</xsl:text>
		<xsl:text>" time="</xsl:text>
		<xsl:value-of select="$timeTaken" />
		<xsl:text>"&gt;</xsl:text>
		
		<xsl:text>
&lt;testcase classname="</xsl:text>
		<xsl:value-of select="$suiteName" />
		<xsl:text>.</xsl:text>
		<xsl:value-of select="substring-before($scriptName, '.sah')" />
		<xsl:text>" name="</xsl:text>
		<xsl:value-of select="$scriptName" />
		<xsl:text>" time="</xsl:text>
		<xsl:value-of select="$timeTaken" />
		<xsl:text>"&gt;</xsl:text>	
		
	</xsl:template>
	<xsl:template match="suiteInfo"></xsl:template>
</xsl:stylesheet>