<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="in.co.sahi.util.XSLUtils"
	version="1.0">

	<xsl:output method="html" indent="yes" />
	<xsl:param name="useDBURL" select="false" />
	<xsl:param name="scriptName" select="/result/summary/SCRIPTNAME" />
	<xsl:template match="/">
	<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
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

			<body onunload="onUnload()" onload="onLoad()">
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
		<script type="text/javascript">var scriptReportID = '<xsl:value-of select="scriptReportId|SCRIPTREPORTID"/>'</script>
		<xsl:choose>
			<xsl:when test="$useDBURL = 'true'">
				<div id='navbar'> 
					<a href='/_s_/dyn/pro/DBReports' style="color:black">Root</a>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div id='navbar'> 
					<a href='/_s_/dyn/Log_viewLogs' style="color:black">Root</a>
				</div>
			</xsl:otherwise>
		</xsl:choose>
		
		<table class="summary" style="background-color:white;margin-top:20px;width:300px;">
			<tr>
				<td>Test</td>
				<td>Total Steps</td>
			</tr>
			<tr class="{$className}">
				<td>
					<xsl:value-of select="scriptName|SCRIPTNAME" />
				</td>
				<td>
					<xsl:value-of select="$stepsCount" />
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
			<xsl:param name="isExcel">
				<xsl:value-of select="util:endsWith($scriptName, '.xls') or util:endsWith($scriptName, '.xlsx')"/> 
			</xsl:param>
			<xsl:choose>
				<xsl:when test="starts-with($result,'_log') and $className!=&quot;ERROR&quot;">
				</xsl:when>
				<xsl:when test="$isExcel=&quot;true&quot; and ($className=&quot;TESTCASE_START&quot; or $className=&quot;TESTCASE_END&quot;)">
				</xsl:when>				
				<xsl:when test="$className=&quot;RAW&quot;">
					<xsl:value-of disable-output-escaping="yes" select="message|MESSAGE" />
				</xsl:when>
				<xsl:when test="$className=&quot;TESTCASE_START&quot; or $className=&quot;GROUP_START&quot;">
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
				<xsl:when test="$className=&quot;TESTCASE_END&quot; or $className=&quot;GROUP_END&quot;">
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
						<xsl:variable name="time" select="time|MESSAGETIMESTAMP" />
						<xsl:variable name="fixedTime" select="util:fixMillis($time)" />
						</span>
						<xsl:if test="not($failureMsg = '' or $failureMsg ='null')">
							<div><xsl:value-of disable-output-escaping="yes" select="util:newlineToBR($failureMsg)" /></div>
						</xsl:if>
						<xsl:if test="not($screenShot = '')">
							<div id="like_{$screenShot}" class="imagegroup">
							<a href="/_s_/dyn/Log_viewLogs/images/{$screenShot}" style="margin:0px;padding:0px" target="_blank"><img style="margin-top:15px;margin-bottom:30px;display:block;" src="/_s_/dyn/Log_viewLogs/images/{$screenShot}" height="337" /></a>
							</div>
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
		var openedElement = new Array();
		var cookieHashMap = {};
		function hideImage(i){i.style.display='none';}
        var divs = document.getElementsByTagName('DIV'); 
        for (var i=0; i<divs.length; i++){
        	var d = divs[i]; 
        	if (d.className == 'GROUP') { attachFn(d); markStatus(d);} 
        }
        function attachFn(d){ d.getElementsByTagName('DIV')[0].onclick = function () {showHideDiv(d);}	} 
        function getInnerDiv(d){var els = d.getElementsByTagName('DIV'); for (var i=0; i<els.length;i++) {if (els[i].className == 'GROUP_INNER') return els[i];}}
        function showHideDiv(groupDiv){	
        	var stepsDiv = getInnerDiv(groupDiv);
        	var els = document.getElementsByTagName('DIV');
        	for(var i = 0; i < els.length; i++){
        		if (els[i] == stepsDiv){
        			if(stepsDiv.style.display == 'block'){
        				removeFromCookieArray(i);
        				stepsDiv.style.display = 'none';
        				break;
        			}else{
        				stepsDiv.style.display = 'block';
        				addToCookieArray(i);
        				break;
        			}
        		}	
        	}
        }; 
		function markStatus(d) {d.getElementsByTagName('DIV')[0].className += (d.innerHTML.indexOf('<!--SAHI_TESTCASE_FAIL_MARKER-->') == -1) ? ' SUCCESS' : ' FAILURE'};
		function addToCookieArray(element){
			openedElement.push(element)
		}
		function removeFromCookieArray(element){
			removeByValue(openedElement,element)
		}
		function removeByValue(arr, val) {
			for ( var i = 0; i < arr.length; i++) {
				if (arr[i] == val) {
					arr.splice(i, 1);
					break;
				}
			}
		}
		function onLoad(){
			var cookieValue = readCookie("OpenedElement");
			if(cookieValue){
				cookieHashMap = eval("("+cookieValue+")");
				openedElement=cookieHashMap[scriptReportID];
				if (!openedElement) openedElement = [];
				delete cookieHashMap[scriptReportID];
				var els = document.getElementsByTagName('DIV');
				for(var i = 0; i < openedElement.length; i++){
					els[openedElement[i]].style.display = 'block';
        		}
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
			cookieHashMap[scriptReportID] = openedElement;
			var cookieValue = getJSON(cookieHashMap);
			createCookie("OpenedElement", cookieValue, 1);
		}
		function getJSON(o) {
			var s = "{";
			for (var i in o) {
				s += "'" + i + "':[" + o[i] + "],"
			}
			s += "}";
			return s;
		}
		function createCookie(name,value,days)
		{
			if (days) {
				var date = new Date();
				date.setTime(date.getTime()+(days*24*60*60*1000));
				var expires = "; expires="+date.toGMTString();
			}
			else var expires = "";
			document.cookie = name+"="+value+expires+"; path=/";
		}
		
		function readCookie(name)
		{
			var nameEQ = name + "=";
			var ca = document.cookie.split(';');
			for(var i=0;i < ca.length;i++)
			{
				var c = ca[i];
				while (c.charAt(0)==' ') c = c.substring(1,c.length);
				if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
			}
			return null;
		}
		function fixImagePaths(){
			if (location.href.indexOf("http://") == 0 || location.href.indexOf("https://") == 0) return;
			var imgs = document.getElementsByTagName('IMG'); 
	        for (var i=0; i<imgs.length; i++){
	        	var img = imgs[i]; 	        	
 				if (img.src.indexOf("Log_viewLogs/images") != -1) {
 					img.src = makeRelative(img.src);
 					if (img.parentNode.tagName.toLowerCase() == "a") {
 						img.parentNode.href = makeRelative(img.parentNode.href);
 					}
 				}
	        }
		}
		function makeRelative(s){
			var ix = s.indexOf("/images/"); 
			if (ix != -1) {
				s = s.substring(ix+1);
			}
			return s;
		}
		function showComparisonImages(o){
			var steps = o.result;
			//var groups = document.getElementsByClassName("imagegroup");
			var groups = [];
            var groupsDiv = document.getElementsByTagName("div");
			for(var i=0; i<groupsDiv.length; i++){
				if(groupsDiv[i].className == "imagegroup"){
					groups.push(groupsDiv[i]);
				}
			}
			var grouped = groupSimilarImages(steps);
			//alert(grouped);
			for (var j=0; j<groups.length; j++) {
				var g = groups[j];
				var id = g.id.replace("like_", "");
				var images = grouped[id];
				g.innerHTML = "";
				for (var k=0; k<images.length; k++) {
					g.innerHTML += '<a href="/_s_/dyn/Log_viewLogs/images/' + images[k] + '" style="margin:0px;padding:0px" target="_blank"><img style="margin-top:15px;margin-bottom:30px;display:inline;" src="/_s_/dyn/Log_viewLogs/images/' + images[k] + '" height="337" /></a>';
				}
				//alert(images);
			}
			//for (var i=1; i<steps.length; i++) {
			//	document.write("<img src='" + steps[i][2] + "'></img>");
			//}
		}
		function groupSimilarImages(steps){
			var map = {};
			for (var i=1; i<steps.length; i++) {
				var step = steps[i];
				var msg = step[0];
				var scr = step[2];
				if (!map[msg]) {
					map[msg] = [];
				}
				map[msg].push(scr);
			}
			var newMap = {};
			for (var k in map) {
				newMap[map[k][0]] = map[k];
			}
			return newMap;
		}
		fixImagePaths();
        ]]>
        </script>
        </div>
        <style>div.GROUP_LABEL {display:block;}</style>
	</xsl:template>
	
	<xsl:template match="otherScreenShots">
	<script>
	var o = <xsl:value-of disable-output-escaping="yes" select="." />;
	showComparisonImages(o);
	</script>
	</xsl:template>
	<xsl:template match="suiteInfo">
	</xsl:template>
</xsl:stylesheet>