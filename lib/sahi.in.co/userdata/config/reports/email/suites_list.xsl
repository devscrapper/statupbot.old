<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="in.co.sahi.util.XSLUtils" 
version="1.0">
	<xsl:output method="html" indent="yes" />
	<xsl:param name="showUserDefinedId" select="'false'" />
	<xsl:param name="showBaseUrl" select="'true'" />

	<xsl:template match="/">
		<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
		<html>
		<link rel="shortcut icon" href="/_s_/spr/favicon.ico" type="image/png"/>
		<script type="text/javascript" src="/_s_/spr/ext/jquery/jquery.min.js"></script>
		<script type="text/javascript" src="/_s_/spr/ext/easyui/jquery.easyui.min.js"></script>
		<script language="JavaScript" src="/_s_/spr/charts/JSClass/FusionCharts.js"></script>
		<link rel="stylesheet" type="text/css" href="/_s_/spr/ext/easyui/themes/gray/easyui.css" />
		<link rel="stylesheet" type="text/css" href="/_s_/spr/ext/easyui/themes/icon.css" />
		<script>
		<![CDATA[
		//userdata/config/reports/html/suites_list.xsl
		var pageSize = 50;
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
			var match = filter_value.match(/^([><\!]=*)?(\d+)$/);
			if (!match) return;
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
		function changeDate() {
			$_("range_flt").value="changed";
			//alert($_("range_flt").value);
		}
		
		function getLimitString(pageNumber, pageSize){
			if(dbType == "mssql"){
				if(pageNumber && pageSize)
					return " WHERE RESULTS.ROWNUM BETWEEN " + ((pageSize * (pageNumber-1)) + 1) + " AND " + pageNumber*pageSize;
				return "";		
			}
			else{
				if(pageNumber && pageSize)
					return " LIMIT " + ((pageNumber - 1)*pageSize) + ", " + pageSize;
				return ( (isNaN($_("filter_top_flt").value) || !$_("filter_top_flt").value) ? "" :  (" LIMIT " + $_("filter_top_flt").value) );		
			}
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
				built = "showTCSummaryKey" + ":::" + _isTCSummary + "---" + built;	//adding Testcase and Script toggling functionality 
			return built;
		}		

		function getFilterQuery(ele){
			switch(ele.id)
			{
				case "suite_name_flt":
					return ("SUITEREPORTS.SUITENAME LIKE '%" + ele.value + "%'");
				case "script_name_flt":
					return ("SCRIPTREPORTS.SCRIPTNAME LIKE '%" + ele.value + "%'");
				case "user_id_flt":
				  return (" SUITEREPORTS.USERDEFINEDID LIKE '%" + ele.value + "%'");
				case "base_url_flt":
				  return (" SUITEREPORTS.SUITEINFO LIKE '%baseURL=%" + ele.value + "%'")
				case "browser_name_flt":
				  return (" SUITEREPORTS.BROWSERTYPE LIKE '%" + ele.value + "%'");
				case "range_flt":
				  return " SUITEREPORTS.STARTTIME BETWEEN '" + $_("from_flt").value + "' AND '" + $_("to_flt").value +" 23:59:59'" ;
				case "time_taken_flt":
					var ms = getMilliseconds(ele.value);
					return ms ? (" SUITEREPORTS.TIMETAKEN " + handleRelationalFilter(ms)) : "";
				case "scripts_run_flt":
					if(_isTCSummary) { return (" SUITEREPORTS.TCCOUNT " + handleRelationalFilter(ele.value)); } //Modifying SQL according to Testcase / Script field and same for passed and failed field
					return (" SUITEREPORTS.TOTALCOUNT " + handleRelationalFilter(ele.value));
				case "passed_flt":
					if(_isTCSummary) { return (" SUITEREPORTS.TCPASSED " + handleRelationalFilter(ele.value)); }	
					return (" SUITEREPORTS.PASSEDCOUNT " + handleRelationalFilter(ele.value));
				case "failed_flt":
					if(_isTCSummary) { return (" SUITEREPORTS.TCFAILED " + handleRelationalFilter(ele.value)); }
					return (" SUITEREPORTS.FAILEDCOUNT " + handleRelationalFilter(ele.value));
				case "status_flt":
					if ($_("script_name_flt").value == "") {
						return (" SUITEREPORTS.STATUS LIKE '%" + ele.value + "%'");
					} else {
						return (" SCRIPTREPORTS.STATUS LIKE '%" + ele.value + "%'");
					}
				
				default:
				  return "";
			}
		
		}
		
		function getMilliseconds(filter_value){
			if (filter_value == "00:00:00 000") return null;
			if ((/^([><\!]=*)?\d+$/).test(filter_value)) return filter_value; // plain number
			if (!((/^([><\!]=*)?[\d: ]+$/).test(filter_value))) return null; // wrong format
			var regex = /(\d\d)[:](\d\d)[:](\d\d) (\d\d\d)$/;
			var m = filter_value.match(regex);
			if (!m) return null;
			var ms = "" + (parseInt(m[1])*60*60*1000 + parseInt(m[2])*60*1000 + parseInt(m[3])*1000 + parseInt(m[4]));
			
			var operator = ""; 
			var m2 = filter_value.match(/^([><\!]=*)/);
			if (m2) operator = m2[1];  
			
			return operator + ms;
		}
		
		function addStrs(str1,str2){ 
			if(str2){
				return str1+str2;
			}
			return "";
		} 
		
	function getPageSize(){
		return jQuery('#pagination_div').pagination('options').pageSize;
	}
		
	function searchSuites(bySql, pageNumber, pageSize){
			if(!pageNumber){
				pageNumber = 1;
			}
			if(!pageSize){
				pageSize = getPageSize();
			}
			if (!bySql) {
				if (dbType == "mssql") {
					if ($_("script_name_flt").value == "") {
						var selectPart1 = "SELECT * FROM (SELECT *,ROW_NUMBER() OVER (/*ORDERBYSTART*//*ORDERBYEND*/ORDER BY RES.STARTTIME DESC) AS ROWNUM FROM (SELECT SUITEREPORTS.STATUS AS ROWSTATUS,SUITEREPORTS.* FROM SUITEREPORTS";
					} else {
						var selectPart1 = "SELECT * FROM (SELECT *,ROW_NUMBER() OVER (/*ORDERBYSTART*//*ORDERBYEND*/ORDER BY RES.STARTTIME DESC) AS ROWNUM FROM (SELECT DISTINCT SCRIPTREPORTS.STATUS AS ROWSTATUS,SCRIPTREPORTS.SCRIPTREPORTID,SCRIPTREPORTS.SCRIPTNAME,SUITEREPORTS.* FROM SUITEREPORTS,SCRIPTREPORTS WHERE SCRIPTREPORTS.SUITEREPORTID=SUITEREPORTS.SUITEREPORTID";
					}
					var selectPart2 = " ) AS RES) AS RESULTS /*LIMITSTART*/";
				} else {
					if ($_("script_name_flt").value == "") {
						var selectPart1 = "SELECT SUITEREPORTS.STATUS AS ROWSTATUS, SUITEREPORTS.* FROM SUITEREPORTS";
					} else {
						var selectPart1 = "SELECT DISTINCT SCRIPTREPORTS.STATUS AS ROWSTATUS, SCRIPTREPORTS.SCRIPTREPORTID,SCRIPTREPORTS.SCRIPTNAME,SUITEREPORTS.* FROM SUITEREPORTS,SCRIPTREPORTS WHERE SUITEREPORTS.SUITEREPORTID=SCRIPTREPORTS.SUITEREPORTID";
					}
					var selectPart2 = " /*ORDERBYSTART*/ ORDER BY SUITEREPORTS.STARTTIME DESC /*ORDERBYEND*/ /*LIMITSTART*/";
				}
				var sql = selectPart1;
				var filters = document.listForm.elements;
				for(var itr=0;itr<filters.length;itr++){
					var child = filters[itr];
					if( child.id == "range_flt" && ( $_("from_flt").value != "yyyy-mm-dd" || $_("to_flt").value != "yyyy-mm-dd") ) { } 	
					else if ( (child.type != "text" && child.type != "select-one") ||  child.value =="" || child.id =="from_flt" || child.id =="to_flt" || child.id =="filter_top_flt") continue;
					if(sql == selectPart1 && $_("script_name_flt").value == ""){
						sql += addStrs(" WHERE ",getFilterQuery(child));
					} else {
						sql += addStrs(" AND ",getFilterQuery(child));
					}
				}
				sql += selectPart2;
				sql += getLimitString(pageNumber, pageSize);
				sql += "/*LIMITEND*/";
				$_("sql").value = sql;
				$_("useSQL").value = "false";
			} else{
				sql = $_("sql").value;
				$_("useSQL").value = "true";
			}
			if(pageNumber && pageSize){
				setPageNumInfo(pageNumber);			
				location.href = "DBReports?sql="+encodeURIComponent(sql)+"&filterInfo="+encodeURIComponent(buildFilterInfo())+
				"&pageNumber="+pageNumber+"&pageSize="+pageSize;
			}
			else
				location.href = "DBReports?sql="+encodeURIComponent(sql)+"&filterInfo="+encodeURIComponent(buildFilterInfo());
		}
		
		function setPageNumInfo(pageNumber){
			$_("pageNumInfo").value = pageNumber;
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
			var useThreshold =  $_("script_name_flt").value == "";
		 for(var counter=1; ;counter++){
		 	var row = $_("row-"+counter);
		 	if(row == null) return;

		  	var status = getStatus(counter);
		  	if (status != "SUCCESS" && status != "FAILURE" && status != "LOAD EXHAUSTED") {
				row.className = "RUNNING";
				continue;
			}
			
			if (status == "LOAD EXHAUSTED") {
				row.className = "FAILURE";
			}
		 	else {
		 		if (!useThreshold) continue;
		 		if (getTotalCount(counter) == 0) continue;
				var pass_pc = getPassedPercent(getPassedCount(counter),getFailedCount(counter));
				if( pass_pc >= getPassThreshold() ){
					if ((status == "FAILURE") && (getPassedCount(counter) + getFailedCount(counter) != getTotalCount(counter))) {
						row.className = "FAILURE";
					} else {
						row.className = "SUCCESS";
					}
				} else{
					row.className = "FAILURE";
				}
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
			var showTCSummaryKey;
			var keys_values = inFilterInfo.split("---");
			if(keys_values.length > 3){
				for(var itr=0;itr<keys_values.length;itr++){
					var key_value = keys_values[itr].split(":::");
					if(key_value[0] == "showTCSummaryKey") {	//adding Testcase and Script toggling functionality
						 showTCSummaryKey =  key_value[1];
						 continue;
					}
					else if(key_value[0] == "filter_top_flt"){
						pageSize = parseInt(key_value[1]);
						initPagination();
					}
					if ($_(key_value[0]))
						$_(key_value[0]).value =key_value[1]; 
				}
			}
			else{
				initPagination();
			}
			
			if($_("useSQL").value == "true"){ // to preserve sql box if sql box was used to filter in previous request
				$_("sql_span").style.display = "block"; 
				$_("toggle_link").innerHTML = "Don't use SQL";
			}
			
			changeRowClassToThreshold();
			
			showGraphs(queryStringObject["graphs"] == "enabled" || $_("graphs").value == "enabled");
			showTCSummary(showTCSummaryKey == "true");	//adding Testcase and Script toggling functionality
		}
		
		function pressEnter(event){
			if (event.keyCode == 13) 
				searchSuites(false);
		}
		
		function showGraphs(b){
			if (b) {
				$_("graphs").value = "enabled";
				$_("graphsDiv").style.display = "block";
				renderColumnLineChart("suite_runs_bar");
				renderAverageBarChart("average_bar");
				renderStackedColumnCharts("stacked_column_chart");
				$_("showGraphsBtn").style.display = "none";
				$_("hideGraphsBtn").style.display = "inline";
			} else {
				$_("graphs").value = "disabled";
				$_("graphsDiv").style.display = "none";
				$_("showGraphsBtn").style.display = "inline";
				$_("hideGraphsBtn").style.display = "none";
			}	
		}
		
		//javascript change - globals
		_isTCSummary = false;
		var ieColor = "893BFF";
		var firefoxColor = "321640";
		var chromeColor = "F88017";
		var safariColor = "690000";
		var defaultColor = "eeccff";
		function getBrowserColor(browserName){
			var color;
			switch(browserName){
						case "ie":
							color = ieColor;
							break;
						case "firefox":
							color = firefoxColor;
							break;
						case "chrome":
							color = chromeColor;
							break;
						case "safari":
							color = safariColor;
							break;
						default:
							color = defaultColor;
					}
				return color;
		}
		
		function showTCSummary(b){	//adding Testcase and Script toggling functionality
			_isTCSummary = b;
			if(b) {
				$_("showScriptBtn").style.display = "inline";
				$_("showTCBtn").style.display = "none";
			} else {
				$_("showScriptBtn").style.display = "none";
				$_("showTCBtn").style.display = "inline";
			}
			
			
			showTCSummaryColumns(b);  //Filtering according to Testcase / Script
		}
		function showTCSummaryColumns(b){
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
					#graphsDiv{background-color:white;}					
					.panel div{
						border-bottom: 0px;
						padding: 0px;
					}
					.panel{
						border-bottom: 0px;
						padding: 0px;
					}
					.easyui-panel{
						border-color: gray;
					}
					
					.pagination-page-list{
						width:	65px;
					}
					
					tr a.visitedmarker {color:white;text-decoration:none;margin-right:10px;}
					tr.SUCCESS a.visitedmarker:link{}
					tr.SUCCESS a.visitedmarker:visited{color:green;}
					tr.SUCCESS a.visitedmarker:hover{}
					tr.SUCCESS a.visitedmarker:active{}

					tr.FAILURE a.visitedmarker:link{}
					tr.FAILURE a.visitedmarker:visited{color:red;}
					tr.FAILURE a.visitedmarker:hover{}
					tr.FAILURE a.visitedmarker:active{}
					
					tr.RUNNING a.visitedmarker:link{}
					tr.RUNNING a.visitedmarker:visited{color:orange;}
					tr.RUNNING a.visitedmarker:hover{}
					tr.RUNNING a.visitedmarker:active{}
					tr.SUCCESS span.inSuiteLink, tr.SUCCESS span.inSuiteLink * {color:#bbb;}
					tr.FAILURE span.inSuiteLink, tr.FAILURE span.inSuiteLink * {color:#dcc;}
					tr.RUNNING span.inSuiteLink, tr.RUNNING span.inSuiteLink * {color:#666;}

</style>
			</head>

			<body onLoad="onLoad()" onresize="pageResize()">
				<div id = "heading" style="float:right;margin-right:20px;">Script Wise Summary</div>
				<div id='navbar'> 
					<a href='/_s_/dyn/pro/DBReports' style="color:black"><b>Root</b></a>
				</div>
				
				<div id="graphsDiv" style="display:none;min-width:1310px;border:1px solid #999; padding:5px;margin-top:-1;">
				<table style="width:100%">
					<tr>
						<td colspan="2"><div id="suite_runs_bar" style="border:none;"></div></td>
					</tr>				
					<tr>
						<td style="width:50%">
							<div id="average_bar" style="border:none;"></div>
						</td>
						<td>
							<div id="stacked_column_chart" style="margin-left: 30px;border:none;"></div>
						</td>
					</tr>
				</table>
				</div>
				
				<xsl:apply-templates />
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="suiteSummaries">
		<script>
			var inFilterInfo='<xsl:value-of select="filter/filterInfo" />';	
			var totalSuite=parseInt('<xsl:value-of select="totalSuite" />');
			var dbType='<xsl:value-of select="dbType" />';		
		</script>

		<form name="listForm" method="POST" action="">
		<input type="hidden" name="pageNumInfo" value="" id="pageNumInfo"/>
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
					Columns available:  SUITENAME, BROWSERTYPE, TIMETAKEN, TOTALCOUNT, PASSEDCOUNT, FAILEDCOUNT, STATUS, USERDEFINEDID, SUITEINFO
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
<select name="pass_threshold" id="pass_threshold" style="width:65px" onkeydown="pressEnter(event)"><!--will be populated on body-load--></select>
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
<input id="showTCBtn" type="button" onclick="showTCSummary(true)" value="Show Testcase Summary" style="width:183px;margin-right:8px"/>
<input id="showScriptBtn" type="button" onclick="showTCSummary(false)" value="Show Script Summary" style="width:183px;display:none;margin-right:8px"/>
</td>
<td>
<table style="float:right">
<tr>
<td><a href="#" style="color:blue;text-decoration:underline;margin:0 10px 0px 0px;" id="toggle_link" value ="Use SQL" onclick="toggleSql()">Use SQL</a></td>
<td style="display:none;">Limit: <input type="text" name ="filter_top_flt" id="filter_top_flt" value="50" size="2" onkeydown="pressEnter(event)"/></td>
<td><input type="button" onclick="searchSuites(false)" value="Filter" style="margin-left:8px"/></td>
<td><input type="button" onclick="document.listForm.reset()" value="Reset filters" style="margin-left:8px"/></td>
</tr>
</table>
</td>

</tr>
</table>
			</td></tr>
			<tr><td>
				<div id="pagination_panel_div" class="easyui-panel">
					<div id="pagination_div" class="easyui-pagination"></div>
				</div>
				<table id="suite_list_table" style="width:100%;background-color:white;overflow:auto;">
					<tr id="filter_row">
					<td style="width:30px;">
					</td>
					<td>
						<input type="text" style="width:100px;" name ="script_name_flt" id="script_name_flt" onkeydown="pressEnter(event)" title="Script"></input>
					</td>
					<td>
						<input type="text" style="width:100px;" name ="suite_name_flt" id="suite_name_flt" onkeydown="pressEnter(event)" title="Suite"></input>
					</td>
					<xsl:choose>
						<xsl:when test="$showUserDefinedId = 'true'">
							<td>
								<input type="text"  name ="user_id_flt" id="user_id_flt" onkeydown="pressEnter(event)"></input>
							</td>
						</xsl:when>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="$showBaseUrl = 'true'">
							<td>
								<input type="text"  name ="base_url_flt" id="base_url_flt" onkeydown="pressEnter(event)"></input>
							</td>
						</xsl:when>
					</xsl:choose>
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
							From</td><td><input type="text" id="from_flt" onkeyup="changeDate()" onkeydown="pressEnter(event)" value="yyyy-mm-dd"></input></td><td>To</td><td>
							<input type="text" id="to_flt" onkeyup="changeDate()" onkeydown="pressEnter(event)" value="yyyy-mm-dd"></input></td>
						</tr></table>
					</td>
					<td style="width:100px;">
						<input type="text" name="time_taken_flt" id="time_taken_flt" onkeydown="pressEnter(event)" title="Format: hour:min:sec milliseconds. =,&lt;,&gt;or!= can be used. eg. &lt;00:02:00 000" value="00:00:00 000"></input>
					</td>
					<td style="width:60px;">
						<input type="text" name="scripts_run_flt" id="scripts_run_flt" style="width:45px;" title="=,&lt;,&gt;or!= can be used. eg. &gt;10" onkeydown="pressEnter(event)"></input>
					</td>
					<td style="width:60px;">
						<input type="text" name="passed_flt" id="passed_flt" style="width:45px;"  title="=,&lt;,&gt;or!= can be used. eg. &gt;10" onkeydown="pressEnter(event)"></input>
					</td>
					<td style="widsth:60px;">
						<input type="text" name="failed_flt" id="failed_flt" style="width:45px;" title="=,&lt;,&gt;or!= can be used. eg. &gt;10" onkeydown="pressEnter(event)"></input>
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
				<td id="ScriptName">Script Name</td>
				<td id="SuiteName">Suite Name</td>
				<xsl:choose>
					<xsl:when test="$showUserDefinedId = 'true'">
						<td id="UserDefinedId">User Defined Id</td>
					</xsl:when>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="$showBaseUrl = 'true'">
						<td id="BaseUrl">Base Url</td>
					</xsl:when>
				</xsl:choose>
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
				<xsl:param name="className" select="ROWSTATUS" />
				<xsl:param name="suitePath" select="SUITEPATH" />
				<xsl:param name="suiteReportId" select="SUITEREPORTID" />
				<xsl:param name="scriptReportId" select="SCRIPTREPORTID" />
				<xsl:param name="suiteName" select="SUITENAME" />
				<xsl:param name="scriptName" select="SCRIPTNAME" />
				<xsl:param name="suiteInfo" select="SUITEINFO" />
				<xsl:param name="baseURL" select="util:fetchInfo(SUITEINFO, 'baseURL')" />

				<tr id="row-{position()}" class="{$className}">
				
				<td><input name="cb_{position()}" type="checkbox" value="{$suiteReportId}" onclick="onCheckClick(this)"/></td>
				<td style="overflow:hidden" colspan="2">
					<xsl:choose>
        				<xsl:when test="util:startsWith(SUITENAME, 'LOAD_')">
        					<a class="visitedmarker" href="/_s_/dyn/pro/DBReports_reconciledReport?id={$suiteReportId}">&#187;</a> 
          					<a id="link-{position()}" href="/_s_/dyn/pro/DBReports_reconciledReport?id={$suiteReportId}"><xsl:value-of select="SUITENAME" /></a>
        				</xsl:when>
		        		<xsl:otherwise>
		        			<xsl:choose>
			        			<xsl:when test="$scriptName != '' and $scriptName != $suiteName">	
				        			<a class="visitedmarker" href="/_s_/dyn/pro/DBReports_scriptReport?id={$scriptReportId}">&#187;</a> 
		        					<a id="link-{position()}" href="/_s_/dyn/pro/DBReports_scriptReport?id={$scriptReportId}"><xsl:value-of select="SCRIPTNAME" /></a>
				        			<br/><span class='inSuiteLink'>(in <a id="link-{position()}" href="/_s_/dyn/pro/DBReports_suiteReport?id={$suiteReportId}&amp;o=list"><xsl:value-of select="SUITENAME" /></a>)</span>
			        			</xsl:when>
			        			<xsl:otherwise>
			        				<a class="visitedmarker" href="/_s_/dyn/pro/DBReports_suiteReport?id={$suiteReportId}&amp;o=list">&#187;</a> 
	        						<a id="link-{position()}" href="/_s_/dyn/pro/DBReports_suiteReport?id={$suiteReportId}&amp;o=list"><xsl:value-of select="SUITENAME" /></a>
			        			</xsl:otherwise>
		        			</xsl:choose>
		        		</xsl:otherwise>
      				</xsl:choose>
					<a id="link-{position()}-tc" href="/_s_/dyn/pro/DBReports_testCaseReport?id={$suiteReportId}&amp;o=list" class="hidden"><xsl:value-of select="SUITENAME" /></a>
					<!-- 
					xsl change
					-->
					
				</td>
				
				<xsl:choose>
					<xsl:when test="$showUserDefinedId = 'true'">					
					<td>
						<xsl:if test="USERDEFINEDID != 'null'">
							<xsl:value-of select="USERDEFINEDID" />
						</xsl:if>
					</td>
					</xsl:when>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="$showBaseUrl = 'true'">					
						<td>
							<xsl:if test="SUITEINFO != 'null'">
								<div style="width:100px;overflow:hidden;text-overflow:ellipsis;border:0;white-space: nowrap" title="{$baseURL}">
									<xsl:copy-of select="$baseURL" />
								</div>
							</xsl:if>
						</td>
					</xsl:when>
				</xsl:choose>
				<!--Retrieve custom field value-->
				<!--<td>
				<xsl:if test="SUITEINFO != 'null'">
					<xsl:value-of select="util:fetchInfo(SUITEINFO, 'customField')" />
				</xsl:if>				
				</td>-->
				<td id="browser-{position()}"><xsl:value-of select="BROWSERTYPE" /></td>
				<td><xsl:value-of select="util:humanTime(STARTTIME)" /></td>
				<td><xsl:value-of select="util:humanTime(ENDTIME)" /></td>
				<td id="timetaken-{position()}"><xsl:value-of select="util:prettyTimeMoreThan24Hours(TIMETAKEN)" /></td>
				 
				<td id="total-{position()}" name="totalScriptCount"><xsl:value-of select="TOTALCOUNT" /></td>
				<td id="passed-{position()}" name="passedScriptCount"><xsl:value-of select="PASSEDCOUNT" /></td>
				<td id="failed-{position()}" name="failedScriptCount"><xsl:value-of select="FAILEDCOUNT" /></td>
			
				<td id="totalTC-{position()}" name="totalTCCount" class="hidden"><xsl:value-of select="TCCOUNT" /></td>
				<td id="passedTC-{position()}" name="passedTCCount" class="hidden"><xsl:value-of select="TCPASSED" /></td>
				<td id="failedTC-{position()}" name="failedTCCount" class="hidden"><xsl:value-of select="TCFAILED" /></td>
				
				<td id="status-{position()}"><xsl:value-of select="ROWSTATUS"/></td>
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
				
				function ifNotCounterExists(counter){
					return $_("browser-"+counter) == null;
				}
				
				var numberOfRows = function (){ 
					for(var counter=1;;counter++){
						if(ifNotCounterExists(counter)) break;
					}
					return counter-1;
				}();
				
				function getStatus(counter){
					var el = $_("status-"+counter);
					return el ? el.innerHTML : 'RUNNING';
				}
				
				function getSuiteName(counter){ 
					return $_("link-"+counter).innerHTML;
				}
				
				function getBrowserType(counter){
					return $_("browser-"+counter).innerHTML;
				}
				
				function getLinkHref(counter){
					return $_("link-"+counter).href;
				}
				
				function getCount(elId) {
					var el = $_(elId);
					if (!el) return 0;
					var t = el.innerHTML;
					return isNaN(t) ? 0 : parseInt(t);
				}
				
				function getScriptCount(counter){
					return getCount("total" + (_isTCSummary ? "TC" : "") + "-"+counter);
				}
				
				function getTotalCount(counter){
					return getCount("total" + (_isTCSummary ? "TC" : "") + "-"+counter);
				}
				
				function getPassedCount(counter){
					return getCount("passed" + (_isTCSummary ? "TC" : "") + "-"+counter);
				}
				
				function getFailedCount(counter){
					return getCount("failed" + (_isTCSummary ? "TC" : "") + "-"+counter);
				}
				
				function getTimeTaken(counter){
					var time_str = $_("timetaken-" + counter).innerHTML;
					if (time_str == "null") return 0;
					var time_arr = time_str.split(" ");
					var split_arr = time_arr[0].split(":");
					return parseInt(split_arr[2]) + parseInt(split_arr[1])*60 + parseInt(split_arr[0])*60*60;
				}
				
				function getPassThreshold(){
					return $_("pass_threshold").value;
				}
				
				function hasRunPassedThreshold(counter){
					return hasClass($_("row-"+counter),"SUCCESS");
				}
				
// ------ COLUMN + LINE GRAPH STARTS ------
				
				function renderColumnLineChart(containerDiv) {
					var argXML = getColumnLineChartHeader();
					argXML += getDataColumnLineChartXML();
					argXML += getColumnLineChartFooter();
					var myChart = new FusionCharts( "/_s_/spr/charts/swf/FCF_MSColumn2DLineDY.swf","myChartId", "1300", "400");
	      			myChart.setDataXML(argXML,"xml");
	     	 		myChart.render(containerDiv);
				}
				
				function getColumnLineChartHeader(){
					return "<graph caption=' ' showColumnShadow='0' showShadow='0' showNames='0' xAxisName='Suite Runs Over Time-->' PYAxisName='Script Count' SYAxisName='Time Taken' canvasBorderThickness='0' hovercapbg='FFFFDD' formatNumberScale='0' decimalPrecision='0' showvalues='0' animation='0' numdivlines='4' PYAxisMaxValue='5' numVdivlines='0' lineThickness='2' rotateNames='1' lineAlpha='100'>";
				}
				
				function getColumnLineChartFooter(){
					return "</graph>";
				}
				
				function getDataColumnLineChartXML() {
					var categoriesXml = "<categories>";
					var dataTotalXml = "<dataset seriesname='' parentYAxis='P'>";
					var dataPassedXml = "<dataset seriesname='Passed' color='BBE18E' parentYAxis='P'>";
					var dataFailedXml = "<dataset seriesname='Failed' color='ff0000' parentYAxis='P'>";
					var timeTakenXml = "<dataset seriesname='Time Taken' numberSuffix=' secs' color='0000FF' parentYAxis='S' anchorRadius='3' anchorSides='6'>";
					
					for(counter = numberOfRows;counter>=1;counter--){
						categoriesXml += getCategoryXml(counter);
						dataTotalXml += getCountXml(counter);
						dataPassedXml += getPassedXml(counter);
						dataFailedXml += getFailedXml(counter);
						timeTakenXml += getTimeTakenXml(counter);
					}
					categoriesXml += "</categories>";
					dataTotalXml += "</dataset>";
					dataPassedXml += "</dataset>";
					dataFailedXml += "</dataset>";
					timeTakenXml += "</dataset>";

					return categoriesXml+dataPassedXml+dataTotalXml+dataFailedXml+timeTakenXml;
				}
				
				function getCategoryXml(counter){
					return "<category name='"+ getSuiteName(counter) +" on "+ getBrowserType(counter).toUpperCase() + "' />";
				}
				
				function getCountXml(counter){
					var color = getBrowserColor(getBrowserType(counter));
					return "<set value='" + getTotalCount(counter) + "' link='" + getLinkHref(counter) + "' color='"+color+"'/>";
				}
				
				function getPassedXml(counter){
					return "<set value='" + getPassedCount(counter) + "' link='" + getLinkHref(counter) + "'/>";
				}
				
				function getFailedXml(counter){
					return "<set value='" + getFailedCount(counter) + "' link='" + getLinkHref(counter) + "'/>";
				}
				
				function getTimeTakenXml(counter){
					return "<set value='" + getTimeTaken(counter) + "'/>";
				}
				
// ------ COLUMN + LINE GRAPH ENDS ------				
				
// ------ AVERAGE BAR GRAPH STARTS ------
				
				function renderAverageBarChart(containerDiv){
					var barXML = getAverageBarHeader();
					barXML += getAverageBarXML();
					barXML += getAverageBarFooter();
					var myChart = new FusionCharts( "/_s_/spr/charts/swf/FCF_Column2D.swf ","myChartId3", "600", "400");
	      			myChart.setDataXML(barXML,"xml");
	     	 		myChart.render(containerDiv);
				}
				
				function getAverageBarHeader(){
					return "<graph caption='Average Time Taken By Different Browsers' chartLeftMargin='50' chartBottomMargin='38' yaxisname='Average Time Taken' xaxisname='Browser Type' canvasBorderThickness='0' hovercapbg='FFFFDD' numdivlines='0' numberSuffix=' secs' showColumnShadow='0' decimalPrecision='0' animation='0'>";
				}
				
				function getAverageBarFooter(){
					return "</graph>";
				}
				
				function getAverageBarXML(){
					var browserTimeCountObj = makeEmptyBrowserTimeCountObject();
					fillBrowserTimeCountObject(browserTimeCountObj);
					var xml="";
					var overallAverage = 0 ;
					var overallCount = 0; 
					for(var browserType in 	browserTimeCountObj){
						var average = parseInt(parseInt(browserTimeCountObj[browserType].totalTime) / parseInt(browserTimeCountObj[browserType].count));
						overallAverage += average;
						overallCount++;
						xml += "<set name='"+browserType+"' value='"+average+"' color='"+getBrowserColor(browserType)+"'/>"; 
					}
					var trendlineXML = "<trendlines>";
					trendlineXML += "<line startvalue='"+parseInt(overallAverage/overallCount)+"' displayValue='Avg: "+parseInt(overallAverage/overallCount)+" secs' color='0000FF' thickness='1' showOnTop='1' isTrendZone='0'/>";
					trendlineXML += "</trendlines>";
					xml += trendlineXML;
					return xml;
				}
				
				function makeEmptyBrowserTimeCountObject() {
					var browserTypes = getBrowserTypes();
					var browserTimeCount = {}
					for (var i = 0; i < browserTypes.length; i++) {
 						 if (browserTypes[i] != null) {
							    browserTimeCount[browserTypes[i]] = { totalTime : 0, count : 0 };  //[totaltime,count]
						  }
					}
					return browserTimeCount;
				}
				
				function getBrowserTypes() {
					var browserTypesArr = [];
					for(counter = numberOfRows;counter>=1;counter--){
						var browser = getBrowserType(counter);
						if(findInObjectArray(browserTypesArr, browser) == -1) browserTypesArr.push(browser);
					}
					return browserTypesArr;
				}
				
				function findInObjectArray(ar, el) {
				  var len = ar.length;
				  for (var i = 0; i < len; i++) {
					  if (ar[i].text == el) return i;
				  }
				  return -1;
			 	};
				
				function fillBrowserTimeCountObject(browserTimeCount) {
					for(counter = 1;counter<=numberOfRows;counter++){
						var status = getStatus(counter);
						if(status != "RUNNING"){
							var browserType = getBrowserType(counter);
							var timeTaken = getTimeTaken(counter);
							browserTimeCount[browserType].totalTime += timeTaken;
							browserTimeCount[browserType].count++; 
						}
					}
				}

// ------ AVERAGE BAR GRAPH ENDS ------				

// ------ STACKED COLUMN GRAPH STARTS ------
				
				function renderStackedColumnCharts(containerDiv){
					var obj = getXMLDataPointsObjStackedCol();
					var stackedColXML = getStackedColumnHeader();
					stackedColXML += getStackedColumnXML(obj);
					stackedColXML += getStackedColumnFooter();
					var myChart = new FusionCharts( "/_s_/spr/charts/swf/FCF_StackedColumn2D.swf","myChartId", "500", "400");
	      			myChart.setDataXML(stackedColXML,"xml");
	     	 		myChart.render(containerDiv);
				}
				
				function getStackedColumnHeader(){
					return "<graph caption='Success Percentage By Different Browsers' chartLeftMargin='5' xaxisname='Browser Type' yaxisname='Script Count' canvasBorderThickness='0' hovercapbg='FFFFDD' showColumnShadow='0' animation='0' numdivlines='3' YAxisMaxValue='4' decimalPrecision='0'>";
				}
				
				function getStackedColumnFooter(){
					return "</graph>";
				}
				
				function getStackedColumnXML(obj){
					var categoriesXml = "<categories>";
					var data25Xml = "<dataset seriesname='0-25%' color='ff4415'>";
					var data50Xml = "<dataset seriesname='26-50%' color='FFA62F'>";
					var data75Xml = "<dataset seriesname='51-75%' color='EDDA74'>";
					var data90Xml = "<dataset seriesname='76-90%' color='ffff15'>";
					var data99Xml = "<dataset seriesname='91-99%' color='99ff99'>";
					var data100Xml = "<dataset seriesname='100%' color='008000' >";
					
					for(browser in obj){
						categoriesXml += getStackedColCategoryXml(browser);
						data25Xml += get25Xml(obj[browser]["0-26"]);
						data50Xml += get50Xml(obj[browser]["26-51"]);
						data75Xml += get75Xml(obj[browser]["51-76"]);
						data90Xml += get90Xml(obj[browser]["76-91"]);
						data99Xml += get99Xml(obj[browser]["91-100"]);
						data100Xml += get100Xml(obj[browser]["100-101"]);
					}
					categoriesXml += "</categories>";
					data25Xml += "</dataset>";
					data50Xml += "</dataset>";
					data75Xml += "</dataset>";
					data90Xml += "</dataset>";
					data99Xml += "</dataset>";
					data100Xml += "</dataset>";

					return categoriesXml+data25Xml+data50Xml+data75Xml+data90Xml+data99Xml+data100Xml;
				}
				
				function getStackedColCategoryXml(browser){
					return "<category name='"+ browser +"'/>";
				}
				
				function get25Xml(val){
					return "<set value='"+ val +"'/>";
				}
				
				function get50Xml(val){
					return "<set value='"+ val +"'/>";
				}
				
				function get75Xml(val){
					return "<set value='"+ val +"'/>";
				}
				
				function get90Xml(val){
					return "<set value='"+ val +"'/>";
				}
				
				function get99Xml(val){
					return "<set value='"+ val +"'/>";
				}
				
				function get100Xml(val){
					return "<set value='"+ val +"'/>";
				}
				
				function getXMLDataPointsObjStackedCol(){
					var obj = {};
					var num_keys = [0,26,51,76,91,100,101];
					var str_keys = getPieRangeStringArray(num_keys);
					for(var counter=1;counter<=numberOfRows;counter++){ 	
					 	var browser = getBrowserType(counter);
					 	var pass_pc = Math.floor(getPassedPercent(getPassedCount(counter),getFailedCount(counter)));
					 	pushIfKeyNotExists(obj, browser,str_keys);
					 	var str_key = getStrKeyForValue(num_keys,pass_pc);
					 	obj[browser][str_key] +=1;
					}
					return obj;
				}
				
				function getPieRangeStringArray(pass_range){
					// in : [pass_array,fail_array] , out : [pass_array_strs,fail_array_strs]
					var pass_range_strs = [];
					for(var itr=1; itr<pass_range.length; itr++){
						pass_range_strs.push(pass_range[itr-1] + '-' + pass_range[itr] );
					}
					return pass_range_strs;				
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
				
				function getStrKeyForValue(num_keys,value){
					for(var itr=1; itr<num_keys.length; itr++){
						if(value<num_keys[itr]) return num_keys[itr-1]+'-'+num_keys[itr];
					}
				}
				
// ------ STACKED COLUMN GRAPH ENDS ------
				
				function initPagination(){
					jQuery('#pagination_div').pagination({
					    total:totalSuite,
					    pageList:[50,100,200,500,1000],
					    pageSize:pageSize
					});
					attachIdsToPaginationEls();
					var pageNum = isNaN(parseInt(document.getElementById("pageNumInfo").value)) ? 1:parseInt(document.getElementById("pageNumInfo").value)
					jQuery('#pagination_div').pagination('select', pageNum);
					jQuery('#pagination_div').pagination({
					    onSelectPage:function(pageNumber, pageSize){
					    	$_("filter_top_flt").value = pageSize;
							jQuery(this).pagination('loading');
							jQuery(this).pagination('loaded');
							searchSuites(false, pageNumber, pageSize);
						}
					});
				}
				
				function attachIdsToPaginationEls(){
					var allSelect = document.getElementsByTagName("SELECT");
					for(var i=0; i<allSelect.length; i++){
						var select = allSelect[i];
						var selectClass = select.className;
						if(selectClass == "pagination-page-list"){
							select.id = "pageSize_select_id";
							break;
						}
					}
					var allInput = document.getElementsByTagName("INPUT");
					for(var i=0; i<allInput.length; i++){
						var input = allInput[i];
						var inputClass = input.className;
						if(inputClass == "pagination-num"){
							input.id = "pageNumber_input_id";
							break;
						}
					}
				}
				
				function pageResize(){
					jQuery('#pagination_panel_div').panel('resize');
				}
				
				]]>
		</script>


	</xsl:template>

</xsl:stylesheet>
