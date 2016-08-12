<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="in.co.sahi.util.XSLUtils" 
version="1.0">
	<xsl:output method="html" indent="yes" />
	<xsl:template match="/">
		<html>
		<script language="JavaScript" src="/_s_/spr/charts/JSClass/FusionCharts.js"></script>
		<script>
		<![CDATA[
		//userdata/config/reports/html/suites_list.xsl
		
		function checkAll(isChecked){
			var els = document.getElementsByTagName("INPUT");
			for (var i=0; i<els.length; i++) {
				var el = els[i];
				if (el.type == "checkbox") {
					el.checked = isChecked;
				}
			}
		}
		function onCheckClick(me){
			var el = document.getElementById("checkAllCB");
			if (el.checked) {
				el.checked = false;
			}
		}
		function deleteSuites(){
			document.listForm.action = "DBReports_deleteSuite";
			document.listForm.submit();
		}
		
		function getCheckedSuites(){
			var elements = document.listForm.elements;
			var ids=[];
			for(var itr=0;itr<elements.length;itr++){
				var element = elements[itr];
				if(element.type == "checkbox" && element.checked){
					ids.push(element.value);
				}
			}
			return ids;
		}
		function compareSuites(){
			var ids = getCheckedSuites();
			if(ids.length < 2){
				alert("select more than 2 suites to compare");
				return;
			}
			location.href = "DBReports_suiteReport?id="+ids[0]+"&compareIds="+ids.slice(1).join(',');
		}
		
		function $_(id){
			return document.getElementById(id);
		}
		
		
		function hasClass(ele,cls) {
			return ele.className.match(new RegExp('(\\s|^)'+cls+'(\\s|$)'));
		}
		function addClass(ele,cls) {
			if (!this.hasClass(ele,cls)) ele.className += " "+cls;
		}
		function removeClass(ele,cls) {
			if (hasClass(ele,cls)) {
				var reg = new RegExp('(\\s|^)'+cls+'(\\s|$)');
				ele.className=ele.className.replace(reg,' ');
			}
		}
		
		
		function handleRelationalFilter(filter_value){
			var match = filter_value.match(/^([[>|<|\!]=*)?(\d+)$/);
			if(!match[1]){
				return " = " + match[0];
			} else{
				return " " + match[1] + " " + match[2];
			}
		}
		
		function jsToDbTS(now){
			return [(now.getFullYear()) + "-" +(now.getMonth()+1) +"-"+ (now.getDate()) , now.getHours() + ":" + now.getMinutes()+ ":" + now.getSeconds()];
		}
		
		function handleDateFilter(option){
			var start = new Date();
			var end = new Date();
			end.setDate(end.getDate());
			end = jsToDbTS(end)[0];
			switch(option){
				case "today":
					start = jsToDbTS(start)[0];					
					break;
				case "7days":
					start.setDate(start.getDate()-7);
					start = jsToDbTS(start)[0];					
					break;
				case "1month":
					start.setMonth(start.getMonth()-1);
					start = jsToDbTS(start)[0];
					break;					
			}
			//return " startTime between '" + start + "' and '" + end +"'" ;
			return [start,end];
		
		}
		
		function changeRange(){
			if($_("range_flt").value){
				var range = handleDateFilter($_("range_flt").value);
				$_("from_flt").value = range[0];
				$_("to_flt").value = range[1];
			} else{
				$_("from_flt").value = "yyyy-mm-dd";
				$_("to_flt").value = "yyyy-mm-dd";
			}
		}
		
		
		function getLimitString(){
			return ( (isNaN($_("filter_top_flt").value) || !$_("filter_top_flt").value) ? "" :  (" limit " + $_("filter_top_flt").value) );		
		}

		function buildFilterInfo(){
			var built = "";
				var filters = document.listForm.elements;
				for(var itr=0;itr<filters.length;itr++){
					var child = filters[itr];
					if (child.type != "text" && child.type != "select-one" && child.type != "hidden") continue;
					if(!built){
						built += child.id + ":::" + child.value;
					}else{
						built += "---" +child.id + ":::" + child.value;
					}
				}
				built += "---" + "pass_threshold" + ":::" + $_("pass_threshold").value;
			return built;
		}		

		function getFilterQuery(ele){
			
			switch(ele.id)
			{
				case "suite_name_flt":
				  return (" SUITENAME like '%" + ele.value + "%'");
				case "user_id_flt":
				  return (" USERDEFINEDID like '%" + ele.value + "%'");
				case "browser_name_flt":
				  return (" BROWSERTYPE like '%" + ele.value + "%'");
				case "range_flt":
				  return " STARTTIME between '" + $_("from_flt").value + "' and '" + $_("to_flt").value +" 23:59:59'" ;
				case "time_taken_flt":
					return (" TIMETAKEN " + handleRelationalFilter(ele.value));
				case "scripts_run_flt":
					return (" TOTALCOUNT " + handleRelationalFilter(ele.value));
				case "passed_flt":
					return (" PASSEDCOUNT " + handleRelationalFilter(ele.value));
				case "failed_flt":
					return (" FAILEDCOUNT " + handleRelationalFilter(ele.value));
				case "status_flt":
					return (" STATUS like '%" + ele.value + "%'");
				
				default:
				  return "";
			}
		
		}
		
		function addStrs(str1,str2){ 
			if(str2){
				return str1+str2;
			}
			return "";
		} 
		
		function searchSuites(bySql){
			if(!bySql){
				var selectPart = "select * from SUITEREPORTS";
				var sql = selectPart;
				var filters = document.listForm.elements;
				for(var itr=0;itr<filters.length;itr++){
					var child = filters[itr];
					if ( (child.type != "text" && child.type != "select-one") || child.value =="" || child.id =="from_flt" || child.id =="to_flt" || child.id =="filter_top_flt") continue;
					if(sql == selectPart){
						sql += addStrs(" where ",getFilterQuery(child));
					} else {
						sql += addStrs(" and ",getFilterQuery(child));
					}
	
				}
				sql += " order by STARTTIME desc";
				sql += getLimitString();
				$_("sql").value = sql;
				$_("useSQL").value = "false";
			} else{
				sql = $_("sql").value;
				$_("useSQL").value = "true";
			}
			location.href = "DBReports?sql="+encodeURIComponent(sql)+"&filterInfo="+encodeURIComponent(buildFilterInfo());
			
		}
		
		
		function isVisible(element){
			return (element.style.display != "none");

		}
		function toggleSql(){
			if(isVisible($_("sql_span"))){
				$_("sql_span").style.display="none";
				$_("toggle_link").innerHTML = "Use SQL";
				$_("useSQL").value = "false";
			} else {
				$_("sql_span").style.display="block";
				$_("toggle_link").innerHTML = "Don't use SQL";
				$_("useSQL").value = "true";
			}
		}
		function populatePassThresholdSelect(){
			var sel_el = $_("pass_threshold");
			var s = "";
			var i = 0;
			for(var itr = 100; itr>=0 ; itr--){
				sel_el.options[i++] = new Option(itr+"%", itr);
			}
		}
		function getPassedPercent(passed,failed){
			if ((passed + failed) == 0) return 0;
			return (passed*100/(passed+failed));
		}
		
		function changeRowClassToThreshold(){
		 for(var counter=1; ;counter++){
		 	var row = $_("row-"+counter);
		 	if(row == null) return;
		 	
		 	var pass_pc = getPassedPercent(getPassedCount(counter),getFailedCount(counter));
		 	if( pass_pc >= getPassThreshold() ){
		 		row.className = "SUCCESS";
		 	} else{
		 		row.className = "FAILURE";
		 	}
		 	
					 	
		 }
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
		
		function onLoad(){
			populatePassThresholdSelect();
			
			var keys_values = inFilterInfo.split("---");
			if(keys_values.length > 2){
				for(var itr=0;itr<keys_values.length;itr++){
					var key_value = keys_values[itr].split(":::");
					$_(key_value[0]).value =key_value[1]; 
				}
			}
			if($_("useSQL").value == "true"){ // to preserve sql box if sql box was used to filter in previous request
				$_("sql_span").style.display = "block"; 
				$_("toggle_link").innerHTML = "Don't use SQL";
			}
			
			changeRowClassToThreshold();
			
			showGraphs(queryStringObject["graphs"] == "enabled" || $_("graphs").value == "enabled");
		}
		
		function pressEnter(event){
			if (event.keyCode == 13) 
				searchSuites(false);
		}
		
		function showGraphs(b){
			if (b) {
				$_("graphs").value = "enabled";
				$_("graphsDiv").style.display = "block";
				renderPieCharts("pie_chart_parent");
				renderSingleBarChart("suite_runs_bar");
				$_("showGraphsBtn").style.display = "none";
				$_("hideGraphsBtn").style.display = "inline";
			} else {
				$_("graphs").value = "disabled";
				$_("graphsDiv").style.display = "none";
				$_("showGraphsBtn").style.display = "inline";
				$_("hideGraphsBtn").style.display = "none";
			}	
		}
		
		
		//javascript change
		_isTCSummary = false;
		function showTCSummary(b){
			_isTCSummary = b;
			showHideTCSummaryColumns();
			if ($_("graphsDiv").style.display == "block") {
				showGraphs(true);
			}
		}
		function showHideTCSummaryColumns(){
			var b = _isTCSummary;
   			for (var i=1; i<100;i++) {
   				showHide($_("total-" + i), !b);
   				showHide($_("passed-" + i), !b);
   				showHide($_("failed-" + i), !b);
   			}
   			for (var i=1; i<100;i++) {
   				showHide($_("totalTC-" + i), b);
   				showHide($_("passedTC-" + i), b);
   				showHide($_("failedTC-" + i), b);   			
   			}
   			for (var i=1; i<100;i++) {
   				showHide($_("link-" + i + "-tc"), b);
   				showHide($_("link-" + i), !b);
   			}
   			$_("heading").innerHTML = b? "Test Case Wise Summary" : "Script Wise Summary" ;
			showHide($_("showTCBtn"), !b);
			showHide($_("showScriptBtn"), b);
		}
		function showHide(el, b){
			if (!el) return;
			if (b) {
				el.className =   el.className.replace(/(?:^|\s)hidden(?!\S)/g , '');
			} else {
				el.className = el.className + " hidden";
			}
		}
		
		]]>
		</script>
			<head>
				<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
				<title>Suites List</title>
								<style>
					div{border:1px solid white;border-bottom:1px solid gray;padding:1px}
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
				
					table#suite_list_table{border-top:1px solid gray;border-right:1px solid gray;border-spacing:0px;border-collapse:collapse;}
					table#suite_list_table td{border-bottom:1px solid gray;border-left:1px solid gray;padding:5px;text-align:right;}
					table#range_table {border:0px;margin:0px;padding:0px}
					table#range_table td{border:0px;margin:0px;padding:0px;padding-right:5px;}
					td a.SCRIPT{float:left;}
					tr.FAILURE{background-color:red;color:white;}
					tr.SUCCESS{background-color:green;color:white;}
					tr.RUNNING{background-color:orange;color:black;}
					tr.INITIAL a{color:black;}
					tr a{color:white;text-decoration:underline;}
					tr.RUNNING a {color:black;}
					
					body *{font-family:verdana;font-size:10pt;}
					body {margin:2px; background-color:lightyellow;}
					
					tr#filter_row td input{width:102px;}
					input.init{color:grey;font-size:10pt;}
					.sql_table{border:0;width:900px;}
					.sql_table td{border:0;text-align:left;}
					.hidden{display:none}
</style>
			</head>

			<body onLoad="onLoad()">
				<div id = "heading" style="float:right;margin-right:20px;">Script Wise Summary</div>
				<div id='navbar'> 
					<a href='/_s_/dyn/pro/DBReports' style="color:black"><b>Root</b></a>
				</div><br/>
				
				<div id="graphsDiv" style="border:1px solid gray;border-radius:10px;padding:20px;margin:20px;">
				<div id="suite_runs_bar" style="border:0px"></div>
				<span id="pie_chart_parent" style="border:0px"></span>
				</div>
				
				<xsl:apply-templates />
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="suiteSummaries">
		<script>
			var inFilterInfo='<xsl:value-of select="filter/filterInfo" />';		
		</script>

		<form name="listForm" method="POST" action="">
		<input type="hidden" name="graphs" value="" id="graphs"/>
		<input type="hidden" name="useSQL" value="false" id="useSQL"/>
		<table>
			<tr><td>	
<div style="margin-bottom:0px;border:0px;">
	<span id="error_span" style="color:red;"><xsl:value-of select="error"/></span>
	
	<div id="sql_span" style="display:none;border:1px solid gray;border-radius:5px;padding:20px;background-color:#ddd;margin:20px 10px;">
		<table class="sql_table" style="width:99%;">
		<tr>	
			<td>
				<textarea id="sql" style="width:100%;height:60px;padding:5px;"><xsl:value-of select="filter/sql" /></textarea>
				<br/>
				
			</td>
			</tr><tr>
			<td>
				<input type="button" onclick="searchSuites(true)" style="float:right;" value="Filter by SQL"/>
				<span>
					Columns available:  SUITENAME, BROWSERTYPE, TIMETAKEN, TOTALCOUNT, PASSEDCOUNT, FAILEDCOUNT, STATUS
				</span>
			</td>
		</tr>
		</table>		
	</div>
</div>

<table width="100%">
<tr>
<td>
<table style="float:left">
<tr>
<td><input type="button" onclick="deleteSuites()" value="Delete" style="margin-right:8px"/></td>
<td><input type="button" onclick="compareSuites()" value="Compare Suites" style="margin-right:8px"/></td>
<td><span style="margin-right:5px">Pass threshold</span>
<select name="pass_threshold" id="pass_threshold" onkeydown="pressEnter(event)"><!--will be populated on body-load--></select>
</td>
<td>
</td>
</tr>
</table>
</td>
<td>
<input id="showGraphsBtn" type="button" onclick="showGraphs(true)" value="Show Graphs" style="margin-right:8px"/>
<input id="hideGraphsBtn" type="button" onclick="showGraphs(false)" value="Hide Graphs" style="display:none;margin-right:8px"/>
</td>
<td>
<input id="showTCBtn" type="button" onclick="showTCSummary(true)" value="Show Testcase Summary" style="margin-right:8px"/>
<input id="showScriptBtn" type="button" onclick="showTCSummary(false)" value="Show Script Summary" style="margin-right:8px" class="hidden"/>
</td>
<td>
<table style="float:right">
<tr>
<td><a href="#" style="color:blue;text-decoration:underline;margin:0 10px 0px 0px;" id="toggle_link" value ="Use SQL" onclick="toggleSql()">Use SQL</a></td>
<td>Limit: <input type="text" name ="filter_top_flt" id="filter_top_flt" value="50" size="2" onkeydown="pressEnter(event)"/></td>
<td><input type="button" onclick="searchSuites(false)" value="Filter" style="margin-left:8px"/></td>
<td><input type="button" onclick="document.listForm.reset()" value="Reset filters" style="margin-left:8px"/></td>
</tr>
</table>
</td>

</tr>
</table>
			</td></tr>
			<tr><td>		
				<table id="suite_list_table" style="width:100%;background-color:white;overflow:auto;">
					<tr id="filter_row">
					<td style="width:30px;">
					</td>
					<td>
						<input type="text" style="width:200px;" name ="suite_name_flt" id="suite_name_flt" onkeydown="pressEnter(event)"></input>
					</td>
					<td>
						<input type="text"  name ="user_id_flt" id="user_id_flt" onkeydown="pressEnter(event)"></input>
					</td>
					<!-- custom field filtering part start-->
					<!--<td></td>-->
					<!-- custom field filtering part end-->
					<td>
						<input type="text" name ="browser_name_flt" id="browser_name_flt" onkeydown="pressEnter(event)"></input>
					</td>
					<td colspan="2" style="width:450px;">
						<table id="range_table"><tr>
						<td>
							<select id="range_flt" name="range_flt" onkeydown="pressEnter(event)" onchange="changeRange()" >
								<option value="" default="true">Choose</option>
								<option value="today">Today</option>
								<option value="7days">Last 7 days</option>
								<option value="1month">Last month</option>
							</select></td><td>
							From</td><td><input type="text" id="from_flt"  onkeydown="pressEnter(event)" value="yyyy-mm-dd"></input></td><td>To</td><td>
							<input type="text" id="to_flt" onkeydown="pressEnter(event)" value="yyyy-mm-dd"></input></td>
						</tr></table>
					</td>
					<td style="width:100px;">
						<input type="text" name="time_taken_flt" id="time_taken_flt" onkeydown="pressEnter(event)"></input>
					</td>
					<td style="width:60px;">
						<input type="text" name="scripts_run_flt" id="scripts_run_flt" style="width:45px;" onkeydown="pressEnter(event)"></input>
					</td>
					<td style="width:60px;">
						<input type="text" name="passed_flt" id="passed_flt" style="width:45px;" onkeydown="pressEnter(event)"></input>
					</td>
					<td style="widsth:60px;">
						<input type="text" name="failed_flt" id="failed_flt" style="width:45px;" onkeydown="pressEnter(event)"></input>
					</td>
					<td style="widsth:90px;">
						<select id="status_flt" name="status_flt" onkeydown="pressEnter(event)">
						<option value="" default="true">Choose</option>
						<option value="SUCCESS">Success</option>
						<option value="FAILURE">Failure</option>
					</select>
					</td>
				</tr>
				
				<tr>
				<td id="CheckAll"><input id="checkAllCB" type="checkbox" value="" onclick="checkAll(this.checked)"/></td>
				<td id="SuiteName">Suite Name</td>
				<td id="UserDefinedId">User Defined Id</td>
				<!-- Custom Field header-->
				<!--<td id="RowNo">Custom Field</td>-->
				<td id="Browser">Browser</td>
				<td id="StartTime">Start Time</td>
				<td id="EndTime">End Time</td>
				<td id="TimeTaken">Time Taken</td>
				<td id="ScriptsRun">Run</td>
				<td id="Passed">Passed</td>
				<td id="Failed">Failed</td>
				<td id="tcRun" class="hidden">Run</td>
				<td id="tcPassed" class="hidden">Passed</td>
				<td id="tcFailed" class="hidden">Failed</td>				
				<td id="Status">Status</td>
				</tr>
		
				
				<xsl:for-each select="suiteSummary">
				<xsl:param name="className" select="STATUS" />
				<xsl:param name="suitePath" select="SUITEPATH" />
				<xsl:param name="suiteReportId" select="SUITEREPORTID" />
				<xsl:param name="suiteName" select="SUITENAME" />
				<xsl:param name="suiteInfo" select="SUITEINFO" />
		
				<tr id="row-{position()}" class="{$className}">
				
				<td><input name="cb_{position()}" type="checkbox" value="{$suiteReportId}" onclick="onCheckClick(this)"/></td>
				<td style="overflow:hidden">
					<a id="link-{position()}" href="/_s_/dyn/pro/DBReports_suiteReport?id={$suiteReportId}&amp;o=list"><xsl:value-of select="SUITENAME" /></a>
					<a id="link-{position()}-tc" href="/_s_/dyn/pro/DBReports_testCaseReport?id={$suiteReportId}&amp;o=list" class="hidden"><xsl:value-of select="SUITENAME" /></a>
					<!-- 
					xsl change
					-->
					
				</td>
				<td>
				<xsl:if test="USERDEFINEDID != 'null'">
					<xsl:value-of select="USERDEFINEDID" />
				</xsl:if>
				</td>
				<!--Retrieve custom field value-->
				<!--<td>
				<xsl:if test="SUITEINFO != 'null'">
					<xsl:value-of select="util:fetchInfo(SUITEINFO, 'customField')" />
				</xsl:if>				
				</td>-->
				<td id="browser-{position()}"><xsl:value-of select="BROWSERTYPE" /></td>
				<td id="timetaken-{position()}"><xsl:value-of select="util:humanTime(STARTTIME)" /></td>
				<td><xsl:value-of select="util:humanTime(ENDTIME)" /></td>
				<td><xsl:value-of select="TIMETAKEN" /></td>
				 
				<td id="total-{position()}" name="totalScriptCount"><xsl:value-of select="TOTALCOUNT" /></td>
				<td id="passed-{position()}" name="passedScriptCount"><xsl:value-of select="PASSEDCOUNT" /></td>
				<td id="failed-{position()}" name="failedScriptCount"><xsl:value-of select="FAILEDCOUNT" /></td>
			
				<td id="totalTC-{position()}" name="totalTCCount" class="hidden"><xsl:value-of select="TCCOUNT" /></td>
				<td id="passedTC-{position()}" name="passedTCCount" class="hidden"><xsl:value-of select="TCPASSED" /></td>
				<td id="failedTC-{position()}" name="failedTCCount" class="hidden"><xsl:value-of select="TCFAILED" /></td>
				
				<td><xsl:value-of select="STATUS"/></td>
				</tr>
				</xsl:for-each>
				</table>
			</td></tr>
		</table>
		</form>

			<script type="text/javascript">
				<![CDATA[
				
				function $_(id) {
					return document.getElementById(id);
				}	
				function getHeaderPie(caption){
					return "<graph animation='0' showNames ='1' pieBorderAlpha='40' showValues='1' " + 
					"caption='"+ caption +"' numberSuffix='%' bgColor='FFFFE0' " + 
					"showPercentValues='0' showPercentageInLabel='1' pieRadius='40' pieYScale='75' baseFontSize='10'>";
				}
				function ifNotCounterExists(counter){
					return $_("browser-"+counter) == null;
				}
				function getBrowserType(counter){
					return $_("browser-"+counter).innerHTML;
				}
				function getPassedCount(counter){
					return parseInt($_("passed" + (_isTCSummary ? "TC" : "") + "-"+counter).innerHTML);
				}
				function getFailedCount(counter){
					return parseInt($_("failed" + (_isTCSummary ? "TC" : "") + "-"+counter).innerHTML);
				}
				 
				
				function getPassThreshold(){
					return $_("pass_threshold").value;
				}
				
				function hasRunPassedThreshold(counter){
					return hasClass($_("row-"+counter),"SUCCESS");
				}
				
				function pushIfKeyNotExists(obj,key,str_keys){
					for(k in obj){
						if(k == key) return;
					}
					obj[key] = {};
					for(var itr=0;itr<str_keys.length;itr++){
						obj[key][str_keys[itr]] = 0;
					}
				}
				
				function getPieRangeArray(){
					var pass_threshold = getPassThreshold();
					var ranges = [0,51,61,71,81,91,100,101]; // [)
					for(var itr=1;itr<ranges.length;itr++){
						if( (ranges[itr-1] < (parseInt(pass_threshold)) && (parseInt(pass_threshold)) < ranges[itr]) ){
							ranges.splice(itr++,0,(parseInt(pass_threshold)));
								
						}
					}
					
					return ranges;
				}
				function getPieRangeStringArray(pass_range){ // in : [pass_array,fail_array] , out : [pass_array_strs,fail_array_strs]
					var pass_range_strs = [];
					for(var itr=1; itr<pass_range.length; itr++){
						pass_range_strs.push(pass_range[itr-1] + '-' + pass_range[itr] );
					}
					return pass_range_strs;				
				}
				
				function populateColors(obj,num_keys,str_keys){
					var pass_colors = ["51ff00","81f7a0","49875a","236b36","035e1b","6fff00","b6fa82"];
					var fail_colors = ["e83d12","a83232","FF9999","bd0000","FF0000","de2121","940000"];
					var pass_threshold = getPassThreshold();
					var fail_color_itr=0;
					var pass_color_itr=0;
					obj["x_color_codes"]={};
					for(var itr=1; itr<num_keys.length; itr++){
						if(parseInt(num_keys[itr]) <= (parseInt(pass_threshold))){
							obj["x_color_codes"][str_keys[itr-1]] = fail_colors[fail_color_itr++];
							} else {
							obj["x_color_codes"][str_keys[itr-1]] = pass_colors[pass_color_itr++];
						}						
					}
					//alert(JSON.stringify(obj["x_color_codes"]));
					
				}
				
				function getStrKeyForValue(num_keys,value){
					for(var itr=1; itr<num_keys.length; itr++){
						if(value<num_keys[itr]) return num_keys[itr-1]+'-'+num_keys[itr];
					}
				}
					
				function getXMLDataPointsObjPie(){ // { browser:xml , ... }
					var obj = {};
					
					var num_keys = getPieRangeArray();
					
					var str_keys = getPieRangeStringArray(num_keys);
					populateColors(obj,num_keys,str_keys);
					for(var counter=1;counter<=numberOfRows;counter++){ 	
					 	var browser = getBrowserType(counter);
					 	var pass_pc = Math.floor(getPassedPercent(getPassedCount(counter),getFailedCount(counter)));
					 	
					 	pushIfKeyNotExists(obj, browser,str_keys);
					 	var str_key = getStrKeyForValue(num_keys,pass_pc);
					 	obj[browser][str_key] +=1;
					 }
					return obj;
				}
				
				function getLabelStringForRange(range_str){
					
				}
				function getRangeObj(range_str){
					var range_obj = {};
					var xy = range_str.split('-');
					if(xy[0] == (xy[1]-1)) {
						range_obj["label"] = xy[0] + '%';
					} else{
						range_obj["label"] = xy[0] + '-' + (xy[1]-1) + '%';
					}
					range_obj["has_passed"] = ((xy[1]-1) >= getPassThreshold());
					return range_obj;
				}
				
				function getXmlForObjPie(obj){ //{ browser:{passed:int,failed:int} , ...}
					var xmlObj = {};
					for(browser in obj){
						if(browser == "x_color_codes") continue;
						xmlObj[browser] = "";
						for(range in obj[browser]){
							var val = obj[browser][range];
							if(val==0) continue;
							var rangeObj= getRangeObj(range);
							if(rangeObj.has_passed){
								xmlObj[browser] += "<set name= '"+rangeObj.label+"' value='"+ val +"' color='"+obj["x_color_codes"][range]+"'/>";
							} else {
								xmlObj[browser] += "<set name= '"+rangeObj.label+"' value='"+ val +"' color='"+obj["x_color_codes"][range]+"' isSliced='1'/>";
							}					
						}
					}
					return xmlObj;
				}
				function getFooter(){
					return "</graph>";
				}
				function createPieDiv(parent,counter){
					var new_div_id = "pieDiv-"+counter;
					$_(parent).innerHTML += '<div id="'+ new_div_id +'" style="display:inline;border:0px"></div>';
					return new_div_id;
				}
				function renderPieCharts(parentDiv){
					var obj = getXMLDataPointsObjPie();
					var browserXml = getXmlForObjPie(obj); // {browser:xml,...}
					var counter=0;
					for(browser in browserXml){
						var argXML = getHeaderPie(browser);
						argXML += browserXml[browser];
						argXML += getFooter();
						
						var new_div_id = createPieDiv(parentDiv,counter);
						
						var pieChart = new FusionCharts( "/_s_/spr/charts/swf/FCF_Pie2D.swf",new_div_id, "400", "180");
	      			    pieChart.setDataXML(argXML,"xml");
	     	 		    pieChart.render(new_div_id);
	     	 		    
	     	 		    counter++;
					
					}					
					 
				}
				
				function getHeaderBar(yAxisDisplay){
					return "<graph animation='0' showNames='0' showValues='0' showShadow='0' " + 
					"bgColor='FFFFE0' caption='SUITE RUNS OVER TIME' " + 
					"xAxisName='Suite runs over time ->' yAxisName='"+ yAxisDisplay + "' " +
					"canvasBorderColor='ffffff' canvasBorderThickness='0' chartBottomMargin='10'" +
					">";
				}
				function getScriptCount(counter){
					return $_("total" + (_isTCSummary ? "TC" : "") + "-"+counter).innerHTML;
				}
				function getLinkHref(counter){
					return $_("link-"+counter).href;
				}
				function getSuiteName(counter){ 
					return $_("link-"+counter).innerHTML;
				}				
				function getCategoryXml(counter){
					return "<category name='"+ getSuiteName(counter) + "' />";
				}
				function getPassXml(counter){
					return "<set name='" + getSuiteName(counter) + "' value='" + getPassedCount(counter) + "' link='"+ getLinkHref(counter) +"' color='00FF00' />";
				}
				function getFailXml(counter){
					return "<set name='" + getSuiteName(counter) + "' value='" + getFailedCount(counter) + "' link='"+ getLinkHref(counter) +"' color='FF0000' />";
				}
				
				var numberOfRows = function (){ 
					for(var counter=1;;counter++){
						if(ifNotCounterExists(counter)) break;
					}
					return counter-1;
				}();
				
				function getXMLDataPointsBar(){
					var categoriesXml = "<categories>";
					var failXml = "<dataset seriesname='Failed' color='FF0000' showValues='0' >";
					var passXml = "<dataset seriesname='Passed' color='00FF00' showValues='0' >";
					
					for(counter = numberOfRows-1;counter>=1;counter--){
						categoriesXml += getCategoryXml(counter);
					 	failXml += getFailXml(counter);
					 	passXml += getPassXml(counter);
					}
					categoriesXml += "</categories>";
					passXml += "</dataset>";
					failXml += "</dataset>";
					
					return categoriesXml+failXml+passXml;
				}				
				function renderSingleBarChart(containerDiv){
					var argXML = getHeaderBar('Script count');
					argXML += getXMLDataPointsBar();
					argXML += getFooter();
					
					 var myChart = new FusionCharts( "/_s_/spr/charts/swf/FCF_StackedColumn2D.swf","myChartId", "1200", "300");
	      			 myChart.setDataXML(argXML,"xml");
	     	 		 myChart.render(containerDiv);
				
				}
				//showGraphs(true);
				//renderSingleBarChart("suite_runs_bar");
				
				
				]]>
		</script>


	</xsl:template>

</xsl:stylesheet>