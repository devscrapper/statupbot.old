<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="in.co.sahi.util.XSLUtils"
	version="1.0">

	<xsl:output method="html" indent="yes" />
	<xsl:param name="useDBURL" select="false" />
	<xsl:template match="/">
		<html>
			<head>			
				<script language="JavaScript" src="/_s_/spr/charts/JSClass/FusionCharts.js"></script>

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
					
					div.graphUnit {
					    background-color: #ffffff;
					    color: #000000;
					    border: 1px solid #ccc;
						margin: 10px 0px;
						padding: 10px;
					}
					.limitSpan{
						display : block;
						width: 100%;
						text-align: center;
					}
				</style>
				<script language="JavaScript" src="/_s_/spr/charts/JSClass/FusionCharts.js"></script>
			</head>

			<body>
				<div class="graphDiv" id="graphDiv">
			<h2>
			Suite: <xsl:value-of select="//scriptSummaries/summary/SUITENAME" />
			</h2>				
					<div id="stepsGraph" class="graphUnit">
					<div  id="placeHolder-Line"></div>
					<span class="limitSpan">Number of steps in graph <input style="width:50px;" type="text" id="changeStepsCount" onkeydown="if(event.keyCode==13)changeStepsLineChart()" value="5"/> <input type="button" value="Update" onClick="changeStepsLineChart()" style="margin-left:5px;"/></span>
					</div>
					<div id="urlsGraph" class="graphUnit">
					<div id="placeHolder-urlLine"></div>
					<span class="limitSpan" id="urlLineLimitBox">Number of URLs in graph <input style="width:50px;" type="text" id="changeURLsCount" onkeydown="if(event.keyCode==13)changeURLsLineChart()" value="5"/> <input type="button" value="Update" onClick="changeURLsLineChart()"  style="margin-left:5px;"/></span>
					</div>
				</div>
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
				<div id='navbar'> <a href='/_s_/dyn/pro/DBReports' style="color:black">Root</a> | <a href='/_s_/dyn/pro/DBReports_suiteReport?id={$suiteId}' style="color:black">Suite Report</a> | <a href='/_s_/dyn/pro/DBReports_reconciledReport?id={$suiteId}' style="color:black"><b>Load Test Summary</b></a></div>
			</xsl:when>
			<xsl:otherwise>
				<div id='navbar'> <a href='/_s_/dyn/Log_viewLogs' style="color:black">Root</a> | <a href='index.htm' style="color:black">Script Report</a> | <a href='results.csv' style="color:black">Load Test Summary</a></div>
			</xsl:otherwise>
		</xsl:choose>
		<h2>
			Scripts <a onclick="el=document.getElementById('scriptSummaries');el.style.display=el.style.display=='none'?'block':'none'" style="cursor:pointer;color:black;font-weight:normal">(Show/Hide)</a>
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
					<xsl:param name="reportId" select="reportId|SCRIPTREPORTID" />
					<xsl:param name="steps" select="steps|TOTALSTEPS" />
					<xsl:param name="failures" select="failures|FAILURES" />
					<xsl:param name="errors" select="errors|ERRORS" />
					<xsl:param name="load" select="load|LOAD" />
				
				<tr class="{$className}">
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
	<h2>Steps:</h2>
	<xsl:param name="count" select="count(//suite/stepSummaries/steps)"/>
	<xsl:variable name="maxSteps"><xsl:call-template name="getStepCount"/></xsl:variable>
	<table class="stepsTable" border="1" style="border-collapse:collapse;background-color:#ffffff">
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
			
			<td style="vertical-align:top">
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
		<div id="harInfo"/>
		<!-- <textarea id="ta"></textarea> -->
		<script type="text/javascript">
				<![CDATA[
		
			function _isIE() {return this.navigator.appName == "Microsoft Internet Explorer";}
			
			function $_(id) {
				return document.getElementById(id);
			}
			
			function cleanString(str) {
				return str.replace(/\r/g, '').replace(/\n/g, '').replace(/,undefined|undefined/g,'');
			}
			
			function replaceWithSpecialChars(str) {
				return str.replace(/&/g, "&amp;").replace(/'/g, '&apos;').replace(/"/g, '&quot;')
						.replace(/</g, "&lt;").replace(/>/, "&gt;");
			}
			
			function isPositiveInteger(n) {
    			return (n >>> 0 === parseFloat(n)) && n>0;
			}
			
			function changeStepsLineChart() {
				var newCount = document.getElementById("changeStepsCount").value;
				if(isPositiveInteger(newCount))
					renderStepsLineChart(stepsArrayG,averageArrayG,loadsArrayG,indicesG,parseInt(newCount));			
			}
			function changeURLsLineChart() {
				var newCount = document.getElementById("changeURLsCount").value;
				if(isPositiveInteger(newCount))
					initiateUrlLineGraph(parseInt(newCount),"placeHolder-urlLine");
			}
//Line chart begins here	
			// numberOfRepeats should match the value of the property dload.number_of_time_subject_execute	
			//var numberOfRepeats=3;
			var isFailedInStep = -1;
			var errorMessage = "";
			var globalScriptReportId;
			var canvasBgColor = "ffffff";
			var canvasBgAlpha = "100";
			var bgAlpha = "100";
			var bgColor = "ffffff";
			
			function getTimeArrayFromTable(table){
				var timeArr = [];
				for (var i = 0, row; row = table.rows[i]; i++) {
				   var cellValue = parseInt(row.innerHTML.split('ms</a>')[0].split('>').pop().trim() );
				   if(isNaN(cellValue)) break;
				   timeArr.push ( cellValue );  
				}
				return timeArr;
			}
			
			function mergeArrays(finalArr,curArr) {
				if(finalArr == undefined) return curArr;
				for(var i=0;i<curArr.length;i++){
					finalArr[i] += curArr[i];
				}
				return finalArr;
			}

			function getAverageDataArray() {
				var numberOfRepeats = guessSubjectRepeatCount();
				var tableCount=1;
				var arr;
				var finalArr = [];
				while(true) {
					if( $_(tableCount) == undefined ) break;
					var curArr = getTimeArrayFromTable($_(tableCount));
					finalArr[parseInt((tableCount-1)/numberOfRepeats)] = mergeArrays(finalArr[parseInt((tableCount-1)/numberOfRepeats)],curArr);
					tableCount++;
				}
				return finalArr;
			}
	
			function guessSubjectRepeatCount() {
				try {
				var cells = document.getElementsByTagName('table')[1].rows[1].cells;
				var loadNames = [];
				var lastLoadName = "";
				var count = 0;
				for(var cellIndex=0; cellIndex < cells.length; cellIndex++){
					var loadName = cells[cellIndex].innerHTML;
					if (lastLoadName == "" || lastLoadName == loadName) {
						count++;
						lastLoadName = loadName;
					} else {
						break;
					}
				}
				return count;		
				} catch (e) {return 3;}	
			}

			function getStepsAndLinksArray(){
				var rows = $_('0').rows;
				var stepsArr = [];
				for(var rowCount=0; rowCount < rows.length; rowCount++){
					var currentAnchor = rows[rowCount].getElementsByTagName('a')[0];
					if(currentAnchor.innerHTML == '<!--SAHI_TESTCASE_FAIL_MARKER-->' ) {
						currentAnchor = rows[rowCount+1].getElementsByTagName('a')[0]
						isFailedInStep = rowCount;
					}
					if(isFailedInStep != -1) {
						var innerHTML = currentAnchor.innerHTML.split("Error:");
						stepsArr.push(innerHTML[0]);
						errorMessage = innerHTML[1];
						break; 
					}					
					stepsArr.push(currentAnchor.innerHTML);
				}
				return stepsArr;
			}

			function getLoadNames() {
				var cells = document.getElementsByTagName('table')[1].rows[1].cells;
				var loadNames = [];
				var lastLoadName = "";
				for(var cellIndex=0; cellIndex < cells.length; cellIndex++){
					var loadName = cells[cellIndex].innerHTML;
					if (lastLoadName != loadName) {
						lastLoadName = loadName;
						loadNames.push(cells[cellIndex].innerHTML);
					}
				}
				return loadNames;
			}

			function removeLastIfFailed(averageArray) {
				if(isFailedInStep == -1) return averageArray;
				for(var index=0; index<averageArray.length; index++){
					averageArray[index].pop();
				}
				return averageArray;
			}

			function makeAverage(inputArr) {
				var outputArray = [];
				for(var j=0;j<inputArr[0].length;j++) {
					outputArray[j] = 0;
					for(var i=0;i<inputArr.length;i++) {
						outputArray[j] +=  inputArr[i][j];
					}
					outputArray[j] = parseInt(outputArray[j]/i);
				}
				return outputArray;
			}

			function returnIndicesAsArray(array,indices) {
				var outArr = [];
				for(var i=0;i<indices.length;i++){
					outArr.push(array[indices[i]]);
				}
				return outArr;
			}

			function returnIndicesAsArray2d(array,indices) {
				var outArr = [];
				for(var i=0;i<array.length;i++){
					outArr.push(returnIndicesAsArray(array[i],indices));
				}
				return outArr;
			}

			function getTopNStepsWithoutWait(indices,stepsArr,n){
				var outArr = [];
				for(var i=0; i<indices.length; i++){
					if(stepsArr[indices[i]].indexOf("_wait")==-1){
						outArr.push(indices[i]);
					}
					if( n == 1 ) break; 
					n--;
				}
				return outArr;
			}
			function getScriptReportIdFromPage(){
				return document.getElementsByClassName('SCRIPT')[0].href.split('id=')[1];
			}
			function stepClick(stepId) {
				if(!globalScriptReportId) globalScriptReportId = getScriptReportIdFromPage();
				location.href = "/_s_/dyn/pro/DBReports_scriptReport?id=" +globalScriptReportId+"&stepId="+stepId;
			}
			
			var gColorCount = 0;
			var colors = ["#e41a1c", "#377eb8", "#4daf4a", "#984ea3", "#ffff33", "#a65628", "#f781bf", "#999999", "#a6cee3", "#1f78b4", "#b2df8a", "#33a02c", "#fb9a99", "#e31a1c", "#fdbf6f", "#ff7f00", "#cab2d6"];	
			
			function getRandomColor() {
				if (gColorCount >= colors.length) gColorCount = 0;
				return colors[gColorCount++];
			    var letters = '0123456789ABCDEF'.split('');
			    var color = '#';
			    for (var i = 0; i < 6; i++ ) {
			        color += letters[Math.round(Math.random() * 15)];
			    }
			    return color;
			}
		
			function getLineHeaderXML() {
				return "<graph yAxisMinValue='1000' hoverCapBgColor='ffffff' caption='PERFORMANCE OF MOST EXPENSIVE STEPS ACROSS DIFFERENT LOADS' yAxisName='TIME TAKEN BY STEP(ms)' xAxisName='LOAD COUNT' canvasBgColor='"+canvasBgColor+"' canvasBgAlpha='"+canvasBgAlpha+"' bgAlpha='"+bgAlpha+"' bgColor='"+bgColor+"' baseFontColor='000000' formatNumberScale='0' hovercapbg='FFECAA' showLegend='1' showNames='1' decimalPrecision='0' showvalues='0' animation='0' rotateNames='0' numdivlines='5' showhovercap='1' showShadow='0' lineThickness='6' anchorSides='10' anchorRadius='6'>";
			}

			function getLineFooterXML(){
				return "</graph>";
			}

			function getLineCategoriesXML(loadsArray){
				var loadCount = loadsArray.length;
				var categoryXML = "<categories>";
				for(var loadIndex=0; loadIndex<loadCount ; loadIndex++){
				
					categoryXML += "<category name='"+loadsArray[loadIndex]+"' showValues='1' hoverText=' "+loadsArray[loadIndex]+" '/>";
				}
				categoryXML += "</categories>";
				return categoryXML;
			}

			function getStepDataXML(stepIndex,loadCount,topIndices,averageArray) {
				
				var dataXML = "";
				for(var loadIndex=0; loadIndex<loadCount ; loadIndex++){
					var averageTime = parseInt(averageArray[loadIndex][stepIndex]);
					if(isNaN(averageTime) || averageTime == undefined || averageTime == null) averageTime = 0;
					dataXML += "<set value='"+averageTime+"' link='JavaScript:stepClick("+parseInt(topIndices[stepIndex]+1)+");'/>";
				}
				return dataXML;
			}

			function getLineDataXML(stepsArray,averageArray,loadsArray,topIndices){
				gColorCount = 0;
				var stepsCount = stepsArray.length;
				var loadCount = loadsArray.length;
				var dataXML = "";
				for(var stepIndex=0; stepIndex<stepsCount ; stepIndex++){
					var stepXML = "<dataset seriesname='Step-"+parseInt(topIndices[stepIndex]+1)+": "+stepsArray[stepIndex]+"' showValue='1' color='"+getRandomColor()+"' showAnchors='1' alpha='100' anchorAlpha='100' lineThickness='3'>";
					stepXML += getStepDataXML(stepIndex,loadCount,topIndices,averageArray);
					stepXML += "</dataset>";
					dataXML += stepXML;
				}
				return dataXML;	
			}
			
			function getLineXML(stepsArray,averageArray,loadsArray,topIndices) {
				return getLineHeaderXML()+getLineCategoriesXML(loadsArray)+getLineDataXML(stepsArray,averageArray,loadsArray,topIndices)+getLineFooterXML();
			}
			
			function renderStepsLineChart(stepsArray,averageArray,loadsArray,indices,count) {
				var topIndices = getTopNStepsWithoutWait(indices,stepsArray,count);
				stepsArray = returnIndicesAsArray(stepsArray,topIndices);
				averageArray = returnIndicesAsArray2d(averageArray,topIndices);	
				
				
				var argXML = getLineXML(stepsArray,averageArray,loadsArray,topIndices);
				var width = document.getElementById("graphDiv").offsetWidth - 45;
				var lineChart = new FusionCharts( "/_s_/spr/charts/swf/FCF_MSLine.swf","placeHolder-Line", width.toString(), "300");
	    	  	lineChart.setDataXML(argXML,"xml");
	     		lineChart.render("placeHolder-Line");
	     	}
	     	function placeGraphsDiv() {
	     		var childNodes = document.body.children;
	     		var graphsDiv = childNodes[0];
	     		var scripts = childNodes[3];
	     		document.body.insertBefore(scripts,graphsDiv);
	     	}
	     	var stepsArrayG = getStepsAndLinksArray();
			var averageArrayG = removeLastIfFailed(getAverageDataArray());
			var first = makeAverage(averageArrayG);
			var len = first.length;
			
			var indicesG = new Array(len);
			for (var i = 0; i < len; ++i) indicesG[i] = i;
			indicesG.sort(function (a, b) { return first[a] > first[b] ? -1 : first[a] < first[b] ? 1 : 0; });
			var loadsArrayG = getLoadNames();
			
			placeGraphsDiv();	
			renderStepsLineChart(stepsArrayG,averageArrayG,loadsArrayG,indicesG,5);

//urlLine chart begins here
		function getUrlQueryString(name){
		   if(name=(new RegExp('[?&]'+encodeURIComponent(name)+'=([^&]*)')).exec(location.search))
		      return decodeURIComponent(name[1]);
		}
		
		function makeResponseRows(responseText){
			return responseText.slice(2,responseText.length-2).split('], [');
		}
		
		function makeResponseArrays(responseRows) {
			var responseArray = [];
			for(i=0;i<responseRows.length;i++) {
				responseArray.push(responseRows[i].split(','));
			}
			return responseArray;
		}
 			
		function makeUrlObject(responseArray){
			var fields = responseArray[0];
			var urlObject = {};
			for(index=1;index<responseArray.length;index++){
				var current = responseArray[index];
				var scriptId = current[0].trim();
				var totalTime = parseInt(current[1].trim());
				var sendTime = parseInt(current[2].trim());
				var waitTime = parseInt(current[3].trim());
				var receiveTime = parseInt(current[4].trim());
				var url = decodeURIComponent(current[5].trim());
				var stepId = parseInt(current[6].trim());
				var loadCount = parseInt(current[7].trim());
				if( (urlObject[url]==undefined) || (urlObject[url][stepId]==undefined ) || (urlObject[url][stepId][loadCount]==undefined ) ) {
					if( urlObject[url]==undefined ) urlObject[url] = {};
					if( urlObject[url][stepId]==undefined ) urlObject[url][stepId] = {};
					if( urlObject[url][stepId][loadCount]==undefined ) urlObject[url][stepId][loadCount] = {};	
				}				
				urlObject[url][stepId][loadCount]["scriptReportId"] = scriptId;
				urlObject[url][stepId][loadCount]["totalTime"] = totalTime;
				urlObject[url][stepId][loadCount]["sendTime"] = sendTime;
				urlObject[url][stepId][loadCount]["waitTime"] = waitTime;
				urlObject[url][stepId][loadCount]["receiveTime"] = receiveTime;
				urlObject[url][stepId][loadCount]["stepId"] = stepId;
			}
			return urlObject;
		}
		
		function urlLineClick(stepId,urlValue,scriptReportId) {
			location.href = "/_s_/dyn/pro/DBReports_scriptReport?id=" +scriptReportId+"&stepId="+stepId+"&url="+encodeURIComponent(urlValue);
		}
		
		function initiateUrlLineGraph(urlsLimit,chartHolder){
			var xmlhttp;
			if (window.XMLHttpRequest){ // code for IE7+, Firefox, Chrome, Opera, Safari
				xmlhttp=new XMLHttpRequest();
			} else {// code for IE6, IE5
				xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  			}
  			xmlhttp.onreadystatechange = function() {
				if (this.readyState==4 && this.status==200) {
			    	var responseText = xmlhttp.responseText;
			    	var responseRows = makeResponseRows(responseText);
			    	if(responseRows.length > 1) {
				    	var responseArray = makeResponseArrays(responseRows);
				    	drawUrlLineGraph(makeUrlObject(responseArray),chartHolder);	
				    } else {
				    	document.getElementById("urlLineLimitBox").style.display = "none";
				    }
			    }
			}
  			var suiteId = getUrlQueryString("id");
  			xmlhttp.open("GET", "/_s_/dyn/pro/HARViewer_viewHARLogsTopWaited?suiteReportId=" + suiteId + "&urlsLimit=" +urlsLimit,true);
			xmlhttp.send();			
		}
		
		initiateUrlLineGraph(5,"placeHolder-urlLine");						
		
		function getURLValue(urlAndScriptId) {
			return urlAndScriptId.split("_SAHISEP_")[0];
		}
		
		function getUrlLineHeaderXML(yAxisMin) {
			return "<graph hoverCapBgColor='ffffff' canvasBgColor='"+canvasBgColor+"' canvasBgAlpha='"+canvasBgAlpha+"' bgAlpha='"+bgAlpha+"' bgColor='"+bgColor+"'  baseFontColor='000000' formatNumberScale='0' showShadow='0' lineThickness='3' anchorSides='10' anchorRadius='6' animation='0' decimalPrecision='0' caption='PERFORMANCE OF MOST EXPENSIVE URLS ACROSS DIFFERENT LOADS' yaxisname='TIME TAKEN BY URL(ms)' xaxisname='Load number' showLegend='1' showNames='1' showValues='0'  numdivlines='5' yAxisMinValue='"+yAxisMin+"'>";
		}
		
		function getLoadArray(urlObject){
			var loadArray = [];
			for(var firstUrl in urlObject) {
				for(var firstStep in urlObject[firstUrl]){
					for(var loadCount in urlObject[firstUrl][firstStep]){
						loadArray.push(loadCount);
					}
					break;
				}
				break;
			}
			return loadArray;
		}
		
		function getUrlLineCategoriesXML(urlObject) {
			var loadArray = getLoadArray(urlObject);
			var categoriesXML = "<categories>";
			for(var index=0; index < loadArray.length; index++){
				categoriesXML += "<category name='load-"+loadArray[index]+"' />";
			}
			categoriesXML += "</categories>";
			return categoriesXML;
		}
		
		function getUrlLineDataXML(urlObject) {
			gColorCount = 0;
			var dataXML = "";
			var minYAxisValue = 999999999;
			for(var url in urlObject) {
				var currentUrlObject = urlObject[url];			
				for( var stepId in currentUrlObject){
					var currentStepObject = currentUrlObject[stepId];
					var urlStepXML = "<dataset seriesName='Step-" + stepId  +","+ url + "' color='"+getRandomColor()+"' >";
					for(var loadCount in currentStepObject){
						var currentLoadObject = currentStepObject[loadCount];
						var currentTotalTime = parseInt(currentLoadObject['totalTime']);
						urlStepXML += "<set value='"+currentTotalTime+"' link='Javascript:urlLineClick("+JSON.stringify(stepId)+","+JSON.stringify(url)+","+JSON.stringify(currentLoadObject['scriptReportId'])+");'/> ";   											
						if( currentTotalTime < minYAxisValue) 
							minYAxisValue = currentTotalTime;
						if(!globalScriptReportId) globalScriptReportId = currentLoadObject['scriptReportId'];
					}
					urlStepXML += "</dataset>";
					dataXML += urlStepXML;
				}
			}
			return [dataXML, minYAxisValue];
		}

		function getUrlLineFooterXML() {
			return "</graph>";
		}
		
		function getUrlLineXML(urlObject) {
			var ret = getUrlLineDataXML(urlObject);
			var urlLineDataXml = ret[0];
			var yAxisMin = ret[1] - 20;
			return getUrlLineHeaderXML(yAxisMin) + getUrlLineCategoriesXML(urlObject) + urlLineDataXml + getUrlLineFooterXML();
		}
		
		function drawUrlLineGraph(urlObject,chartHolder){
			var argXML = getUrlLineXML(urlObject);
			var width = document.getElementById("graphDiv").offsetWidth - 45;
			var urlLineChart = new FusionCharts( "/_s_/spr/charts/swf/FCF_MSLine.swf",chartHolder, width.toString(), "300");
	      	urlLineChart.setDataXML(argXML,"xml");
	     	urlLineChart.render(chartHolder);
		}       	 				
			
	]]>

		</script>
	</xsl:template>
	
	</xsl:stylesheet>