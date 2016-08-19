function login(){
	var user = jQuery('#user').textbox('getText');
	var password = jQuery('#password').textbox('getText');
	var message = "";
	if(user == ""){
		message = "User field can not be blank!";
	}
	else if(password == ""){
		message = "Password field can not be blank!";
	}
	if(message != ""){
		setErrorMessage(message);
		return;
	}
	message = sahiSendToServer("/_s_/dyn/pro/UserUI_validateUserForLogin?user="+encodeURIComponent(user)+"&password="+encodeURIComponent(password));
	if(message != ""){
		setErrorMessage(message);
		return;
	}
	
	if (location.href.indexOf("login.htm") != -1) {
		location.href = "/_s_/spr/editor/editor.html";
	} else {
		location.reload();
	}
}

function setErrorMessage(message){
	var errorDiv = document.getElementById("errorMessage");
	errorDiv.style.display = "block";
	errorDiv.innerHTML = message;
}
