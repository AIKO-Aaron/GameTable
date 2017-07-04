function postRequestAsync(data, clbck) { // Send data to server
	var http = new XMLHttpRequest();
	http.onreadystatechange = function() {
		if(clbck != null && http.readyState == 4 && (http.status == 200 || http.status == 324)) clbck(http.responseText);
	};
	http.open("POST", "http://" + window.location.host, true);
	http.send(data + "\r\n");
	
	return http;
}