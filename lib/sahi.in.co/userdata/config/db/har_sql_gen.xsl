<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="in.co.sahi.datastore.SQLUtils" exclude-result-prefixes="util" version="1.0">
	<xsl:output method="text" indent="no" omit-xml-declaration="yes" />
	<!-- 
	<xsl:param name="suiteId"/>
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	-->
	<xsl:template match="pageEntry">
		<xsl:variable name="id" select="id"/>
		<xsl:variable name="escaped_id" select="util:sqlString($id)"/>
		<xsl:variable name="pageData" select="pageData"/>
		<xsl:variable name="escaped_pageData" select="util:sqlString($pageData)"/>
		<xsl:variable name="requestStartTime" select="requestStartTime"/>
		<xsl:variable name="escaped_requestStartTime" select="util:sqlString($requestStartTime)"/>
		<!--  
		delete from SUITEREPORTS where SUITEREPORTID=<xsl:value-of select="$escaped_suiteReportId" />;
		delete from NODEREPORTS where SUITEREPORTID=<xsl:value-of select="$escaped_suiteReportId" />;
		-->
		insert into HARPAGES (ID, PAGEDATA, REQUESTSTARTTIME) values (<xsl:value-of select="$escaped_id" />,  <xsl:value-of select="$escaped_pageData" />,  <xsl:value-of select="$escaped_requestStartTime" />);
	</xsl:template>
	<xsl:template match="requestResponseEntry">
		<xsl:variable name="id" select="id"/>
		<xsl:variable name="scriptReportId" select="scriptReportId"/>
		<xsl:variable name="url" select="url"/>
		<xsl:variable name="escaped_id" select="util:sqlString($id)"/>
		<xsl:variable name="escaped_scriptReportId" select="util:sqlString($scriptReportId)"/>
		<xsl:variable name="escaped_url" select="util:sqlString($url)"/>
		<xsl:variable name="requestResponseData" select="requestResponseData"/>
		<xsl:variable name="escaped_requestResponseData" select="util:sqlString($requestResponseData)"/>
		<xsl:variable name="sendTime" select="sendTime"/>
		<xsl:variable name="escaped_sendTime" select="util:sqlString($sendTime)"/>
		<xsl:variable name="waitTime" select="waitTime"/>
		<xsl:variable name="escaped_waitTime" select="util:sqlString($waitTime)"/>
		<xsl:variable name="receiveTime" select="receiveTime"/>
		<xsl:variable name="escaped_receiveTime" select="util:sqlString($receiveTime)"/>
		<!--  
		delete from SUITEREPORTS where SUITEREPORTID=<xsl:value-of select="$escaped_suiteReportId" />;
		delete from NODEREPORTS where SUITEREPORTID=<xsl:value-of select="$escaped_suiteReportId" />;
		-->
		insert into HARREQUESTRESPONSE (ID, REQUESTRESPONSEDATA, SENDTIME, WAITTIME, RECEIVETIME, SCRIPTREPORTID, URL) values (<xsl:value-of select="$escaped_id" />,  <xsl:value-of select="$escaped_requestResponseData" />,  <xsl:value-of select="$escaped_sendTime" />, <xsl:value-of select="$escaped_waitTime" />, <xsl:value-of select="$escaped_receiveTime" />, <xsl:value-of select="$escaped_scriptReportId" />, <xsl:value-of select="$escaped_url" /> );
	</xsl:template>
	
</xsl:stylesheet>