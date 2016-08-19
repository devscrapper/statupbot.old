jQuery(function(){
	jQuery.ajax({
		  url: "/_s_/dyn/pro/UserUI_getAllUsers",
		  context: document.body
	  }).done(function(data) {
		  var json = eval("(" + data + ")");
		  createDefaultUser(json);
	  });
	  if(sahiSendToServer("/_s_/dyn/pro/UserUI_isRemoteAccessLoginFeatureEnabled") == "true")
		  document.getElementById("enableOrDisableLogin").checked = true;
});

function setLoginFeatureEnable(checked){
	sahiSendToServer("/_s_/dyn/pro/UserUI_setloginFeatureEnableDisable?value="+checked);
}

function editUser(){
	var user = document.getElementById('uid').value;
	var password = document.getElementById('pid').value;
	var password2 = document.getElementById('pid2').value;
	var errorDiv = document.getElementById("errorMessage_modal");
	var message = null;
	if (password == "") {
		message = "Password field can not be blank!"
			errorDiv.style.color = "red";
	} else if (password != password2) {
		message = "Password do not match.";
		errorDiv.style.color = "red";
	} else{
		var status = sahiSendToServer("/_s_/dyn/pro/UserUI_editUser?user="+encodeURIComponent(user) +"&password="+encodeURIComponent(password));
		if (status == "true") {
			message = "Password changed successfully."
			errorDiv.style.color = "green";
			document.getElementById('pid').value = "";
			document.getElementById('pid2').value = "";
		} else {
			message = status;
			errorDiv.style.color = "red";
		}
	}
	errorDiv.innerHTML = message;
	errorDiv.style.display = "block";
}

function createDefaultUser(json){
	if(json.length == 0) {
		sahiSendToServer("/_s_/dyn/pro/UserUI_registerUser?user="+encodeURIComponent("admin")+"&password="+encodeURIComponent("password"));
	}
}