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
					#navbar {padding:2px; border:0px;}
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
		<xsl:param name="timeTaken" select="timeTaken|TIMETAKEN" />
		
		<xsl:if test="position() = 1">		
				
		</xsl:if>
		
		<xsl:choose>
		<xsl:when test="count(/suite/suiteSummary)=1">
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
							<td>Time Taken </td>
							<td>
								<xsl:value-of select="util:prettyTime($timeTaken)" />
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
		</xsl:when>
		<xsl:otherwise>
		<table class="suite_summary">
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
					<xsl:value-of select="timeTaken|TIMETAKEN" />
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
		
		
	</xsl:template>

	<xsl:template match="scriptSummaries">
		<h2>
			Scripts: 
		</h2>
		<table class="scriptSummaries" id="scriptSummaries">
			<tr>
				<!-- <td>Index</td> -->
				<td>Test</td>
				<td>Total Steps</td>
				<td>Failures</td>
				<td>Errors</td>
				<td>Success Rate</td>
				<td>Time Taken (ms)</td>
				<td>Node</td>
				<td>Load</td>
				<td>Suite Report Id</td>
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
				<tr id='status-{position()}' class="{$className}">
				<xsl:param name="scriptargs" select="scriptargs|SCRIPTARGS"/>
					<!-- <td><xsl:value-of select="position()"/></td> -->
					<td id="{$suiteId}">
						<xsl:choose>
							<xsl:when test="$useDBURL = 'true'">
								<xsl:value-of select="scriptName|SCRIPTNAME" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="scriptName|SCRIPTNAME" />
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="$scriptargs != 'null'">
							<br/><div align="left"><xsl:value-of select="scriptargs|SCRIPTARGS" /></div>
						</xsl:if>
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
					<td id="timetaken-{position()}">
						<xsl:value-of select="timeTaken|TIMETAKEN" />
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
					
					
				</tr>
			</xsl:for-each>

		</table>
		<script type="text/javascript">
		<![CDATA[
		if (window.location.search.indexOf('o=list')!=-1 && (document.getElementById('scriptSummaries').rows.length == 2)) {
			var getTable = document.getElementById('scriptSummaries');
			var links = getTable.getElementsByTagName('a');
			window.location.href = (links[0].href.indexOf('DBReports_scriptReport')!=-1) ? links[0].href : '';
		}
		]]>
		</script>

	</xsl:template>

	<xsl:template match="testCaseSummaries">
		
			<script type="text/javascript">
				<![CDATA[
				
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
					return "<graph animation='0' showNames='0' showValues='0' showShadow='0' caption='Scripts runtime' xAxisName='Script name' yAxisName='"+ yAxisDisplay +"'>";
				
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
					return $_("timetaken-"+counter).innerHTML;
				}
				function getTotalSteps(counter){
					return $_("totalsteps-"+counter).innerHTML;
				}
				function getErrorsCount(counter){
					return $_("errors-"+counter).innerHTML;
				}
				function getFailuresCount(counter){
					return $_("failures-"+counter).innerHTML;
				}
				function getStatus(counter){
					return $_("status-"+counter).className;
				}
				function getBarColor(counter){
					return ( hasClass($_("status-"+counter),"SUCCESS") ? "00FF00" : "FF0000" );
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
					var argXML = getHeader('Run time(ms)');
					argXML += getXMLDataPoints();
					argXML += getFooter();
					
					 myChart = new FusionCharts( "/_s_/spr/charts/swf/FCF_Column3D.swf","myChartId", "1200", "300");
	      			 myChart.setDataXML(argXML,"xml");
	     	 		 myChart.render(containerDiv);
				
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
					
					var argXML = getXmlForCompare(graphObj,allIds,'Run time(ms)','timeTaken');
					
					 myChart = new FusionCharts( "/_s_/spr/charts/swf/FCF_MSLine.swf", "myChartId", "1200", "500");
	      			 myChart.setDataXML(argXML,"xml");
	     	 		 myChart.render("chartContainer");
	     	 		 
	     	 		 var radioSpan = $_("radio_span");
					 radioSpan.innerHTML += '<input type="radio" name="selectGraph" value="timeTaken" onclick="changeGraph(this.value)" checked="checked">Time taken</input><input type="radio" name="selectGraph" value="totalSteps" onclick="changeGraph(this.value)">Total steps</input><input type="radio" name="selectGraph" value="failuresCount" onclick="changeGraph(this.value)">Failures count</input><input type="radio" name="selectGraph" value="errorsCount" onclick="changeGraph(this.value)">Errors count</input> ';
							
				}
				
				function changeGraph(value){
					//alert(graphObj);
					var argXML = getXmlForCompare(graphObj,allIds,value,value);
					
					 myChart = new FusionCharts( "/_s_/spr/charts/swf/FCF_MSLine.swf", "myChartId", "1200", "300");
	      			 myChart.setDataXML(argXML,"xml");
	     	 		 myChart.render("chartContainer");
	     	 		
					
				}
				
				]]>
		</script>
	</xsl:template>
	<xsl:template match="suiteInfo"></xsl:template>
</xsl:stylesheet>