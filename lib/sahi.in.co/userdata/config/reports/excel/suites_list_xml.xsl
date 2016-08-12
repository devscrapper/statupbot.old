<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="in.co.sahi.util.XSLUtils" 
version="1.0">
	<xsl:output method="xml" indent="yes" />
	<xsl:template match="/">
		<result>
			<xsl:apply-templates />
		</result>
	</xsl:template>
	<xsl:template match="suiteSummaries">
		<table>
			<row>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
			</row>
			<row>
				<cell></cell>
				<cell fontWeight="bold" borderBottom="thin" fontSize="11">SQL Query</cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
			</row>
			<row>
				<cell></cell>
				<cell colspan="10" rowspan="2" fontSize="11" borderLeft="thin" borderTop="thin" verticalAlignment="top"><xsl:value-of select="filter/sql" /></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin" borderRight="thin"></cell>
				<cell></cell>
			</row>
			<row>
				<cell></cell>
				<cell borderLeft="thin"></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell borderRight="thin"></cell>
				<cell></cell>
			</row>
			<row>
				<cell></cell>
				<cell borderLeft="thin" borderBottom="thin"></cell>
				<cell borderBottom="thin"></cell>
				<cell borderBottom="thin"></cell>
				<cell borderBottom="thin"></cell>
				<cell borderBottom="thin"></cell>
				<cell borderBottom="thin"></cell>
				<cell borderBottom="thin"></cell>
				<cell borderBottom="thin"></cell>
				<cell borderBottom="thin"></cell>
				<cell borderBottom="thin" borderRight="thin"></cell>
				<cell></cell>
			</row>
			<row>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
			</row>
			<row>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
			</row>
		</table>
		<table rowHeight="20">
			<row>
				<cell></cell>
				<cell fontWeight="bold" borderBottom="thin" fontSize="11">SUITE REPORTS</cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
			</row>
			<row>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
			</row>
			<row>
				<cell></cell>
				<cell fontWeight="bold" borderLeft="thin" borderTop="thin" borderBottom="thin" fontSize="11">Suite Name</cell>
				<cell fontWeight="bold" borderBottom="thin" borderTop="thin" fontSize="11">Base Url</cell>
				<cell fontWeight="bold" borderBottom="thin" borderTop="thin" fontSize="11">Browser</cell>
				<cell fontWeight="bold" borderBottom="thin" borderTop="thin" fontSize="11">Start Time</cell>
				<cell fontWeight="bold" borderBottom="thin" borderTop="thin" fontSize="11">End Time</cell>
				<cell fontWeight="bold" borderBottom="thin" borderTop="thin" fontSize="11">Time Taken</cell>
				<cell fontWeight="bold" borderBottom="thin" borderTop="thin" fontSize="11">Run</cell>
				<cell fontWeight="bold" borderBottom="thin" borderTop="thin" fontSize="11">Passed</cell>
				<cell fontWeight="bold" borderBottom="thin" borderTop="thin" fontSize="11">Failed</cell>
				<cell fontWeight="bold" borderRight="thin" borderTop="thin" borderBottom="thin" fontSize="11">Status</cell>
				<cell></cell>
			</row>
			<xsl:for-each select="suiteSummary">
				<row>
					<xsl:variable name="cellcolor">
						<xsl:choose>
							<xsl:when test="STATUS = 'SUCCESS'">green</xsl:when>
	      					<xsl:otherwise>red</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<cell></cell>
					<cell borderLeft="thin" color="{$cellcolor}" fontSize="11"><xsl:value-of select="SUITENAME" /></cell>
					<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="util:fetchInfo(SUITEINFO, 'baseURL')" /></cell>
					<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="BROWSERTYPE" /></cell>
					<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="util:humanTime(STARTTIME)" /></cell>
					<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="util:humanTime(ENDTIME)" /></cell>
					<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="util:prettyTimeMoreThan24Hours(TIMETAKEN)" /></cell>
					<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="TOTALCOUNT" /></cell>
					<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="PASSEDCOUNT" /></cell>
					<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="FAILEDCOUNT" /></cell>
					<cell borderRight="thin" color="{$cellcolor}" fontSize="11"><xsl:value-of select="STATUS" /></cell>
					<cell></cell>
				</row>
			</xsl:for-each>
			<row>
				<cell></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell borderTop="thin"></cell>
				<cell></cell>
			</row>
			<row>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
			</row>
		</table>
	</xsl:template>
</xsl:stylesheet>