<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="in.co.sahi.util.XSLUtils"
	version="1.0">

	<xsl:output method="html" indent="yes" />
	<xsl:param name="useDBURL" select="false" />
	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
				<style>
					div{padding:3px;}
					a{text-decoration:none;color:white;}
					a.INFO{color:black;}
					a.START,a.STOP{color:black;font-weight:bold;}
					div.INFO{background-color:white}
					div.SUCCESS{background-color:green;color:white}
					div.FAILURE,div.ERROR{background-color:red;color:white}
					a.CUSTOM, a.CUSTOM2, a.CUSTOM4{color:black}
					div.CUSTOM{background-color:yellow;}
					div.CUSTOM1{background-color:orange;}
					div.CUSTOM2{background-color:#EFEFEF;}
					div.CUSTOM3{background-color:green;}
					div.CUSTOM4{background-color:violet;}
					div.CUSTOM5{background-color:indigo;}
					a.SCRIPT{text-decoration:underline;}
					span.extra{color:#CCC;margin-left:20px;}
					div.SKIPPED{background-color:#eed;}
					a.SKIPPED{color:gray;}
					tr.step_SUCCESS{background-color:lightgreen;color:black;}
					tr.step_FAILURE{background-color:red;color:white;}
					div.GROUP {padding:0px;}
					div.GROUP_LABEL {font-weight: bold;cursor:pointer; padding:5px;}
					div.GROUP_INNER{padding:10px;display:none;border:1px solid gray;}
				
					table.summary {border-top:1px solid gray;border-right:1px solid
					gray;border-spacing:0px;border-collapse:collapse;}
					table.summary td{border-bottom:1px solid gray;border-left:1px solid
					gray;padding:5px;text-align:right;}
					td a.SCRIPT{float:left;}
					tr.FAILURE{background-color:red;color:white;}
					tr.SUCCESS{background-color:green;color:white;}
					a{color:white;}
					
					body *{font-family:verdana;font-size:10pt;}
					body {margin:10px; background-color:lightyellow;}
					
					tr.step_SUCCESS{background-color:lightgreen;color:black;}
					tr.step_FAILURE{background-color:red;color:white;}
					
					#navbar a{color: blue;}
					#navbar {padding:2px;border:1px solid white;border-bottom:1px solid gray;padding:1px}
				</style>
			</head>

			<body>
				<xsl:apply-templates />
			</body>
		</html>
	</xsl:template>

	<xsl:template match="testCaseSummaries">
		<table class="summary" style="background-color:white;margin-top:20px;width:700px;">
		<xsl:for-each select="testCaseSummary">
			<xsl:if test="(position()) = 1">
			<tr><td>Test Case Id</td><td>Description</td><td>Status</td><td>Time Taken</td></tr>
		    </xsl:if>
			<xsl:param name="cn" select="status|STATUS" />
			<tr class="{$cn}">
			<td><xsl:value-of disable-output-escaping="yes" select="testCaseReportId|TESTCASEREPORTID" /></td>
			<td><xsl:value-of disable-output-escaping="yes" select="description|DESCRIPTION" /></td>
			<td><xsl:value-of disable-output-escaping="yes" select="status|STATUS" /></td>
			<td><xsl:value-of disable-output-escaping="yes" select="timeTaken|TIMETAKEN" /></td>
			</tr>
		</xsl:for-each>
		</table>
	</xsl:template>

	<xsl:template match="summary">
		<xsl:param name="className" select="status|STATUS" />
		<xsl:param name="stepsCount" select="number(steps|TOTALSTEPS)" />
		<xsl:param name="failures" select="number(failures|FAILURES)" />
		<xsl:param name="errors" select="number(errors|ERRORS)" />
		<xsl:param name="suiteReportId" select="suiteReportId|SUITEREPORTID" />
		<xsl:param name="scriptReportId" select="scriptReportId|SCRIPTREPORTID" />
		<xsl:param name="load" select="number(load|LOAD)" />
		<xsl:choose>
			<xsl:when test="$useDBURL = 'true'">
				<div id='navbar'> 
					<a href='/_s_/dyn/pro/DBReports' style="color:black">Root</a> |
					<a href='/_s_/dyn/pro/DBReports_suiteReport?id={$suiteReportId}' style="color:black">Script Report</a> |
					<xsl:choose>
						<xsl:when test="starts-with($suiteReportId, 'LOAD_')">
							<a href='/_s_/dyn/pro/DBReports_reconciledReport?id={$suiteReportId}' style="color:black">Load Test Summary</a> 
						</xsl:when>
						<xsl:otherwise>
							<a href='/_s_/dyn/pro/DBReports_testCaseReport?id={$suiteReportId}' style="color:black">Test Cases Report</a>
							| <a href='/_s_/dyn/pro/DBReports_csvTestCasesReport?id={$suiteReportId}' style="color:black">Test Cases Report Summary</a>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div id='navbar'> 
					<a href='/_s_/dyn/Log_viewLogs' style="color:black">Root</a> |
					<a href='index.html' style="color:black">Script Report</a> |
					<a href='testcase_summary.html' style="color:black">Test Cases Report</a> |
					<a href='results.csv' style="color:black">Test Cases Report Summary</a>
				</div>
			</xsl:otherwise>
		</xsl:choose>
		
		<table class="summary" style="background-color:white;margin-top:20px;width:700px;">
			<tr>
				<td>Test</td>
				<td>Total Steps</td>
				<td>Failures</td>
				<td>Errors</td>
				<td>Success Rate</td>
				<td>Time Taken (ms)</td>
				<td>Node</td>
				<td>Load</td>
				<td></td>
			</tr>
			<tr class="{$className}">
				<td>
					<xsl:value-of select="scriptName|SCRIPTNAME" />
				</td>
				<td>
					<xsl:value-of select="$stepsCount" />
				</td>
				<td>
					<xsl:value-of select="$failures" />
				</td>
				<td>
					<xsl:value-of select="$errors" />
				</td>
				<td>
					<xsl:choose>
						<xsl:when test="$stepsCount &gt; 0">
							<xsl:value-of
								select="round(($stepsCount - $failures - $errors) div $stepsCount * 100)" />
							%
						</xsl:when>
						<xsl:otherwise>
							0%
						</xsl:otherwise>
					</xsl:choose>
				</td>
				<td>
					<xsl:value-of select="timeTaken|TIMETAKEN" />
				</td>
				<td>
					<xsl:value-of select="nodeHost|NODEHOST" />:<xsl:value-of select="nodePort|NODEPORT" />
				</td>
				<td>
					<xsl:value-of select="load|LOAD" />
				</td>
				<td>
					<xsl:choose>
						<xsl:when test="$useDBURL = 'true'">
							<a href="/_s_/dyn/pro/DBReports_compare?logFile1={$scriptReportId}" target="_top">Compare Logs</a>
						</xsl:when>
						<xsl:otherwise>
							<a href="/_s_/dyn/Log_compare?logFile1={/suite/suiteSummary/suiteId}/{$scriptReportId}" target="_top">Compare Logs</a>
						</xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>
		</table>
		
	</xsl:template>

	<xsl:template match="steps|STEPS">
		<br />
		<div style="padding:10px;background-color:white;border:1px solid #ddd;">
		<div class="START">
			<a class="START">Starting script</a>
		</div>
		<xsl:for-each select="step">
			<xsl:param name="ix" select="position()" />
			<xsl:param name="className" select="type|MESSAGETYPE" />
			<xsl:param name="debugInfo" select="debugInfo|DEBUGINFO" />
			<xsl:param name="failureMsg" select="failureMsg|FAILUREMESSAGE" />
			<xsl:param name="result" select="message|MESSAGE" />
			<xsl:param name="scriptReportId" select="scriptReportId|SCRIPTREPORTID" />
			<xsl:param name="screenShot" select="SCREENSHOT" />
			<xsl:choose>
				<xsl:when test="starts-with($result,'_log')">
				</xsl:when>
				<xsl:when test="$className=&quot;RAW&quot;">
					<xsl:value-of disable-output-escaping="yes" select="message|MESSAGE" />
				</xsl:when>
				<xsl:when test="$className=&quot;TESTCASE_START&quot;">
					<xsl:text disable-output-escaping="yes">
						<![CDATA[
							<div class="GROUP">
				 		]]>
				 		</xsl:text>
						<div class="GROUP_LABEL">
							<xsl:value-of disable-output-escaping="yes" select="message|MESSAGE" />
						</div>
						<xsl:text disable-output-escaping="yes">
						<![CDATA[
						<div class="GROUP_INNER">
						]]>
						</xsl:text>
				</xsl:when>
				<xsl:when test="$className=&quot;TESTCASE_END&quot;">
					<xsl:text disable-output-escaping="yes">
					<![CDATA[
					</div></div>
					]]>
					</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<div class="{$className}">
						<a class="{$className}" href="/_s_/dyn/Log_highlight?href={$debugInfo}#selected"
							title="{$debugInfo}">
							<xsl:value-of disable-output-escaping="yes" select="message|MESSAGE" />
						</a>
						<span class='extra'>
						<xsl:choose>
							<xsl:when test="$ix=1">
								[110 ms]
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="time" select="time|MESSAGETIMESTAMP" />
								<xsl:variable name="fixedTime" select="util:fixMillis($time)" />
								<xsl:variable name="prevTime" select="/result/steps/step[$ix - 1]/MESSAGETIMESTAMP" />
								<xsl:variable name="fixedPrevTime" select="util:fixMillis($prevTime)" />
								<xsl:variable name="difference" select="util:timeDifference($fixedTime,$fixedPrevTime)" />
								[<xsl:value-of select="$difference" /> ms]
							</xsl:otherwise>
						</xsl:choose>
						</span>
						<xsl:if test="not($failureMsg = '')">
							<div><xsl:value-of disable-output-escaping="yes" select="$failureMsg" /></div>
						</xsl:if>
						<xsl:if test="not($screenShot = '')">
							<a href="/_s_/dyn/Log_viewLogs/images/{$screenShot}" style="margin:0px;padding:0px" target="_blank"><img style="margin-top:15px;margin-bottom:30px;display:block;" src="/_s_/dyn/Log_viewLogs/images/{$screenShot}" height="337" /></a>
						</xsl:if>
						
					</div>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
		<div class="STOP">
			<a class="STOP">Stopping script</a>
		</div>
		<script type="text/javascript">
		<![CDATA[
		function hideImage(i){i.style.display='none';}
        var divs = document.getElementsByTagName('DIV'); 
        for (var i=0; i<divs.length; i++){
        	var d = divs[i]; 
        	if (d.className == 'GROUP') { attachFn(d); markStatus(d);} 
        }
        function attachFn(d){ d.getElementsByTagName('DIV')[0].onclick = function () {showHideDiv(d);}	} 
        function getInnerDiv(d){return d.getElementsByTagName('DIV')[1];}
        function showHideDiv(groupDiv){	var stepsDiv = getInnerDiv(groupDiv);	stepsDiv.style.display = (stepsDiv.style.display == 'block') ? 'none' : 'block'; }; 
        function markStatus(d) {d.getElementsByTagName('DIV')[0].className += (d.innerHTML.indexOf('<!--SAHI_TESTCASE_FAIL_MARKER-->') == -1) ? ' SUCCESS' : ' FAILURE'};
        ]]>
        </script>
        </div>
	</xsl:template>
</xsl:stylesheet>