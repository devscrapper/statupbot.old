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
					div{padding:3px}
					a{text-decoration:none;color:white;}
					a.INFO{color:black}
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
					span.extra{color:#CCC;}
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
					
					#navbar{border:1px solid white;border-bottom:1px solid
					gray;padding:1px}
					#navbar a{color: blue;}
					
					table.scriptSummaries{border-top:1px solid gray;border-right:1px solid gray;border-spacing:0px;border-collapse:collapse;}
					table.scriptSummaries td{border-bottom:1px solid gray;border-left:1px solid gray;padding:5px;text-align:right;}
					
				</style>
				<script language="JavaScript" src="/_s_/spr/charts/JSClass/FusionCharts.js"></script>
			</head>

			<body>
				<xsl:apply-templates />
			</body>
		</html>
	</xsl:template>
	
		<xsl:template name="getStepCount">
			<xsl:value-of select="//suite/scriptSummaries/summary/TOTALSTEPS[not(. &lt; ../preceding-sibling::summary/TOTALSTEPS) and not(. &lt; ../following-sibling::summary/TOTALSTEPS)]"/>
		</xsl:template>
		
		<xsl:template match="scriptSummaries">
		<xsl:param name="suiteId" select="summary/SUITEREPORTID"/>
		<xsl:param name="runs" select="count(//suite/scriptSummaries/summary)"/>
		<xsl:variable name="stepsCount"><xsl:call-template name="getStepCount"/></xsl:variable>
		<input type="hidden" id="runs" value="{$runs}"/>
		<input type="hidden" id="steps" value="{$stepsCount}"/>
		<xsl:choose>
			<xsl:when test="$useDBURL = 'true'">
				<div id='navbar'> <a href='/_s_/dyn/pro/DBReports' style="color:black">Root</a> | <a href='/_s_/dyn/pro/DBReports_suiteReport?id={$suiteId}' style="color:black">Script Report</a> | <a href='/_s_/dyn/pro/DBReports_reconciledReport?id={$suiteId}' style="color:black">Load Test Summary</a></div>
			</xsl:when>
			<xsl:otherwise>
				<div id='navbar'> <a href='/_s_/dyn/Log_viewLogs' style="color:black">Root</a> | <a href='index.htm' style="color:black">Script Report</a> | <a href='results.csv' style="color:black">Load Test Summary</a></div>
			</xsl:otherwise>
		</xsl:choose>
		<h2 onclick="el=document.getElementById('scriptSummaries');el.style.display=el.style.display=='none'?'block':'none'" style="cursor:pointer">
			Scripts:
		</h2>
		<div id="scriptSummaries" style="display:none">
		<table class="scriptSummaries">
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

			<xsl:for-each select="summary">
				<xsl:param name="className" select="status|STATUS" />
				<tr class="{$className}">
					<xsl:param name="reportId" select="reportId|SCRIPTREPORTID" />
					<xsl:param name="steps" select="steps|TOTALSTEPS" />
					<xsl:param name="failures" select="failures|FAILURES" />
					<xsl:param name="errors" select="errors|ERRORS" />
					<xsl:param name="load" select="load|LOAD" />
					<td>
					<xsl:choose>
						<xsl:when test="$useDBURL = 'true'">
							<a class="SCRIPT" href="/_s_/dyn/pro/DBReports_scriptReport?id={$reportId}"><xsl:value-of select="scriptName|SCRIPTNAME" /></a>
						</xsl:when>
						<xsl:otherwise>
							<a class="SCRIPT" href="{$reportId}.htm"><xsl:value-of select="scriptName|SCRIPTNAME" /></a>
						</xsl:otherwise>
					</xsl:choose>
					</td>
					<td>
						<xsl:value-of select="steps|TOTALSTEPS" />
					</td>
					<td>
						<xsl:value-of select="failures|FAILURES" />
					</td>
					<td>
						<xsl:value-of select="errors|ERRORS" />
					</td>
					<td>
						<xsl:choose>
							<xsl:when test="$steps &gt; 0">
								<xsl:value-of
									select="round(($steps - $failures - $errors) div $steps * 100)" />
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
					<td id="load-{position()}">
						<xsl:value-of select="load|LOAD" />
					</td>
					<td>
					<xsl:choose>
						<xsl:when test="$useDBURL = 'true'">
							<a href="/_s_/dyn/pro/DBReports_compare?logFile1={$reportId}" target="_top">Compare Logs</a>
						</xsl:when>
						<xsl:otherwise>
							<a href="/_s_/dyn/Log_compare?logFile1={/suite/suiteSummary/suiteId}/{$reportId}" target="_top">Compare Logs</a>
						</xsl:otherwise>
					</xsl:choose>
					
					</td>
					
				</tr>
			</xsl:for-each>

		</table>
		</div>
	</xsl:template>
	
	<xsl:template name="getRemainingTD">
		<xsl:param name="i" />
	<xsl:param name="maxSteps" />
	<xsl:if test="$i &lt;= $maxSteps">
		<tr><td><div class="INFO">
			0 ms
		</div></td></tr>
		<xsl:call-template name="getRemainingTD"><xsl:with-param name="i" select="$i+1"/><xsl:with-param name="maxSteps" select="$maxSteps"/></xsl:call-template>
	</xsl:if> 
	</xsl:template>
	
	<xsl:template match="stepSummaries">
	<br/>
	<h2>Summary Plot:</h2>
	<div id="generateGraph"></div>
	<br/>
	<h2>Steps:</h2>
	<xsl:param name="count" select="count(//suite/stepSummaries/steps)"/>
	<xsl:variable name="maxSteps"><xsl:call-template name="getStepCount"/></xsl:variable>
	<table border="1" style="border-collapse:collapse;">
	<tr align="center" height="27px"><td rowspan="2">Steps</td><td colspan="{$count}">Time taken</td></tr>
	<tr align="center" height="27px">
	<xsl:for-each select="../scriptSummaries/summary">
		<td>Load: <xsl:value-of select="LOAD" /></td>
	</xsl:for-each>
	</tr>
	<tr>
		<xsl:for-each select="steps">
		<xsl:sort select="count(step)"/>
		<xsl:if test="position()=last()">
				<td>
					<table id="0">
					<xsl:for-each select="step">
						<xsl:param name="cn" select="type|MESSAGETYPE" />
						<xsl:param name="debugInfo" select="debugInfo|DEBUGINFO" />
							<tr><td style="white-space: nowrap;"><div class="{$cn}"><a class="{$cn}" href="/_s_/dyn/Log_highlight?href={$debugInfo}#selected"
								title="{$debugInfo}">
								<xsl:value-of disable-output-escaping="yes" select="message|MESSAGE" />
							</a></div></td></tr>
					</xsl:for-each>
					</table>
				</td>
				</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="steps">
			<xsl:param name="stepsIndex" select="position()" />
			
			<td>
			<table id="{position()}">
			<xsl:for-each select="step">
			<xsl:param name="ix" select="position()" />
			<xsl:param name="time" select="MESSAGETIMESTAMP"/>
			<xsl:param name="fixedTime" select="util:fixMillis($time)"/>
			<xsl:param name="cn2" select="type|MESSAGETYPE" />
			<xsl:param name="debugInfo2" select="debugInfo|DEBUGINFO" />
					<tr><td style="white-space: nowrap;">
					<xsl:choose>
						<xsl:when test="$ix=1">
							<div class="{$cn2}"><a class="{$cn2}" href="/_s_/dyn/Log_highlight?href={$debugInfo2}#selected"
								title="{$debugInfo2}">110 ms</a></div>
						</xsl:when>
						<xsl:otherwise>
							<xsl:param name="prevTime" select="../step[$ix - 1]/MESSAGETIMESTAMP" />
							<xsl:param name="fixedPrevTime" select="util:fixMillis($prevTime)"/>
							<div class="{$cn2}"><a class="{$cn2}" href="/_s_/dyn/Log_highlight?href={$debugInfo2}#selected"
								title="{$debugInfo2}"><xsl:value-of select="util:timeDifference($fixedTime,$fixedPrevTime)" /> ms</a></div>
						</xsl:otherwise>
					</xsl:choose>
					</td></tr>
			</xsl:for-each>
			<xsl:param name="i" select="count(step)"/>
			<xsl:if test="$i &lt;= $maxSteps">
				<xsl:call-template name="getRemainingTD"> 
					<xsl:with-param name="i"> 
						<xsl:value-of select="$i + 1"/> 
					</xsl:with-param> 
					<xsl:with-param name="maxSteps"> 
						<xsl:value-of select="$maxSteps"/> 
					</xsl:with-param> 
				</xsl:call-template>
			</xsl:if>
			</table>
			</td>
		</xsl:for-each>
		</tr></table>
		<script type="text/javascript">
				<![CDATA[
				var executionCount = $('runs').value;
				var stepCount = $('steps').value;
				
				var strXML = ""; 
				
				var graph = getHeader();
				var categories = getCategories(executionCount);
				var dataset = getDataset(executionCount, stepCount);
								
				strXML += graph + cleanString(categories) + cleanString(dataset.toString()) + "</graph>";
				renderGraph(strXML);
				
				function _isIE() {return this.navigator.appName == "Microsoft Internet Explorer";}
				
				function $(id) {
					return document.getElementById(id);
				}
				
				function cleanString(str) {
					return str.replace(/\r/g, '').replace(/\n/g, '').replace(/,undefined|undefined/g,'');
				}
				
				function renderGraph(strXML){
					var chart = new FusionCharts("/_s_/spr/charts/swf/FCF_StackedArea2D.swf", "chartId", "600", "300");
					chart.setDataXML(strXML);
					chart.render("generateGraph");
				}
				
				function getHeader(){
					return "<graph caption=\'Load test summary\'  xAxisName=\'Loads\' yAxisName=\'Time (ms)\' animation='0' showValues=\'0\'" + 
						   " numVDivLines=\'10\' showAlternateVGridColor=\'1\' AlternateVGridColor=\'e1f5ff\' divLineColor=\'e1f5ff\' vdivLineColor=\'e1f5ff\'" +   
						   " bgColor=\'E9E9E9\' canvasBorderThickness=\'0\' decimalPrecision=\'0\'>";
				}
				
				function getCategories(runs){
					var str = "<categories>";
					for(var i=1; i<=runs; i++){
						str += "<category name=\'" + $('load-' + i).innerHTML + "\'/>"; 
					}
					str += "</categories>";
					return str;
				}
				
				function getDataset(runs, steps){
					var FC_ColorCounter=0;
					var arr_FCColors= new Array("1941A5" , "AFD8F8", "F6BD0F", "8BBA00", "A66EDD", "F984A1", "CCCC00", "999999", "0099CC", "FF0000", "006F00", "0099FF", "FF66CC", "669966", "7C7CB4", "FF9933", "9900FF", "99FFCC", "CCCCFF", "669900");
					
					var dataset = new Array();
					var headerTable = $("0");
				
					for(var i=0; i<steps; i++){
						dataset[i] += "<dataset seriesName=\'" + headerTable.rows[i].cells[0].textContent + "\' color=\'"+ arr_FCColors[++FC_ColorCounter % arr_FCColors.length] + "\'>";
						for(var j=1; j<=runs; j++){
							var table = $(j);
							var rows = table.rows;
							var cellContent = _isIE() ? rows[i].cells[0].innerText.split(" ")[0] : rows[i].cells[0].textContent.split(" ")[0];
							dataset[i] += "<set value=\'"+ cellContent +"\'/>";
						}
					dataset[i] += "</dataset>";
					}
					return dataset;
				}
				]]>
		</script>
	</xsl:template>
	
	</xsl:stylesheet>