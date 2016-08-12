<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:util="in.co.sahi.util.XSLUtils" 
version="1.0">
	<xsl:output method="html" indent="yes" />
	<xsl:template match="/">
		<html>
		<link rel="stylesheet" type="text/css" href="http://gramam/demo/webinar/flexigrid.pack.css" />
		<script src="http://gramam/demo/webinar/jquery.js"></script>
		<script src="http://gramam/demo/webinar/flexigrid.js"></script>
		<script>
		<![CDATA[		
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
		]]>
		</script>
			<head>
				<meta http-equiv="content-type" content="text/html; charset=UTF-8" />
								<style>
					xdiv{border:1px solid white;border-bottom:1px solid gray;padding:1px}
					xa{text-decoration:none;color:white;}
					xa.INFO{color:black}
					xa.START,a.STOP{color:black;font-weight:bold;}
					xdiv.INFO{background-color:white}
					xdiv.SUCCESS{background-color:green;color:white}
					xdiv.FAILURE,div.ERROR{background-color:red;color:white}
					xa.CUSTOM, a.CUSTOM2, a.CUSTOM4{color:black}
					xdiv.CUSTOM{background-color:yellow;}
					xdiv.CUSTOM1{background-color:orange;}
					xdiv.CUSTOM2{background-color:#EFEFEF;}
					xdiv.CUSTOM3{background-color:green;}
					xdiv.CUSTOM4{background-color:violet;}
					xdiv.CUSTOM5{background-color:indigo;}
					xa.SCRIPT{text-decoration:underline;}
					xspan.extra{color:#CCC;}
					xdiv.SKIPPED{background-color:#eed;}
					xa.SKIPPED{color:gray;}
				
					xtable{border-top:1px solid gray;border-right:1px solid
					xgray;border-spacing:0px;border-collapse:collapse;}
					xtd{border-bottom:1px solid gray;border-left:1px solid
					xgray;padding:5px;text-align:right;}
					xtd a.SCRIPT{float:left;}
					xtr.FAILURE{background-color:red;color:white;}
					xtr.SUCCESS{background-color:green;color:white;}
					xtr.RUNNING{background-color:orange;color:black;}
					xtr.INITIAL a{color:black;}
					xtr a{color:white;text-decoration:underline;}
					xtr.RUNNING a {color:black;}
					
					body *{font-family:verdana;font-size:10pt;}
					body {margin:10px; background-color:lightyellow;}
</style>
			</head>

			<body>
				<div id='navbar'> 
					<a href='/_s_/dyn/pro/DBReports' style="color:black">Root</a>
				</div><br/>
				<xsl:apply-templates />
			</body>
		</html>
	</xsl:template>
	
	<xsl:template match="suiteSummaries">
		<div style="margin-bottom:10px;border:0px;">
		<input type="button" onclick="deleteSuites()" value="Delete"/>
		</div>
		<form name="listForm" method="POST" action="">
		<table id="listing" style="background-color:white;min-width:1024px;">
		<tr>
		<td><input id="checkAllCB" type="checkbox" value="" onclick="checkAll(this.checked)"/></td>
		<td>Suite Name</td>
		<td>User Defined Id</td>
		<td>Browser</td>
		<td>Start Time</td>
		<td>End Time</td>
		<td>Time Taken</td>
		<td>Scripts Run</td>
		<td>Passed</td>
		<td>Failed</td>
		<td>Status</td>
		</tr>
		<xsl:for-each select="suiteSummary">
		<xsl:param name="className" select="STATUS" />
		<xsl:param name="suitePath" select="SUITEPATH" />
		<xsl:param name="suiteReportId" select="SUITEREPORTID" />
		<xsl:param name="suiteName" select="SUITENAME" />

		<tr class="{$className}">
		<td><input name="cb_{position()}" type="checkbox" value="{$suiteReportId}" onclick="onCheckClick(this)"/></td>
		<td>
			<a href="/_s_/dyn/pro/DBReports_suiteReport?id={$suiteReportId}&amp;o=list"><xsl:value-of select="SUITENAME" /></a>
		</td>
		<td>
		<xsl:if test="USERDEFINEDID != 'null'">
			<xsl:value-of select="USERDEFINEDID" />
		</xsl:if>
		</td>
		<td><xsl:value-of select="BROWSERTYPE" /></td>
		<td><xsl:value-of select="util:humanTime(STARTTIME)" /></td>
		<td><xsl:value-of select="util:humanTime(ENDTIME)" /></td>
		<td><xsl:value-of select="TIMETAKEN" /></td>
		<td><xsl:value-of select="TOTALCOUNT" /></td>
		<td><xsl:value-of select="PASSEDCOUNT" /></td>
		<td><xsl:value-of select="FAILEDCOUNT" /></td>
		<td><xsl:value-of select="STATUS" /></td>
		</tr>
		</xsl:for-each>
		</table>
		</form>
		<script>
		<![CDATA[
		window.onload = function(){
		$('#listing').flexigrid({title: "Sahi Pro Reports", height:400, usepager: true, useRp: true,rp: 10,});
		};
		]]>
		</script>

	</xsl:template>

</xsl:stylesheet>