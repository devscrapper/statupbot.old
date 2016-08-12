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
					div#navbar {border:1px solid white;border-bottom:1px solid gray;padding:1px}
					a{text-decoration:none;color:white;}
					a.INFO{color:black}
					a.START,a.STOP{color:black;font-weight:bold;}
					div.INFO{background-color:white}
					div.SUCCESS{background-color:green;color:white}
					div.FAILURE,div.ERROR{background-color:red;color:white}
					a.CUSTOM,
					a.CUSTOM2, a.CUSTOM4{color:black}
					div.CUSTOM{background-color:yellow;}
					div.CUSTOM1{background-color:orange;}
					div.CUSTOM2{background-color:#EFEFEF;}
					div.CUSTOM3{background-color:green;}
					div.CUSTOM4{background-color:violet;}
					div.CUSTOM5{background-color:indigo;}
					a.SCRIPT{text-decoration:underline;}
					span.extra{color:#CCC;}
					div.SKIPPED{background-color:#eed;}
					a.SKIPPED{color:gray;}

					table.scriptSummaries{border-top:1px solid gray;border-right:1px solid gray;border-spacing:0px;border-collapse:collapse;}
					table.scriptSummaries td{border-bottom:1px solid gray;border-left:1px solid gray;padding:5px;text-align:right;}
					td a.SCRIPT{float:left;}
					tr.FAILURE{background-color:red;color:white;}
					tr.SUCCESS{background-color:green;color:white;}
					tr.RUNNING{background-color:orange;color:black;}
					a{color:white;}
					tr.RUNNING a {color:black;}

					table.suite_summary {border:1px solid orange; margin-bottom:30px;background-color:#fff;width:600px;}
					table.suite_summary td {vertical-align:top;padding:3px;text-align:left;}
					table.suite_summary_part {border:0px;}
					table.suite_summary_part *{border:0px;spacing:0px;}
					
					body *{font-family:verdana;font-size:10pt;}
					body {margin:10px; background-color:lightyellow;
					
					#navbar a{color: blue;}
</style>
			</head>

			<body>
				<xsl:apply-templates />
			</body>
		</html>
	</xsl:template>

	<xsl:template match="suiteSummary">
		<xsl:param name="suiteId" select="suiteReportId|SUITEREPORTID" />
		<xsl:param name="className" select="status|STATUS" />
		<xsl:param name="suitePath" select="suitePath|SUITEPATH" />
		<xsl:param name="startTime" select="startTime|STARTTIME" />
		<xsl:param name="endTime" select="endTime|ENDTIME" />
		<xsl:param name="suiteName" select="suiteName|SUITENAME" />
		
		<h2>
			Suite Name:
				<xsl:value-of select="suiteName|SUITENAME" />
		</h2>
		<table class="suite_summary">
			<tr>
				<td>
					<table class="suite_summary_part">
						<tr>
							<td>Browser Type</td>
							<td>
								<xsl:value-of select="browserType|BROWSERTYPE" />
							</td>
						</tr>
						<tr>
							<td>Start Time</td>
							<td>
								<xsl:value-of select="util:humanTime($startTime)" />
							</td>
						</tr>
						<tr>
							<td>End Time</td>
							<td>
								<xsl:value-of select="util:humanTime($endTime)" />
							</td>
						</tr>
						<tr>
							<td>Time Taken (ms)</td>
							<td>
								<xsl:value-of select="timeTaken|TIMETAKEN" />
							</td>
						</tr>
					</table>
				</td>
				<td>
					<table class="suite_summary_part">
						<tr>
							<td>Total testcases run</td>
							<td>
							 	<xsl:value-of select="count(/suite/testCaseSummaries/testCaseSummary)"/> 
							</td>
						</tr>
						<tr>
							<td>Testcases passed</td>
							<td>
							 	<xsl:value-of select="count(/suite/testCaseSummaries/testCaseSummary[STATUS='SUCCESS'])"/> 
							</td>
						</tr>
						<tr>
							<td>Testcases failed</td>
							<td>
							 	<xsl:value-of select="count(/suite/testCaseSummaries/testCaseSummary[STATUS='FAILURE'])"/> 
							</td>
						</tr>
						<tr class="{$className}" id="status">
							<td>Status</td>
							<td>
								<xsl:value-of select="status|STATUS" />
							</td>
						</tr>
					</table>
				</td>
			</tr>
			<tr>
				<td colspan="2" style="padding:7px;">
					<h3>Suite Info</h3>
					<div id="suiteInfo" style="display:inline;">
						<pre>
						<xsl:value-of select="suiteInfo|SUITEINFO" />
						</pre>
					</div>
				</td>
			</tr>
			<tr>
			<td colspan="2" style="padding:7px;">
				<h3>Nodes Info</h3><br/>
				<div id="nodesInfo" style="display:inline;">
				<table style="width:550px;">
					<tr>
						<td>Host</td>
						<td>Port</td>
						<td>Tests executed</td>
					</tr>
			
					<xsl:for-each select="(nodes/node)|(NODES/NODE)">
						<tr>
							<td>
								<xsl:value-of select="host|HOST" />
							</td>
							<td>
								<xsl:value-of select="port|PORT" />
							</td>
							<td>
								<xsl:value-of select="scriptCount|SCRIPTCOUNT" />
							</td>
						</tr>
					</xsl:for-each>
				</table>		
				</div>
			</td>
			</tr>
		</table>

			<script>
			<![CDATA[
			function refreshPage(){
				var el = document.getElementById("status");
				if (el && (el.className == "SUCCESS" || el.className == "FAILURE")){
					return;
				}
				window.setTimeout("window.location.reload();", 2000);
			}
			refreshPage();
			function showHide(s){var el=document.getElementById(s);el.style.display = (el.style.display == 'block') ? 'none' : 'block'; }; 
			]]>
			</script>
	</xsl:template>

	<xsl:template match="scriptSummaries">
	</xsl:template>

	<xsl:template match="testCaseSummaries">
		<table class="scriptSummaries" style="margin-top:20px;background:white;width:800px;">
		<tr><td>Test Case Id</td><td>Description</td><td>Status</td><td>Time Taken</td><td>Script Name</td></tr>
		<xsl:for-each select="testCaseSummary">
		<xsl:param name="reportId" select="reportId|SCRIPTREPORTID" />
			<xsl:param name="cn" select="status|STATUS" />
			<tr class="{$cn}">
			<td>
			<xsl:choose>
				<xsl:when test="$useDBURL = 'true'">
					<a class="SCRIPT" href="/_s_/dyn/pro/DBReports_scriptReport?id={$reportId}"><xsl:value-of select="testCaseReportId|TESTCASEREPORTID" /></a>
				</xsl:when>
				<xsl:otherwise>
					<a class="SCRIPT" href="{$reportId}.htm"><xsl:value-of select="testCaseReportId|TESTCASEREPORTID" /></a>
				</xsl:otherwise>
			</xsl:choose>
			</td>
			<td><xsl:value-of select="description|DESCRIPTION" /></td>
			<td><xsl:value-of select="status|STATUS" /></td>
			<td><xsl:value-of select="timeTaken|TIMETAKEN" /></td>
			<td><xsl:value-of select="scriptName|SCRIPTNAME" /></td>
			</tr>
		</xsl:for-each>
		</table>
	</xsl:template>

</xsl:stylesheet>