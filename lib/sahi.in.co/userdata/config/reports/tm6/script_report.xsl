<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:util="in.co.sahi.util.XSLUtils"
	version="1.0">
	<xsl:output method="text" indent="no" />
	<xsl:param name="useDBURL" select="false" />
	<xsl:template match="/">
<xsl:text>&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;report&gt;</xsl:text>
		<xsl:apply-templates />
<xsl:text>
&lt;/report&gt;</xsl:text>
	</xsl:template>

	<xsl:template match="steps|STEPS">
		<xsl:for-each select="step">
			<xsl:param name="ix" select="position()" />
			<xsl:param name="className" select="MESSAGETYPE" />
			<xsl:param name="debugInfo" select="DEBUGINFO" />
			<xsl:param name="failureMsg" select="FAILUREMESSAGE" />
			<xsl:param name="result" select="util:escapeForXML(MESSAGE)" />
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
				<xsl:otherwise>
<xsl:text>
&lt;step name="</xsl:text>
<xsl:value-of select="$result" />
<xsl:text>" dur="</xsl:text>
<xsl:choose>
	<xsl:when test="$ix=1">
		<xsl:variable name="time" select="time|MESSAGETIMESTAMP" />
		<xsl:variable name="fixedTime" select="util:fixMillis($time)" />
		<xsl:variable name="prevTime" select="/result/suiteInfo/STARTTIME" />
		<xsl:variable name="fixedPrevTime" select="util:fixMillis($prevTime)" />
		<xsl:variable name="difference" select="util:timeDifference($fixedTime,$fixedPrevTime)" />
		<xsl:value-of select="$difference" />
	</xsl:when>
	<xsl:otherwise>
		<xsl:variable name="time" select="time|MESSAGETIMESTAMP" />
		<xsl:variable name="fixedTime" select="util:fixMillis($time)" />
		<xsl:variable name="prevTime" select="/result/steps/step[$ix - 1]/MESSAGETIMESTAMP" />
		<xsl:variable name="fixedPrevTime" select="util:fixMillis($prevTime)" />
		<xsl:variable name="difference" select="util:timeDifference($fixedTime,$fixedPrevTime)" />
		<xsl:value-of select="$difference" />
	</xsl:otherwise>
</xsl:choose>
<xsl:text>" /&gt;</xsl:text>
			
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="testCaseSummaries"></xsl:template>
	<xsl:template match="summary"></xsl:template>
</xsl:stylesheet>