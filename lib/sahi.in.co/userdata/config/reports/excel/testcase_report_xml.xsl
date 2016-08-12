<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="in.co.sahi.util.XSLUtils"
	version="1.0">
	<xsl:output method="xml" indent="yes" />
	<xsl:param name="useDBURL" select="false" />

	<xsl:template match="/">
		<result>
				<xsl:apply-templates />
		</result>
	</xsl:template>

	<xsl:template match="suiteSummary">
		<xsl:param name="suiteId" select="suiteReportId|SUITEREPORTID" />
		<xsl:param name="suiteName" select="suiteName|SUITENAME" />
		<xsl:param name="suitePath" select="suitePath|SUITEPATH" />
		<xsl:param name="startTime" select="startTime|STARTTIME" />
		<xsl:param name="endTime" select="endTime|ENDTIME" />
		<xsl:param name="status" select="status|STATUS" />
		<xsl:param name="tcount" select="totalCount|TOTALCOUNT" />
		<xsl:param name="pcount" select="passedCount|PASSEDCOUNT" />
		<xsl:param name="fcount" select="failedCount|FAILEDCOUNT" />
		<xsl:param name="timeTaken" select="timeTaken|TIMETAKEN" />
		<xsl:param name="browser" select="browserType|BROWSERTYPE"></xsl:param>
		<xsl:param name="suiteInfo" select="SUITEINFO"></xsl:param>
		
		<table rowHeight="20">
			<row>
				<cell></cell>
				<cell fontWeight="bold" borderBottom="thin" fontSize="11">Suite Name</cell>
				<cell fontWeight="bold" borderBottom="thin" fontSize="11"><xsl:value-of select="$suiteName" /></cell>
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
				<cell borderLeft="thin" borderTop="thin" fontSize="11">Browser Type</cell>
				<cell borderTop="thin" fontSize="11"><xsl:value-of select="$browser" /></cell>
				<cell borderTop="thin" fontSize="11">Total scripts run</cell>
				<cell borderTop="thin" borderRight="thin" fontSize="11"><xsl:value-of select="$tcount" /></cell>
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
				<cell borderLeft="thin" fontSize="11">Start Time</cell>
				<cell fontSize="11"><xsl:value-of select="util:humanTime($startTime)" /></cell>
				<cell fontSize="11">Scripts passed</cell>
				<cell borderRight="thin" fontSize="11"><xsl:value-of select="$pcount" /></cell>
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
				<cell borderLeft="thin" fontSize="11">End Time</cell>
				<cell fontSize="11"><xsl:value-of select="util:humanTime($endTime)" /></cell>
				<cell fontSize="11">Scripts failed</cell>
				<cell borderRight="thin" fontSize="11"><xsl:value-of select="$fcount" /></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
			</row>
			<row>
				<xsl:variable name="cellcolor">
					<xsl:choose>
						<xsl:when test="$status = 'SUCCESS'">green</xsl:when>
      					<xsl:otherwise>red</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<cell></cell>
				<cell borderLeft="thin" borderBottom="normal" fontSize="11">Time Taken</cell>
				<cell borderBottom="normal" fontSize="11"><xsl:value-of select="util:prettyTime($timeTaken)" /></cell>
				<cell borderBottom="normal" fontSize="11">Status</cell>
				<cell color="{$cellcolor}" borderBottom="normal" borderRight="thin" fontSize="11"><xsl:value-of select="$status" /></cell>
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
		<xsl:choose>
			<xsl:when test="$suiteInfo !=''">
				<table>
					<row>
						<cell></cell>
						<cell fontWeight="bold" borderBottom="thin" fontSize="11">Suite Info</cell>
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
						<cell colspan="10" rowspan="31" fontSize="11" borderLeft="thin" borderTop="thin" borderBottom="thin" borderRight="thin" verticalAlignment="top"><xsl:value-of select="$suiteInfo" /></cell>
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
						<cell borderBottom="thin" borderLeft="thin"></cell>
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
			</xsl:when>
		</xsl:choose>
		<table>
			<row>
				<cell></cell>
				<cell fontWeight="bold" fontSize="11">Nodes Info</cell>
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
				<cell fontWeight="bold" borderLeft="thin" borderTop="thin" borderBottom="thin" fontSize="11">Host</cell>
				<cell fontWeight="bold" borderTop="thin" borderBottom="thin" fontSize="11">Port</cell>
				<cell fontWeight="bold" borderTop="thin" borderBottom="thin" borderRight="thin" fontSize="11">Tests executed</cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
				<cell></cell>
			</row>
			<xsl:for-each select="(nodes/node)|(NODES/NODE)">
				<row>
					<cell></cell>
					<cell borderLeft="thin" fontSize="11"><xsl:value-of select="host|HOST" /></cell>
					<cell fontSize="11"><xsl:value-of select="port|PORT" /></cell>
					<cell fontSize="11" borderRight="thin"><xsl:value-of select="scriptCount|SCRIPTCOUNT" /></cell>
					<cell></cell>
					<cell></cell>
					<cell></cell>
					<cell></cell>
					<cell></cell>
					<cell></cell>
					<cell></cell>
					<cell></cell>
				</row>
			</xsl:for-each>
				<row>
					<cell></cell>
					<cell borderTop="thin"></cell>
					<cell borderTop="thin"></cell>
					<cell borderTop="thin"></cell>
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
	</xsl:template>

	<xsl:template match="scriptSummaries">
	</xsl:template>

	<xsl:template match="testCaseSummaries">
		<table rowHeight="20">
				<row>
					<cell></cell>
					<cell fontWeight="bold" borderBottom="thin" borderLeft="thin" borderTop="thin" fontSize="11">Test Case Id</cell>
					<cell fontWeight="bold" borderBottom="thin" borderTop="thin" fontSize="11">Description</cell>
					<cell fontWeight="bold" borderBottom="thin" borderTop="thin" fontSize="11">Status</cell>
					<cell fontWeight="bold" borderBottom="thin" borderTop="thin" fontSize="11">Time Taken</cell>
					<cell fontWeight="bold" borderBottom="thin" borderTop="thin" borderRight="thin" fontSize="11">Script Name</cell>
					<cell></cell>
					<cell></cell>
					<cell></cell>
					<cell></cell>
					<cell></cell>
					<cell></cell>
				</row>
			<xsl:for-each select="testCaseSummary">
				<row>
					<xsl:variable name="cellcolor">
						<xsl:choose>
							<xsl:when test="STATUS = 'SUCCESS'">green</xsl:when>
	      					<xsl:otherwise>red</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<cell></cell>
					<cell color="{$cellcolor}" fontSize="11" borderLeft="thin"><xsl:value-of select="testCaseReportId|TESTCASEREPORTID" /></cell>
					<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="description|DESCRIPTION" /></cell>
					<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="status|STATUS" /></cell>
					<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="timeTaken|TIMETAKEN" /></cell>
					<cell color="{$cellcolor}" fontSize="11" borderRight="thin"><xsl:value-of select="scriptName|SCRIPTNAME" /></cell>
					<cell></cell>
					<cell></cell>
					<cell></cell>
					<cell></cell>
					<cell></cell>
					<cell></cell>
				</row>
			</xsl:for-each>
				<row>
					<cell></cell>
					<cell borderTop="thin"></cell>
					<cell borderTop="thin"></cell>
					<cell borderTop="thin"></cell>
					<cell borderTop="thin"></cell>
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
	</xsl:template>

</xsl:stylesheet>