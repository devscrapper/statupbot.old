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

					table.scriptSummaries{background-color:white;width:100%;border-top:1px solid gray;border-right:1px solid gray;border-spacing:0px;border-collapse:collapse;}
					table.scriptSummaries td{border-bottom:1px solid gray;border-left:1px solid gray;padding:5px;text-align:right;vertical-align:top;}
					div.scriptargs {color:#eee;font-size:9pt;padding:5px 0px 3px 0px;}
					td a.SCRIPT{float:left;}
					tr.FAILURE{background-color:red;color:white;}
					tr.SUCCESS{background-color:green;color:white;}
					tr.RUNNING{background-color:orange;color:black;}
					tr.null{background-color:orange;color:black;}
					tr.null a{color:black;}
					a{color:white;}
					tr.RUNNING a {color:black;}

					table.suite_summary {border:1px solid orange; margin-bottom:30px;background-color:#fff;width:600px;}
					table.suite_summary td {vertical-align:top;padding:3px;text-align:left;}
					table.suite_summary_part {border:0px;}
					table.suite_summary_part *{border:0px;spacing:0px;}
					
					body *{font-family:verdana;font-size:10pt;}
					body {margin:10px; background-color:lightyellow;
					
					#navbar a{color: blue;}
					#navbar {padding:2px; border:0px;}
</style>	
				<script language="JavaScript" src="/_s_/spr/charts/JSClass/FusionCharts.js"></script>
				
			</head>

			<body onunload="onUnload()" onload="onLoad()">
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
		<xsl:param name="timeTaken" select="timeTaken|TIMETAKEN" />
		<xsl:if test="position() = 1">	
		<script type="text/javascript">var suiteReportID = '<xsl:value-of select="suiteReportId|SUITEREPORTID"/>'</script>
		<xsl:choose>
			<xsl:when test="$useDBURL = 'true'">
				<div id='navbar' style='height:25px'> 
					<a href='/_s_/dyn/pro/DBReports' style="color:black">Root</a> |
					<a href='/_s_/dyn/pro/DBReports_suiteReport?id={$suiteId}' style="color:black"><b>Suite Report</b></a> |
					<a href='/_s_/dyn/pro/DBReports_suiteReport?id={$suiteId}&amp;type=excel&amp;download=true' style='float:right;'>
						<img border="0" src="/_s_/spr/images/excel.png" title="Export to Excel" width="25" height="25" style="margin-right:10px;"/>
					</a>
					<xsl:choose>
						<xsl:when test="starts-with($suiteId, 'LOAD_')">
							<a href='/_s_/dyn/pro/DBReports_reconciledReport?id={$suiteId}' style="color:black">Load Test Summary</a> 
						</xsl:when>
						<xsl:otherwise>
							<a href='/_s_/dyn/pro/DBReports_testCaseReport?id={$suiteId}' style="color:black">Test Cases Report</a>
							<xsl:if test="(contains(SUITENAME, '.csv')) and not(contains(SUITENAME, '.dd.csv')) and not(contains(SUITENAME, '.s.csv'))">
							| <a href='/_s_/dyn/pro/DBReports_csvTestCasesReport?id={$suiteId}' style="color:black">Test Cases Report Summary</a>
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div id='navbar'><a href='index.html' style="color:black">Script Report</a> | <a href='testcase_summary.html' style="color:black">Test Cases Report</a> | <a href="retry/index.html" style="color:black">Show retry logs</a></div>
			</xsl:otherwise>
		</xsl:choose>	

		<div id="chartContainer" style="display:none;background-color:white;min-width:1310px;border:1px solid #999;padding:5px;margin-top:-1;"></div>		
		<br/>
		<span id="radio_span"></span>
		</xsl:if>
		
		<xsl:choose>
		<xsl:when test="count(/suite/suiteSummary)=1">
		<h2>
			Suite Name:
			<a style="color:black" href="/_s_/dyn/Log_highlight?href={$suitePath}">
				<xsl:value-of select="suiteName|SUITENAME" />
			</a>
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
							<td>Time Taken </td>
							<td>
								<xsl:value-of select="util:prettyTimeMoreThan24Hours($timeTaken)" /><br/>
							</td>
						</tr>
					</table>
				</td>
				<td>
					<table class="suite_summary_part">
						<tr>
							<td>Total scripts run</td>
							<td>
								<xsl:value-of select="totalCount|TOTALCOUNT" />
							</td>
						</tr>
						<tr>
							<td>Scripts passed</td>
							<td>
								<xsl:value-of select="passedCount|PASSEDCOUNT" />
							</td>
						</tr>
						<tr>
							<td>Scripts failed</td>
							<td>
								<xsl:value-of select="failedCount|FAILEDCOUNT" />
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
					<a style="color:blue;text-decoration:underline" href="#" onclick="showHide('suiteInfo');return false;">Suite Info</a><br/>
					<div id="suiteInfo" style="display:none;">
						<pre>
						<xsl:value-of select="suiteInfo|SUITEINFO" />
						</pre>
					</div>
				</td>
			</tr>
			<tr>
			<td colspan="2" style="padding:7px;">
				<a style="color:blue;text-decoration:underline" href="#" onclick="showHide('nodesInfo');return false;">Nodes Info</a><br/>
				<div id="nodesInfo" style="display:none;">
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
		</xsl:when>
		<xsl:otherwise>
		<table class="suite_summary" style="width:800px;">
			<tr>
				<td>
					<xsl:value-of select="browserType|BROWSERTYPE" />
				</td>
				<td>
					<xsl:value-of select="util:humanTime($startTime)" />
				</td>
				<td>
					<xsl:value-of select="util:humanTime($endTime)" />
				</td>
				<td>
					<xsl:value-of select="util:prettyTimeMoreThan24Hours($timeTaken)" />
				</td>
				<td>
					<xsl:value-of select="totalCount|TOTALCOUNT" />
				</td>
				<td>
					<xsl:value-of select="passedCount|PASSEDCOUNT" />
				</td>
				<td>
					<xsl:value-of select="failedCount|FAILEDCOUNT" />
				</td>
				<td>
					<xsl:value-of select="status|STATUS" />
				</td>
				<td>
				<a style="color:blue;text-decoration:underline" href="#" onclick="showHide('suiteInfo_{position()}');return false;">Suite Info</a><br/>
				<div id="suiteInfo_{position()}" style="display:none;">
					<pre>
					<xsl:value-of select="suiteInfo|SUITEINFO" />
					</pre>
				</div>
				</td>
				<td>
					<a style="color:blue;text-decoration:underline" href="#" onclick="showHide('nodesInfo_{position()}');return false;">Nodes Info</a><br/>
					<div id="nodesInfo_{position()}" style="display:none;">
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
		</xsl:otherwise>
		</xsl:choose>
		<script>
		<![CDATA[
		function getCount(elId) {
			var el = $_(elId);
			if (!el) return 0;
			var t = el.innerHTML;
			return isNaN(t) ? 0 : parseInt(t);
		}
				
		function refreshPage(){
			return;
			var el = document.getElementById("status");
			if (el && (el.className == "SUCCESS" || el.className == "FAILURE")){
				return;
			}
			window.setTimeout("window.location.reload();", 2000);
		}
		refreshPage();
		function showHide(s){var el=document.getElementById(s);el.style.display = (el.style.display == 'block') ? 'none' : 'block'; }; 
		function getCheckedScripts(){
			var elements = document.getElementsByTagName("INPUT");
			var ids=[];
			for(var itr=0;itr<elements.length;itr++){
				var element = elements[itr];
				if(element.type == "checkbox" && element.checked && element.id != 'checkAllCB'){
					ids.push(element.value);
				}
			}
			return ids;
		}
		function compareUI() {
			var ids = getCheckedScripts();
			if(ids.length < 2){
				alert("Please select two or more scripts to compare");
				return;
			}
			location.href = "DBReports_scriptUIComparisonReport?id="+ids[0]+"&compareIds="+ids.slice(1).join(',');
		}
		function checkAll(isChecked){
			var els = document.getElementsByTagName("INPUT");
			for (var i=0; i<els.length; i++) {
				var el = els[i];
				if (el.type == "checkbox") {
					el.checked = false;
					if(el.parentNode.parentNode.style.display != "none"){
						el.checked = isChecked;
					}
				}
			}
		}
		function onCheckClick(me){
			var el = document.getElementById("checkAllCB");
			if (el.checked) {
				el.checked = false;
			}
		}
		]]>
		</script>
		
	</xsl:template>

	<xsl:template match="scriptSummaries">
		<h2>
			Scripts: 
		</h2>
		<xsl:choose>
			<xsl:when test="$useDBURL = 'true'">
				<td><input type="button" onclick="compareUI()" value="Compare Screenshots" style="margin-right:8px"/></td>
				<td><input type="button" onclick="compareLogs()" value="Compare Logs" style="margin-right:8px"/></td>
			</xsl:when>
		</xsl:choose>
		<td><input type="button" id="showHideFailButton" onclick="showHideFailure(this)" value="Show Failed" style="margin-right:8px"/></td>
		<table class="scriptSummaries" id="scriptSummaries">
			<tr>
				<xsl:choose>
					<xsl:when test="$useDBURL = 'true'">
						<td id="CheckAll"><input id="checkAllCB" type="checkbox" value="" onclick="checkAll(this.checked)"/></td>
					</xsl:when>
				</xsl:choose>
				
				<!-- <td>Index</td> -->
				<td>Test</td>
				<td>Start Url</td>
				<td>Total Steps</td>
				<td>Failures</td>
				<td>Errors</td>
				<td>Success Rate</td>
				<td width="90px;">Time Taken</td>
				<td>Node</td>
				<td>Load</td>
				<td>Suite Report Id</td>
				<td width="95px;"></td>
			</tr>

			<xsl:for-each select="summary">
				<!-- Uncomment below line to sort by start time (ordered as in suite file) -->
				<!-- 
				<xsl:sort select="substring-after(SCRIPTREPORTID, '__')" />
				-->
				 
				<xsl:param name="className" select="status|STATUS" />
				<xsl:param name="reportId" select="reportId|SCRIPTREPORTID" />
				<xsl:param name="steps" select="steps|TOTALSTEPS" />
				<xsl:param name="failures" select="failures|FAILURES" />
				<xsl:param name="errors" select="errors|ERRORS" />
				<xsl:param name="load" select="load|LOAD" />
				<xsl:param name="suiteId" select="suiteReportId|SUITEREPORTID" />
				<xsl:param name="starturl" select="starturl|STARTURL"/>
				<xsl:param name="scriptargs" select="scriptargs|SCRIPTARGS"/>
								
				<tr id='status-{position()}' class="{$className}">
					<xsl:choose>
					<xsl:when test="$useDBURL = 'true'">
						<td><input name="cb_{position()}" type="checkbox" value="{$reportId}" onclick="onCheckClick(this)"/></td>
					</xsl:when>
					</xsl:choose>
					<!-- <td><xsl:value-of select="position()"/></td> -->
					<td id="{$suiteId}">
						<xsl:choose>
							<xsl:when test="$useDBURL = 'true'">
								<a id="script-{position()}" class="SCRIPT" href="/_s_/dyn/pro/DBReports_scriptReport?id={$reportId}"><xsl:value-of select="scriptName|SCRIPTNAME" /></a>
							</xsl:when>
							<xsl:otherwise>
								<a id="script-{position()}" class="SCRIPT" href="{$reportId}.html"><xsl:value-of select="scriptName|SCRIPTNAME" /></a>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="$scriptargs != 'null'">
							<br/><div class="scriptargs" align="left"><xsl:value-of select="scriptargs|SCRIPTARGS" /></div>
						</xsl:if>
					</td>
					<td id="starturl-{position()}">
						<div style="width:100px;overflow:hidden;text-overflow:ellipsis;border:0" title="{$starturl}">
							<xsl:copy-of select="$starturl" />
						</div>
					</td>
					<td id="totalsteps-{position()}">
						<xsl:value-of select="steps|TOTALSTEPS" />
					</td>
					<td id="failures-{position()}">
						<xsl:value-of select="failures|FAILURES" />
					</td>
					<td id="errors-{position()}">
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
						<xsl:value-of select="util:prettyTimeMoreThan24Hours(timeTaken|TIMETAKEN)" />
						<span style="display:none" id="timetaken-{position()}"><xsl:value-of select="timeTaken|TIMETAKEN" /></span>
					</td>
					<td>
						<xsl:value-of select="nodeHost|NODEHOST" />:<xsl:value-of select="nodePort|NODEPORT" />
					</td>
					<td>
						<xsl:value-of select="load|LOAD" />
					</td>
					<td>
						<xsl:value-of select="SUITEREPORTID" />
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
		<script type="text/javascript">
		<![CDATA[
		if (window.location.search.indexOf('o=list')!=-1 && (document.getElementById('scriptSummaries').rows.length == 2)) {
			var getTable = document.getElementById('scriptSummaries');
			var links = getTable.getElementsByTagName('a');
			var redirect = (links[0].href.indexOf('DBReports_scriptReport')!=-1) ? links[0].href : '';
			window.location.replace(redirect);
			//window.location.href = (links[0].href.indexOf('DBReports_scriptReport')!=-1) ? links[0].href : '';
		}
		]]>
		</script>

	</xsl:template>

	<xsl:template match="testCaseSummaries">
		
			<script type="text/javascript">
				<![CDATA[
				var showFailedOnly;
				var cookieHashMap = {};
				function $_(id) {
					return document.getElementById(id);
				}
				function hasClass(ele,cls) {
					return ele.className.match(new RegExp('(\\s|^)'+cls+'(\\s|$)'));
				}
				
				function getRandomNumberWithin(limit){
					return Math.round(Math.random() * limit);
				}
				var colors = ['0000FF', 'FF00FF', 'FFA500', '800000', '0000A0', '808000', '808080', 'A52A2A', '00FFFF'];
				var colorIx = 0;
				function getRandomColor(){
					return colors[(colorIx++)%(colors.length)];
				    var possibilities = '0123456789ABCDEF'.split('');
				    var color = '';
				    for (var itr=0; itr<6 ; itr++ ) {
				        color += possibilities[getRandomNumberWithin(15)];
				    }
				    return color;
				};
	
					
				function getHeader(yAxisDisplay){
					return "<graph canvasBorderThickness='0' hovercapbg='FFFFDD' animation='0' showNames='0' showValues='0' showShadow='0' showColumnShadow='0' caption=' ' xAxisName='Script Name' yAxisName='"+ yAxisDisplay +"'>";
				
				}
				function ifNotCounterExists(counter){
					return $_("script-"+counter) == null;
				}
				function getScriptName(counter){
					return $_("script-"+counter).innerHTML;
				}
				function getReportId(counter){
					return $_("script-"+counter).parentNode.id;
				}
				function getTimeTaken(counter){
					return getCount("timetaken-"+counter);
				}
				function getTotalSteps(counter){
					return getCount("totalsteps-"+counter);
				}
				function getErrorsCount(counter){
					return getCount("errors-"+counter);
				}
				function getFailuresCount(counter){
					return getCount("failures-"+counter);
				}
				function getStatus(counter){
					return $_("status-"+counter).className;
				}
				function getBarColor(counter){
					return ( hasClass($_("status-"+counter),"SUCCESS") ? "008000" : "FF0000" );
				}
				function getLinkHref(counter){
					return $_("script-"+counter).href;
				}
				function getXMLDataPoints(){
					var dataxml = "";
					for(var counter=1;;counter++){
					 if(ifNotCounterExists(counter)) break;
					 	dataxml += "<set name='" + getScriptName(counter) 
					 			+ "' value='" + (getTimeTaken(counter)/1000) + "' color='" + getBarColor(counter) +"' link='"+ getLinkHref(counter) +"' />";	
					}
					return dataxml;
				}
				function getXMLDataPointsForCompare(graphObj,yAxis){
					var dataxml = "";
					for(line in graphObj){
						dataxml += "<dataset seriesName='"+ line +"' color='"+ getRandomColor() +"'>";
						for(point in graphObj[line]){
							if(graphObj[line][point] != null){
								dataxml += "<set name='"+ point +"' value='"+ graphObj[line][point][yAxis] +"' />";
							} else {
								dataxml += "<set name='"+ point +"' value='0' />";
							}
						}
						dataxml += "</dataset>";
					}
					return dataxml;
				}

				function getFooter(){
					return "</graph>";
				}
				
				function getCategoriesForCompare(line){
					var str = "<categories>";
					for(point in line){
						str += "<category name='" + point + "'/>"; 
					}
					str += "</categories>";
					return str;
				}
				     	 		 
     	 		
     	 		function nullifySuitesWithoutScript(graphObj,scriptName){ //to nullify suites without certain scripts that are present in other compared suites
     	 			for(each in graphObj){
     	 				if(typeof graphObj[each][scriptName] == "undefined"){
     	 					graphObj[each][scriptName] = null;
     	 				}
     	 			}
     	 		}
				
				function getScriptObject(counter){
					var scriptObj = {};
			 		scriptObj["status"] = getStatus(counter);
			 		scriptObj["timeTaken"] = getTimeTaken(counter);
			 		scriptObj["totalSteps"] = getTotalSteps(counter);
			 		scriptObj["errorsCount"] = getErrorsCount(counter);
			 		scriptObj["failuresCount"] = getFailuresCount(counter);
				 	return scriptObj;	
				}
				
				var queryStringObject = function () { //returns URL QueryString parameters as a JSON object
				  var query_string = {};
				  var query = window.location.search.substring(1);
				  var vars = query.split("&");
				  for (var i=0;i<vars.length;i++) {
				    var pair = vars[i].split("=");
				        query_string[pair[0]] = pair[1];
				  } 
				    return query_string;
				}();


				function getGraphObject(allIds){
					var graphObj = {};
					for(var each=0;each<allIds.length;each++) graphObj[allIds[each]] = {};
					
					var current_script_name = "";
					
					for(var counter=1;;counter++){
					 	if(ifNotCounterExists(counter)) break;
				 		if( (current_script_name != "") || (current_script_name != getScriptName(counter)) ){ //first script for same name as previous script
				 			nullifySuitesWithoutScript(graphObj,getScriptName(counter));	
				 		}
			 			current_script_name = getScriptName(counter);
			 			var report_id = getReportId(counter);
				 		graphObj[report_id][current_script_name] = getScriptObject(counter);	
			 						 		
					}
					return graphObj;
				}
				
				var myChart ={};
				
				function renderSingleBarChart(containerDiv){
					var argXML = getHeader('Run Time (sec)');
					argXML += getXMLDataPoints();
					argXML += getFooter();
					
					 myChart = new FusionCharts( "/_s_/spr/charts/swf/FCF_Column2D.swf","myChartId", "1300", "350");
	      			 myChart.setDataXML(argXML,"xml");
	     	 		 myChart.render(containerDiv);
					$_(containerDiv).style.display = "block";
				}
				
				function getXmlForCompare(graphObj,allIds,yAxisDisplay,yAxisField){
					var argXML = getHeader(yAxisDisplay);
					argXML += getCategoriesForCompare(graphObj[allIds[0]]);
					argXML += getXMLDataPointsForCompare(graphObj,yAxisField);
					argXML += getFooter();
					//alert(argXML);
					return argXML;
				
				}
				
				
				if(!queryStringObject.compareIds){
					//place single suite bar chart here
					renderSingleBarChart("chartContainer");
					
				} else {
					//Comparing suites
					var allIds = queryStringObject.compareIds.split(',');
					allIds.push(queryStringObject.id); //Getting all suite Ids to compare
					
					var graphObj = getGraphObject(allIds);
					//alert(JSON.stringify(graphObj));
					
					var argXML = getXmlForCompare(graphObj,allIds,'timeTaken (ms)','timeTaken');
					
					 myChart = new FusionCharts( "/_s_/spr/charts/swf/FCF_MSLine.swf", "myChartId", "1300", "400");
	      			 myChart.setDataXML(argXML,"xml");
	     	 		 myChart.render("chartContainer");
	     	 		 $_("chartContainer").style.display = "block";
	     	 		 var radioSpan = $_("radio_span");
					 radioSpan.innerHTML += '<input type="radio" name="selectGraph" value="timeTaken" onclick="changeGraph(this.value)" checked="checked">Time taken</input><input type="radio" name="selectGraph" value="totalSteps" onclick="changeGraph(this.value)">Total steps</input><input type="radio" name="selectGraph" value="failuresCount" onclick="changeGraph(this.value)">Failures count</input><input type="radio" name="selectGraph" value="errorsCount" onclick="changeGraph(this.value)">Errors count</input> </br></br>';
							
				}
				function isMainCheckBoxChecked () {
					var ids=[];
					var els = document.getElementsByTagName('input');
					for(var i = 0; i<els.length; i++){
						if(els[i].type == "checkbox") ids.push(els[i]);
					}
					return ids[0].checked;
				}
				function compareLogs(){
					var ids = getCheckedLogs();
					if(isMainCheckBoxChecked()) {
						ids.shift();	
					}
					if(ids.length == 0){
						alert("Please select two scripts to compare logs")
						return;
					}
					if(ids.length > 2){
						alert("Please select two scripts to compare logs")
						return;
					}
					if(ids.length == 1){
						location.href = "DBReports_compare?logFile1="+ids[0];			
						return;
					}
					location.href = "DBReports_compare?logFile1="+ids[0]+"&logFile2="+ids[1];
				}
				
				function showHideFailure(showHideFailureButton){
					var scriptSummaryTable = document.getElementById("scriptSummaries");
					var scriptRows = scriptSummaryTable.getElementsByTagName("TR");
					if(showHideFailureButton.value == "Show Failed"){
						showHideFailureButton.value = "Show All";
						setCookie();
						for(var i=1; i<scriptRows.length; i++){
							if(scriptRows[i].className == "SUCCESS"){
								scriptRows[i].style.display = "none";
							}
						}
					}
					else{
						showHideFailureButton.value = "Show Failed";
						resetCookie();
						for(var i=1; i<scriptRows.length; i++){
							scriptRows[i].style.display = "table-row";
						}
					}
					if(!isAllCurrentCheckboxChecked()){
						document.getElementById("checkAllCB").checked = false;
					}
				}
				
				function createCookie(name,value,days){
					showFailedOnly = true;
					if (days) {
						var date = new Date();
						date.setTime(date.getTime()+(days*24*60*60*1000));
						var expires = "; expires="+date.toGMTString();
					}
					else var expires = "";
					document.cookie = name+"="+value+expires+"; path=/";
				}
				
				function readCookie(name){
					var nameEQ = name + "=";
					var ca = document.cookie.split(';');
					for(var i=0;i < ca.length;i++){
						var c = ca[i];
						c = c.replace(/[,][}]$/,'}');
						while (c.charAt(0)==' ') c = c.substring(1,c.length);
						if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
					}
					return null;
				}
				
				function setCookie(){
					showFailedOnly = true;
				}
				
				function resetCookie(){
					showFailedOnly = false;
				}
				
				function onLoad(){
					var cookieValue = readCookie("showFailedOnly");
					if(cookieValue){
						cookieHashMap = eval("("+cookieValue+")");
						showFailedOnly=cookieHashMap[suiteReportID];
						if (showFailedOnly){
							showHideFailure(document.getElementById("showHideFailButton"));
						}
						delete cookieHashMap[suiteReportID];
						
					}
				}
				
				function onUnload(){
					var count = 0;
					var firstElement;
					for(firstElement in cookieHashMap){
						break;
					}
					for(var j in cookieHashMap){
						count++;
					}
					if(count == 10){
						delete cookieHashMap[firstElement];
					}
					cookieHashMap[suiteReportID] = showFailedOnly;
					var cookieValue = getJSON(cookieHashMap);
					createCookie("showFailedOnly", cookieValue, 1);
				}
				
				function getJSON(o) {
					var s = "{";
					for (var i in o) {
						s += "'" + i + "':" + o[i] + ","
					}
					s += "}";
					return s;
				}
				
				function isAllCurrentCheckboxChecked(){
					var els = document.getElementsByTagName("INPUT");
					for (var i=0; i<els.length; i++) {
						var el = els[i];
						if (el.type == "checkbox") {
							if(el.parentNode.parentNode.style.display != "none" && !el.checked){
								return false;
							}
						}
					}
					return true;
				}
				
				function getCheckedLogs(){
					var elements = document.getElementsByTagName("*");
					var ids=[];
					for(var itr=0;itr<elements.length;itr++){
						var element = elements[itr];
						if(element.type == "checkbox" && element.checked){
							ids.push(element.value);
						}
					}
					return ids;
				}
				
				function changeGraph(value){
					//alert(graphObj);
					var argXML = getXmlForCompare(graphObj,allIds,value,value);
					
					 myChart = new FusionCharts( "/_s_/spr/charts/swf/FCF_MSLine.swf", "myChartId", "1300", "400");
	      			 myChart.setDataXML(argXML,"xml");
	     	 		 myChart.render("chartContainer");
	     	 		 $_("chartContainer").style.display = "block";
				}
				

				
				]]>
		</script>
	</xsl:template>
	<xsl:template match="suiteInfo"></xsl:template>
</xsl:stylesheet>