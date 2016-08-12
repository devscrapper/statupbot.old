<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="in.co.sahi.util.XSLUtils"
	version="1.0">

	<xsl:output method="html" indent="yes" />
	<xsl:param name="useDBURL" select="false" />
	<xsl:param name="scriptName" select="/result/summary/SCRIPTNAME" />
	<xsl:template match="/">
		<html>
			<head>
				<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
				<style>
					div{padding:3px;}
					a{text-decoration:none;color:white;}
					a.INFO{color:black;}
					a.START,a.STOP{color:black;font-weight:bold;}
					div.INFO{background-color:white;}
					div.SUCCESS{background-color:green;color:white}
					div.FAILURE,div.ERROR{background-color:red;color:white}
					a.CUSTOM, a.CUSTOM2, a.CUSTOM4{color:black}
					div.CUSTOM{background-color:yellow;}
					div.CUSTOM1{background-color:orange;}
					div.CUSTOM2{background-color:#EFEFEF;}
					div.CUSTOM3{background-color:green;}
					div.CUSTOM4{background-color:violet;}
					div.CUSTOM5{background-color:indigo;}
					div.networkActivity{float:right;width:200px;color:#ccc;cursor:pointer;display:none;padding:0px;}
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

	<xsl:template match="summary">
		<xsl:param name="className" select="status|STATUS" />
		<xsl:param name="stepsCount" select="number(steps|TOTALSTEPS)" />
		<xsl:param name="failures" select="number(failures|FAILURES)" />
		<xsl:param name="errors" select="number(errors|ERRORS)" />
		<xsl:param name="tcCount" select="number(tcCount|TCCOUNT)" />
		<xsl:param name="tcPassed" select="number(tcPassed|TCPASSED)" />
		<xsl:param name="tcFailed" select="number(tcFailed|TCFAILED)" />
		<xsl:param name="suiteReportIdx" select="SUITEREPORTID" />
		<xsl:param name="scriptReportId" select="scriptReportId|SCRIPTREPORTID" />
		<xsl:param name="load" select="number(load|LOAD)" />
		<script type="text/javascript">var scriptReportID = '<xsl:value-of select="scriptReportId|SCRIPTREPORTID"/>'</script>
		<table class="summary" style="background-color:white;margin-top:20px;width:800px;">
			<tr>
				<td>Test</td>
				<td>Total Steps</td>
				<td>Failures</td>
				<td>Errors</td>
				<td>Success Rate</td>
				<td>Time Taken (ms)</td>
				<td>Node</td>
				<td>Load</td>
				<td>Browser</td>
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
					<xsl:value-of select="/result/suiteInfo/BROWSERTYPE" />
				</td>
			</tr>
			<tr><td colspan="9" style="text-align:left">Report Id: <xsl:value-of select="/result/suiteInfo/SUITEREPORTID" />
			</td></tr>
		</table>
		
		<table id="testCaseSummaryTable" class="summary" style="background-color:white;margin-top:20px;width:350px;">
			<tr>
				<td>Total Test Cases</td>
				<td>Passed</td>
				<td>Failed</td>
				<td>Success Rate</td>
			</tr>
			<tr class="{$className}">
				<td>
					<xsl:value-of select="$tcCount" />
				</td>				
				<td>
					<xsl:value-of select="$tcPassed" />
				</td>				
				<td>
					<xsl:value-of select="$tcFailed" />
				</td>
				<td>
					<xsl:choose>
						<xsl:when test="$tcCount &gt; 0">
							<xsl:value-of
								select="round(($tcCount - $tcFailed) div $tcCount * 100)" />
							%
						</xsl:when>
						<xsl:otherwise>
							0%
						</xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>
		</table>
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
			<xsl:param name="stepId" select="stepId|STEPID" />
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
						<div id="networkActivityLink{$stepId}" class="networkActivity"></div>
						<xsl:if test="not(util:isBlankOrNull($debugInfo))">
						
						<span title="{$debugInfo}">
							<xsl:value-of disable-output-escaping="yes" select="message|MESSAGE"/>
						</span>
						
						
						</xsl:if>
						<xsl:if test="util:isBlankOrNull($debugInfo)">
						<xsl:value-of disable-output-escaping="yes" select="message|MESSAGE" />
						</xsl:if>
						<span class='extra'>
						<xsl:variable name="time" select="time|MESSAGETIMESTAMP" />
						<xsl:variable name="fixedTime" select="util:fixMillis($time)" />
						<xsl:choose>
							<xsl:when test="$ix=1">
								<xsl:variable name="prevTime" select="/result/suiteInfo/STARTTIME" />
								<xsl:variable name="fixedPrevTime" select="util:fixMillis($prevTime)" />
								<xsl:variable name="difference" select="util:timeDifference($fixedTime,$fixedPrevTime)" />
								[<xsl:value-of select="$difference" /> ms] [<xsl:value-of select="util:customTime($fixedTime, 'hh:mm:ss.SSS')" />]
							</xsl:when>
							<xsl:otherwise>
								<xsl:variable name="prevTime" select="/result/steps/step[$ix - 1]/MESSAGETIMESTAMP" />
								<xsl:variable name="fixedPrevTime" select="util:fixMillis($prevTime)" />
								<xsl:variable name="difference" select="util:timeDifference($fixedTime,$fixedPrevTime)" />
								[<xsl:value-of select="$difference" /> ms] [<xsl:value-of select="util:customTime($fixedTime, 'hh:mm:ss.SSS')" />]
							</xsl:otherwise>
						</xsl:choose>
						</span>
						<xsl:if test="not(util:isBlankOrNull($failureMsg))">
							<div><xsl:value-of disable-output-escaping="yes" select="util:newlineToBR($failureMsg)" /></div>
						</xsl:if>
						<xsl:if test="not($screenShot = '')">
							<a href="/_s_/dyn/Log_viewLogs/images/{$screenShot}" style="margin:0px;padding:0px" target="_blank"><img style="margin-top:15px;margin-bottom:30px;display:block;" src="/_s_/dyn/Log_viewLogs/images/{$screenShot}" height="337" /></a>
						</xsl:if>
						<div id="harInfo{$stepId}" style="display:none"></div> 						
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
        function showHideNetworkActivity(el, scriptId, stepId){
        	if(document.getElementById('harInfo' + stepId).innerHTML == ""){
        		var html = "<iframe onload=\"setAutoHeight('harIFrame" + stepId +"')\" id=\"harIFrame" + stepId +"\" src=\"/_s_/dyn/pro/HARViewer_viewHARLogs?scriptReportId=" + scriptId + "&stepId=" + stepId + "\" style=\"width:100%;\"  frameborder=\"0\" />";
        		document.getElementById('harInfo' + stepId).innerHTML = html;
        	}
        	var plus = "Show Network Activity";
        	var minus = "Hide Network Activity";
        	if(el.innerHTML == plus){
        		el.innerHTML = minus;
        		document.getElementById('harInfo' + stepId).style.display = "block";
        	} else {
        		el.innerHTML = plus;
        		document.getElementById('harInfo' + stepId).style.display = "none";
        	}
        }
        
        function setNetworkActivityLinks(){
			var xmlhttp;
			if (window.XMLHttpRequest){ // code for IE7+, Firefox, Chrome, Opera, Safari
				xmlhttp=new XMLHttpRequest();
			} else {// code for IE6, IE5
				xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
  			}
  			xmlhttp.onreadystatechange = function() {
				if (this.readyState==4 && this.status==200) {
			    	var steps = xmlhttp.responseText;
			    	steps = steps.substring(1,steps.lastIndexOf("]"));
			    	steps = steps.split(", ");
			    	for(i = 0; i < steps.length; i++){
			    		try{
			    			document.getElementById('networkActivityLink' + steps[i]).style.display = 'block';
			    		}catch(err){
			    		}
			    	}
			    }
			}
  			xmlhttp.open("GET","/_s_/dyn/pro/HARViewer_getStepsWithNetworkActivity?scriptReportId=" + scriptReportID ,true);
			xmlhttp.send();
		}
        function setAutoHeight(id){
        	return;
			var newheight;
			if(document.getElementById(id)){
				newheight=document.getElementById(id).contentWindow.document.body.scrollHeight;
			}
			document.getElementById(id).style.height= (newheight) + "px";
		}
		
		
        
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
			setNetworkActivityLinks();
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
			if (location.href.indexOf("_s_") != -1) return;
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
		fixImagePaths();
        ]]>
        </script>
        </div>
        <style>div.GROUP_LABEL {display:block;}</style>
	</xsl:template>
	<xsl:template match="suiteInfo"></xsl:template>
</xsl:stylesheet>