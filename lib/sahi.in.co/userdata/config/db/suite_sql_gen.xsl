<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="in.co.sahi.datastore.SQLUtils" exclude-result-prefixes="util" version="1.0">
	<xsl:output method="text" indent="no" omit-xml-declaration="yes" />
	<xsl:param name="suiteId"/>
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	<xsl:template match="suiteSummary">
<xsl:variable name="suiteName" select="suiteName"/>
<xsl:variable name="escaped_suiteName" select="util:sqlString($suiteName)"/>
<xsl:variable name="suiteId" select="suiteId"/>
<xsl:variable name="escaped_suiteReportId" select="util:sqlString($suiteId)"/>
<xsl:variable name="suitePath" select="suitePath"/>
<xsl:variable name="escaped_suitePath" select="util:sqlString($suitePath)"/>
<xsl:variable name="browserType" select="browserType"/>
<xsl:variable name="escaped_browserType" select="util:sqlString($browserType)"/>
<xsl:variable name="startTime" select="startTime"/>
<xsl:variable name="escaped_startTime" select="util:sqlTime($startTime)"/>
<xsl:variable name="endTime" select="endTime"/>
<xsl:variable name="escaped_endTime" select="util:sqlTime($endTime)"/>
<xsl:variable name="timeTaken" select="timeTaken"/>
<xsl:variable name="escaped_timeTaken" select="util:sqlNumber($timeTaken)"/>
<xsl:variable name="totalCount" select="totalCount"/>
<xsl:variable name="escaped_totalCount" select="util:sqlNumber($totalCount)"/>
<xsl:variable name="passedCount" select="passedCount"/>
<xsl:variable name="escaped_passedCount" select="util:sqlNumber($passedCount)"/>
<xsl:variable name="failedCount" select="failedCount"/>
<xsl:variable name="escaped_failedCount" select="util:sqlNumber($failedCount)"/>

<xsl:variable name="tcCount" select="tcCount"/>
<xsl:variable name="escaped_tcCount" select="util:sqlNumber($tcCount)"/>
<xsl:variable name="tcPassed" select="tcPassed"/>
<xsl:variable name="escaped_tcPassed" select="util:sqlNumber($tcPassed)"/>
<xsl:variable name="tcFailed" select="tcFailed"/>
<xsl:variable name="escaped_tcFailed" select="util:sqlNumber($tcFailed)"/>


<xsl:variable name="status" select="status"/>
<xsl:variable name="escaped_status" select="util:sqlString($status)"/>
<xsl:variable name="suiteInfo" select="suiteInfo"/>
<xsl:variable name="escaped_suiteInfo" select="util:sqlString($suiteInfo)"/>
<xsl:variable name="userDefinedId" select="userDefinedId"/>
<xsl:variable name="escaped_userDefinedId" select="util:sqlString($userDefinedId)"/>
delete from SUITEREPORTS where SUITEREPORTID=<xsl:value-of select="$escaped_suiteReportId" />;
delete from NODEREPORTS where SUITEREPORTID=<xsl:value-of select="$escaped_suiteReportId" />;
insert into SUITEREPORTS (SUITENAME, SUITEREPORTID, SUITEPATH, BROWSERTYPE, STARTTIME, ENDTIME, TIMETAKEN, TOTALCOUNT, PASSEDCOUNT, FAILEDCOUNT, TCCOUNT, TCPASSED, TCFAILED, STATUS, SUITEINFO, USERDEFINEDID) values (<xsl:value-of select="$escaped_suiteName" />,  <xsl:value-of select="$escaped_suiteReportId" />,  <xsl:value-of select="$escaped_suitePath" />,  <xsl:value-of select="$escaped_browserType" />,  <xsl:value-of select="$escaped_startTime" />,  <xsl:value-of select="$escaped_endTime" />,  <xsl:value-of select="$escaped_timeTaken" />,  <xsl:value-of select="$escaped_totalCount" />,  <xsl:value-of select="$escaped_passedCount" />,  <xsl:value-of select="$escaped_failedCount" />, <xsl:value-of select="$escaped_tcCount" />, <xsl:value-of select="$escaped_tcPassed" />, <xsl:value-of select="$escaped_tcFailed" />, <xsl:value-of select="$escaped_status" />, <xsl:value-of select="$escaped_suiteInfo" />, <xsl:value-of select="$escaped_userDefinedId" />);

		<xsl:for-each select="nodes/node">
			<xsl:variable name="host" select="host" />
			<xsl:variable name="escaped_host" select="util:sqlString($host)" />
			<xsl:variable name="port" select="port" />
			<xsl:variable name="escaped_port" select="util:sqlString($port)" />
			<xsl:variable name="scriptCount" select="scriptCount" />
			<xsl:variable name="escaped_scriptCount" select="util:sqlString($scriptCount)" />
insert into NODEREPORTS (SUITEREPORTID, HOST, PORT, SCRIPTCOUNT) values (<xsl:value-of select="$escaped_suiteReportId" />, <xsl:value-of select="$escaped_host" />, <xsl:value-of select="$escaped_port" />, <xsl:value-of select="$escaped_scriptCount" />);
		</xsl:for-each>

	</xsl:template>

	<xsl:template match="scriptSummaries"></xsl:template>
	
	<xsl:template match="testCaseSummaries"></xsl:template>
	
</xsl:stylesheet>