<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="in.co.sahi.datastore.SQLUtils" exclude-result-prefixes="util" version="1.0">
	<xsl:output method="text" indent="no" omit-xml-declaration="yes" />
	<xsl:param name="suiteId"/>
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="summary">
	    <!-- Insert script_results row -->
		<xsl:variable name="scriptId" select="reportId"/>
		<xsl:variable name="escaped_scriptId" select="util:sqlString($scriptId)"/>	 		
		<xsl:variable name="escaped_suiteId" select="util:sqlString($suiteId)"/>	 		
		<xsl:variable name="scriptName" select="scriptName"/>
		<xsl:variable name="escaped_scriptName" select="util:sqlString($scriptName)"/>	    
		<xsl:variable name="suiteName" select="suiteName"/>
		<xsl:variable name="escaped_suiteName" select="util:sqlString($suiteName)"/>	    
		<xsl:variable name="steps" select="steps"/>
		<xsl:variable name="escaped_steps" select="util:sqlNumber($steps)"/>
		<xsl:variable name="failures" select="failures"/>
		<xsl:variable name="escaped_failures" select="util:sqlNumber($failures)"/>
		<xsl:variable name="errors" select="errors"/>

		<xsl:variable name="tcCount" select="tcCount"/>
		<xsl:variable name="escaped_tcCount" select="util:sqlNumber($tcCount)"/>
		<xsl:variable name="tcPassed" select="tcPassed"/>
		<xsl:variable name="escaped_tcPassed" select="util:sqlNumber($tcPassed)"/>
		<xsl:variable name="tcFailed" select="tcFailed"/>
		<xsl:variable name="escaped_tcFailed" select="util:sqlNumber($tcFailed)"/>

		<xsl:variable name="escaped_errors" select="util:sqlNumber($errors)"/>
		<xsl:variable name="timeTaken" select="timeTaken"/>
		<xsl:variable name="escaped_timeTaken" select="util:sqlNumber($timeTaken)"/>
		<xsl:variable name="nodeHost" select="nodeHost"/>
		<xsl:variable name="escaped_nodeHost" select="util:sqlString($nodeHost)"/>
		<xsl:variable name="nodePort" select="nodePort"/>
		<xsl:variable name="escaped_nodePort" select="util:sqlString($nodePort)"/>
		<xsl:variable name="status" select="status"/>
		<xsl:variable name="escaped_status" select="util:sqlString($status)"/>
		<xsl:variable name="load" select="load"/>
		<xsl:variable name="escaped_load" select="util:sqlNumber($load)"/>
insert into SCRIPTREPORTS (SCRIPTREPORTID, SCRIPTNAME, SUITENAME, TOTALSTEPS, FAILURES, ERRORS, TCCOUNT, TCPASSED, TCFAILED, TIMETAKEN, NODEHOST, NODEPORT, STATUS, SUITEREPORTID, `LOAD`) values (<xsl:value-of select="$escaped_scriptId"/>, <xsl:value-of select="$escaped_scriptName" />, <xsl:value-of select="$escaped_suiteName" />, <xsl:value-of select="$escaped_steps" />, <xsl:value-of select="$escaped_failures" />, <xsl:value-of select="$escaped_errors" />, <xsl:value-of select="$escaped_tcCount" />, <xsl:value-of select="$escaped_tcPassed" />, <xsl:value-of select="$escaped_tcFailed" />, <xsl:value-of select="$escaped_timeTaken" />, <xsl:value-of select="$escaped_nodeHost" />, <xsl:value-of select="$escaped_nodePort" />, <xsl:value-of select="$escaped_status" />,  <xsl:value-of select="$escaped_suiteId"/>, <xsl:value-of select="$escaped_load" />);   
	</xsl:template>
	
	<xsl:template match="testCaseSummaries">
		<xsl:for-each select="testCaseSummary">
		    <!-- Insert script_results row -->
			<xsl:variable name="scriptId" select="../../summary/reportId"/>
			<xsl:variable name="escaped_scriptId" select="util:sqlString($scriptId)"/>	 		
			<xsl:variable name="escaped_suiteId" select="util:sqlString($suiteId)"/>	 		
			<xsl:variable name="testcaseReportId" select="testCaseReportId"/>
			<xsl:variable name="escaped_testcaseReportId" select="util:sqlString($testcaseReportId)"/>
			<xsl:variable name="description" select="description"/>
			<xsl:variable name="escaped_description" select="util:sqlString($description)"/>
			<xsl:variable name="status" select="status"/>
			<xsl:variable name="escaped_status" select="util:sqlString($status)"/>
			<xsl:variable name="timeTaken" select="timeTaken"/>
			<xsl:variable name="escaped_timeTaken" select="util:sqlNumber($timeTaken)"/>
			<xsl:variable name="scriptName" select="../../summary/scriptName"/>
			<xsl:variable name="escaped_scriptName" select="util:sqlString($scriptName)"/>
			
			
insert into TESTCASEREPORTS (TESTCASEREPORTID, SCRIPTREPORTID, SUITEREPORTID, DESCRIPTION, STATUS, TIMETAKEN, SCRIPTNAME) values (<xsl:value-of select="$escaped_testcaseReportId"/>, <xsl:value-of select="$escaped_scriptId"/>, <xsl:value-of select="$escaped_suiteId" />, <xsl:value-of select="$escaped_description" />, <xsl:value-of select="$escaped_status" />, <xsl:value-of select="$escaped_timeTaken" />, <xsl:value-of select="$escaped_scriptName" />);   
		</xsl:for-each>
	</xsl:template>

	<xsl:template match="steps">
insert into STEPREPORTS (MESSAGE, DEBUGINFO, MESSAGETYPE, MESSAGETIMESTAMP, SCRIPTREPORTID, FAILUREMESSAGE, SCREENSHOT, STEPID) values <xsl:for-each select="step">
	    	<!-- Insert step_results row -->
	    	<xsl:variable name="scriptId" select="../../summary/reportId"/>
			<xsl:variable name="escaped_scriptId" select="util:sqlString($scriptId)"/>	 
			<xsl:variable name="message" select="message"/>
			<xsl:variable name="escaped_message" select="util:sqlString($message, 4000)"/>
			<xsl:variable name="debugInfo" select="debugInfo"/>
			<xsl:variable name="escaped_debugInfo" select="util:sqlString($debugInfo, 4000)"/>
			<xsl:variable name="failureMsg" select="failureMsg"/>
			<xsl:variable name="escaped_failureMsg" select="util:sqlString($failureMsg)"/>
			<xsl:variable name="type" select="type"/>
			<xsl:variable name="escaped_type" select="util:sqlString($type)"/>
			<xsl:variable name="time" select="time"/>
			<xsl:variable name="escaped_time" select="util:sqlTime($time)"/>
			<xsl:variable name="screenShot" select="screenShot"/>
			<xsl:variable name="escaped_screenShot" select="util:sqlString($screenShot)"/>
			<xsl:variable name="stepId" select="stepId"/>
			<xsl:variable name="escaped_stepId" select="util:sqlString($stepId)"/>
(<xsl:value-of select="$escaped_message" />, <xsl:value-of select="$escaped_debugInfo" />, <xsl:value-of select="$escaped_type" />, <xsl:value-of select="$escaped_time" />, <xsl:value-of select="$escaped_scriptId"/>, <xsl:value-of select="$escaped_failureMsg" />, <xsl:value-of select="$escaped_screenShot" />, <xsl:value-of select="$escaped_stepId" />) <xsl:if test="position() != last()">,</xsl:if>	
		</xsl:for-each>;
	</xsl:template>
</xsl:stylesheet>