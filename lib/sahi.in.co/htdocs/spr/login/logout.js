function logout(){
	sahiSendToServer("/_s_/dyn/pro/UserUI_logout");
	window.location.reload();
}

function showLogoutIfUserLoggedIn(){
	var isLoggedIn  = "true" == sahiSendToServer("/_s_/dyn/pro/UserUI_isUserLoggedIn");
	if(isLoggedIn) document.getElementById('logout').style.display = "inline";
}