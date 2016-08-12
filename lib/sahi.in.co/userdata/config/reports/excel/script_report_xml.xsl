<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="in.co.sahi.util.XSLUtils" version="1.0">
	<xsl:output method="xml" indent="yes" />
	<xsl:param name="useDBURL" select="false" />
	<xsl:param name="browserType" select="/result/suiteInfo/BROWSERTYPE" />
	<xsl:param name="scriptReportId" select="/result/summary/SCRIPTREPORTID" />
	<xsl:template match="/">
		<result>
			<xsl:apply-templates />
		</result>
	</xsl:template>

	<xsl:template match="summary">
		<xsl:param name="id" select="ID|id" />
		
		<xsl:param name="scriptName" select="SCRIPTNAME" />
		<xsl:param name="suiteName" select="SUITENAME" />
		<xsl:param name="suiteReportId" select="SUITEREPORTID" />
		<xsl:param name="totalSteps" select="number(TOTALSTEPS)" />
		<xsl:param name="failures" select="number(FAILURES)" />
		<xsl:param name="status" select="STATUS" />
		<xsl:param name="errors" select="number(ERRORS)" />
		<xsl:param name="timeTaken" select="number(TIMETAKEN)" />
		<xsl:param name="nodehost" select="NODEHOST" />
		<xsl:param name="nodeport" select="number(NODEPORT)" />
		<xsl:param name="load" select="number(LOAD)" />
		<xsl:param name="tcCount" select="number(TCCOUNT)" />
		<xsl:param name="tcPassed" select="number(TCPASSED)" />
		<xsl:param name="tcFailed" select="number(TCFAILED)" />	
		<xsl:param name="scriptRelpath" select="SCRIPTRELPATH" />	
		<xsl:param name="starturl" select="STARTURL" />	
		<xsl:param name="launcherId" select="LAUNCHERID" />
		<xsl:param name="scriptArgs" select="SCRIPTARGS" />
		<table rowHeight="20">
			<row >
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
				<cell fontWeight="bold" borderLeft="thin" borderTop="thin" fontSize="11">Test</cell>
				<cell fontWeight="bold" borderTop="thin" fontSize="11">Total Steps</cell>
				<cell fontWeight="bold" borderTop="thin" fontSize="11">Failure</cell>
				<cell fontWeight="bold" borderTop="thin" fontSize="11">Errors</cell>
				<cell fontWeight="bold" borderTop="thin" fontSize="11">Success Rate</cell>
				<cell fontWeight="bold" borderTop="thin" fontSize="11">Time Taken(ms)</cell>
				<cell fontWeight="bold" borderTop="thin" fontSize="11">Node</cell>
				<cell fontWeight="bold" borderTop="thin" fontSize="11">Load</cell>
				<cell fontWeight="bold" borderTop="thin" borderRight="thin" fontSize="11">Browser</cell>
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
				<cell color="{$cellcolor}" borderLeft="thin" fontSize="11"><xsl:value-of select="$scriptName" /></cell>
				<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="$totalSteps" /></cell>
				<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="$failures" /></cell>
				<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="$errors" /></cell>
				<cell color="{$cellcolor}" fontSize="11">
					<xsl:choose>
						<xsl:when test="$totalSteps &gt; 0">
							<xsl:value-of
								select="round(($totalSteps - $failures - $errors) div $totalSteps * 100)" />%
						</xsl:when>
						<xsl:otherwise>
							0%
						</xsl:otherwise>
					</xsl:choose>
				</cell>
				<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="$timeTaken" /></cell>
				<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="$nodehost" />:<xsl:value-of select="$nodeport" /></cell>
				<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="$load" /></cell>
				<cell color="{$cellcolor}" borderRight="thin" fontSize="11"><xsl:value-of select="$browserType" /></cell>
				<cell></cell>
			</row>
			<row>
				<cell></cell>
				<cell colspan="9" borderLeft="thin" borderBottom="thin" fontSize="11">Report Id: <xsl:value-of select="$scriptReportId" /></cell>
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
			</row>
		</table>
		<table rowHeight="20">
			<row>
				<cell></cell>
				<cell fontWeight="bold" borderLeft="thin" borderTop="thin" fontSize="11">Total Test Cases</cell>
				<cell fontWeight="bold" borderTop="thin" fontSize="11">Passed</cell>
				<cell fontWeight="bold" borderTop="thin" fontSize="11">Failed</cell>
				<cell fontWeight="bold" borderTop="thin" borderRight="thin" fontSize="11">Success Rate</cell>
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
				<cell color="{$cellcolor}" borderLeft="thin" borderBottom="thin" fontSize="11"><xsl:value-of select="$tcCount" /></cell>
				<cell color="{$cellcolor}" borderBottom="thin" fontSize="11"><xsl:value-of select="$tcPassed" /></cell>
				<cell color="{$cellcolor}" borderBottom="thin" fontSize="11"><xsl:value-of select="$tcFailed" /></cell>
				<cell color="{$cellcolor}" borderBottom="thin" borderRight="thin" fontSize="11"><xsl:choose>
						<xsl:when test="$tcCount &gt; 0">
							<xsl:value-of
								select="round(($tcCount - $tcFailed) div $tcCount * 100)" />%
						</xsl:when>
						<xsl:otherwise>
							0%
						</xsl:otherwise>
					</xsl:choose>
				</cell>
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
			</row>
		</table>
	</xsl:template>
	
	<xsl:template match="testCaseSummaries">
		<table rowHeight="20">
		<row>
			<cell></cell>
			<cell fontWeight="bold" borderLeft="thin" borderTop="thin" fontSize="11">Test Case Id</cell><cell fontWeight="bold" borderTop="thin" fontSize="11">Description</cell><cell fontWeight="bold" borderTop="thin" fontSize="11">Status</cell><cell fontWeight="bold" borderTop="thin" borderRight="thin" fontSize="11">Time Taken</cell>
			<cell></cell>
			<cell></cell>
			<cell></cell>
			<cell></cell>
			<cell></cell>
			<cell></cell>
		</row>
		<xsl:for-each select="testCaseSummary">
				<xsl:param name="st" select="STATUS" />
				<row>
					<xsl:variable name="cellcolor">
						<xsl:choose>
							<xsl:when test="$st = 'SUCCESS'">green</xsl:when>
	      					<xsl:otherwise>red</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<cell></cell>
					<cell color="{$cellcolor}" borderLeft="thin" fontSize="11"><xsl:value-of disable-output-escaping="yes" select="TESTCASEREPORTID" /></cell>
					<cell color="{$cellcolor}" fontSize="11"><xsl:value-of disable-output-escaping="yes" select="DESCRIPTION" /></cell>
					<cell color="{$cellcolor}" fontSize="11"><xsl:value-of disable-output-escaping="yes" select="$st" /></cell>
					<cell color="{$cellcolor}" borderRight="thin" fontSize="11"><xsl:value-of disable-output-escaping="yes" select="timeTaken|TIMETAKEN" /></cell>
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
			</row>
		</table>
	</xsl:template>
	
	
	<xsl:template match="steps|STEPS">
	<table>
			<row>
			<cell></cell>
			<cell fontWeight="bold" borderLeft="thin" borderTop="thin" borderBottom="thin" fontSize="11">Starting script</cell>
			<cell fontWeight="bold" borderTop="thin" borderBottom="thin" fontSize="11">Time Taken(ms)</cell>
			<cell fontWeight="bold" borderTop="thin" borderBottom="thin" borderRight="thin" fontSize="11">Time</cell>
			<cell></cell>
			<cell></cell>
			<cell></cell>
			<cell></cell>
			<cell></cell>
			<cell></cell>
			<cell></cell>
			</row>
		<xsl:for-each select="step">
			<xsl:param name="ix" select="position()" />
			<xsl:param name="id" select="ID|id" />
			<xsl:param name="message" select="MESSAGE" />
			<xsl:param name="debuginfo" select="DEBUGINFO" />
			<xsl:param name="messageType" select="MESSAGETYPE" />
			<xsl:param name="failureMessage" select="FAILUREMESSAGE" />
			<xsl:param name="messageTimeStamp" select="MESSAGETIMESTAMP" />
			<xsl:param name="screenShot" select="SCREENSHOT" />
			<xsl:param name="stepId" select="STEPID" />
			<xsl:variable name="fixedTime" select="util:fixMillis($messageTimeStamp)" />
			
			<xsl:choose>
						<xsl:when test="starts-with($message,'_log') and $messageType!=&quot;ERROR&quot;">
							<xsl:variable name="aa" select="util:getSetPreviousRowRaw()" />
							<raw><xsl:value-of select="$aa" /></raw>
						</xsl:when>
						<xsl:when test="$messageType=&quot;TESTCASE_START&quot;">
							<xsl:variable name="aa" select="util:getSetPreviousRowRaw()" />
							<raw><xsl:value-of select="$aa" /></raw>
						<row>
							<cell></cell>
							<cell fontWeight="bold" borderLeft="thin" fontSize="11">TEST START</cell>
							<cell></cell>
							<cell borderRight="thin"></cell>
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
							<cell borderLeft="thin" fontSize="11"><xsl:value-of select="util:removeXMLTags($message)" /></cell>
							<cell></cell>
							<cell borderRight="thin"></cell>
							<cell></cell>
							<cell></cell>
							<cell></cell>
							<cell></cell>
							<cell></cell>
							<cell></cell>
							<cell></cell>
						</row>
						</xsl:when>
						<xsl:when test="$messageType=&quot;GROUP_START&quot;">
							<xsl:variable name="aa" select="util:getSetPreviousRowRaw()" />
							<raw><xsl:value-of select="$aa" /></raw>
						<row>
							<cell></cell>
							<cell borderLeft="thin" fontSize="11"><xsl:value-of select="util:removeXMLTags($message)" /></cell>
							<cell></cell>
							<cell borderRight="thin"></cell>
							<cell></cell>
							<cell></cell>
							<cell></cell>
							<cell></cell>
							<cell></cell>
							<cell></cell>
							<cell></cell>
						</row>
						</xsl:when>
						<xsl:when test="$messageType=&quot;TESTCASE_END&quot;">
							<xsl:variable name="aa" select="util:getSetPreviousRowRaw()" />
							<raw><xsl:value-of select="$aa" /></raw>
						<row>
							<cell></cell>
							<cell fontWeight="bold" borderLeft="thin" fontSize="11">TEST END</cell>
							<cell></cell>
							<cell borderRight="thin"></cell>
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
							<cell borderLeft="thin"></cell>
							<cell></cell>
							<cell borderRight="thin"></cell>
							<cell></cell>
							<cell></cell>
							<cell></cell>
							<cell></cell>
							<cell></cell>
							<cell></cell>
							<cell></cell>
						</row>
						</xsl:when>
						<xsl:when test="$messageType=&quot;GROUP_END&quot;">
							<xsl:variable name="aa" select="util:getSetPreviousRowRaw()" />
							<raw><xsl:value-of select="$aa" /></raw>
						</xsl:when>
						<xsl:when test="$messageType=&quot;RAW&quot;">
							<xsl:variable name="aa" select="util:getSetPreviousRowRaw()" />
							<raw><xsl:value-of select="$aa" /></raw>
						</xsl:when>
						<xsl:otherwise>
						<row>	
							<xsl:variable name="cellcolor">
								<xsl:choose>
									<xsl:when test="$messageType = 'SUCCESS'">green</xsl:when>
									<xsl:when test="$messageType = 'FAILURE' or $messageType = 'ERROR'">red</xsl:when>
			      					<xsl:otherwise></xsl:otherwise>
								</xsl:choose>
							</xsl:variable>
							
							<xsl:choose>
								<xsl:when test="$messageType = 'SUCCESS'">
								<cell></cell>
								<cell color="green" borderLeft="thin" fontSize="11"><xsl:value-of select="util:removeXMLTags($message)" /></cell>
								</xsl:when>
								<xsl:when test="$messageType = 'FAILURE' or $messageType = 'ERROR'">
									<cell></cell>
									<cell color="red" borderLeft="thin" fontSize="11"><xsl:value-of select="util:removeXMLTags($message)" />
									[<xsl:value-of select="$failureMessage" />]</cell>
								</xsl:when>
								<xsl:otherwise>
									<cell></cell>
									<cell borderLeft="thin" fontSize="11"><xsl:value-of select="util:removeXMLTags($message)" /></cell>
								</xsl:otherwise>
							</xsl:choose>
								<xsl:variable name="raw" select="util:getPreviousRowRaw()" />
								<xsl:variable name="prevTime" >
									<xsl:choose>
										<xsl:when test="number($ix -$raw - 1) &lt; 1">
											<xsl:value-of select="util:getStartTime($scriptReportId)"/>
										</xsl:when>
				      					<xsl:otherwise>
				      						<xsl:value-of select="/result/steps/step[$ix -$raw - 1]/MESSAGETIMESTAMP"/>
				      					</xsl:otherwise>
									</xsl:choose>
								</xsl:variable>
								<xsl:variable name="fixedPrevTime" select="util:fixMillis($prevTime)" />
								<xsl:variable name="difference" select="util:timeDifference($fixedTime,$fixedPrevTime)" />
								<cell color="{$cellcolor}" fontSize="11"><xsl:value-of select="$difference" /></cell>
								<cell color="{$cellcolor}" borderRight="thin" fontSize="11"><xsl:value-of select="util:customTime($fixedTime, 'hh:mm:ss.SSS')" /></cell>
								<cell></cell>
								<cell></cell>
								<cell></cell>
								<cell></cell>
								<cell></cell>
								<cell></cell>
								<cell></cell>
							<image><xsl:value-of select="$screenShot" /></image>
						</row>	
						</xsl:otherwise>
				</xsl:choose>
		</xsl:for-each>
			<row>
				<cell></cell>
				<cell fontWeight="bold" borderLeft="thin" borderBottom="thin" fontSize="11">Stopping script</cell>
				<cell borderBottom="thin"></cell>
				<cell borderBottom="thin" borderRight="thin"></cell>
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
			</row>
	</table>
	</xsl:template>
	<xsl:template match="suiteInfo">
	<suiteInfo>
		<xsl:param name="id" select="ID|id" />
		<xsl:param name="suiteReportId" select="SUITEREPORTID" />
		<xsl:param name="suiteName" select="SUITENAME" />
		<xsl:param name="suitePath" select="SUITEPATH" />
		<xsl:param name="startTime" select="STARTTIME" />
		<xsl:param name="endTime" select="ENDTIME" />
		<xsl:param name="status" select="STATUS" />
		<xsl:param name="totalCount" select="TOTALCOUNT" />
		<xsl:param name="passedCount" select="PASSEDCOUNT" />
		<xsl:param name="failedCount" select="FAILEDCOUNT" />
		<xsl:param name="timeTaken" select="TIMETAKEN" />
		<xsl:param name="suiteInfo" select="SUITEINFO" />
		<xsl:param name="userDefinedId" select="USERDEFINEDID" />
		<xsl:param name="tcCount" select="TCCOUNT" />
		<xsl:param name="tcPassed" select="TCPASSED" />
		<xsl:param name="tcFailed" select="TCFAILED" />
			<ID><xsl:value-of select="$id" /></ID>
			<SUITEREPORTID><xsl:value-of select="$suiteReportId" /></SUITEREPORTID>
			<SUITENAME><xsl:value-of select="$suiteName" /></SUITENAME>
			<SUITEPATH><xsl:value-of select="$suitePath" /></SUITEPATH>
			<STARTTIME><xsl:value-of select="$startTime" /></STARTTIME>
			<ENDTIME><xsl:value-of select="$endTime" /></ENDTIME>
			<STATUS><xsl:value-of select="$status" /></STATUS>
			<TOTALCOUNT><xsl:value-of select="$totalCount" /></TOTALCOUNT>
			<PASSEDCOUNT><xsl:value-of select="$passedCount" /></PASSEDCOUNT>
			<FAILEDCOUNT><xsl:value-of select="$failedCount" /></FAILEDCOUNT>
			<TIMETAKEN><xsl:value-of select="$timeTaken" /></TIMETAKEN>
			<BROWSERTYPE><xsl:value-of select="$browserType" /></BROWSERTYPE>
			<SUITEINFO><xsl:value-of select="$suiteInfo" /></SUITEINFO>
			<USERDEFINEDID><xsl:value-of select="$userDefinedId" /></USERDEFINEDID>
			<TCCOUNT><xsl:value-of select="$tcCount" /></TCCOUNT>
			<TCPASSED><xsl:value-of select="$tcPassed" /></TCPASSED>
			<TCFAILED><xsl:value-of select="$tcFailed" /></TCFAILED>
	</suiteInfo>
	</xsl:template>
</xsl:stylesheet>