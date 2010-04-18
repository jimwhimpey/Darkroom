// javascript:var%20url%20=%20document.location.href;if%20(url.match(/flickr\.com\/photos/[0-9a-zA-Z]+\/?$/ig))%20{var%20heading%20=%20document.body.getElementsByTagName(%22h1%22)[0].innerHTML;var%20split%20=%20heading.split(%22%27%22,%201);var%20username%20=%20split[0];var%20username%20=%20username.replace(/^\s*/,%20%27%27).replace(/\s*$/,%20%27%27);var%20username%20=%20username.replace(/\s/gi,%20%27+%27);window.location%20=%20%22http://darkroom.heroku.com/photos/%22%20+%20username;}%20else%20if%20(url.match(/flickr\.com\/photos/[0-9a-zA-Z]+\/sets/[0-9]+\/?$/ig))%20{var%20setID%20=%20url.match(/[0-9]+/gi)[0];var%20crumbs%20=%20document.getElementById(%22setCrumbs%22);var%20username%20=%20crumbs.getElementsByTagName(%22a%22)[0].innerHTML;var%20username%20=%20username.replace(/^\s*/,%20%27%27).replace(/\s*$/,%20%27%27);var%20username%20=%20username.replace(/\s/gi,%20%27+%27);window.location%20=%20%22http://darkroom.heroku.com/photos/%22%20+%20username%20+%20%22/sets/%22%20+%20setID;}
var url = document.location.href;
if (url.match(/flickr\.com\/photos\/[a-zA-Z0-9]+\/?$/ig)) {
	// We're on a photos page. Find their username.
	var heading = document.body.getElementsByTagName("h1")[0].innerHTML;
	var split = heading.split("'", 1);
	var username = split[0];
	var username = username.replace(/^\s*/, '').replace(/\s*$/, ''); 
	var username = username.replace(/\s/gi, '+');
	window.location = "http://darkroom.heroku.com/photos/" + username;
} else if (url.match(/flickr\.com\/photos\/[a-zA-Z0-9]+\/sets\/[0-9]+\/?$/ig)) {
	// We're on a set page, we need the username and the set ID
	var setID = url.match(/[0-9]+/gi)[0];
	var crumbs = document.getElementById("setCrumbs");
	var username = crumbs.getElementsByTagName("a")[0].innerHTML;
	var username = username.replace(/^\s*/, '').replace(/\s*$/, ''); 
	var username = username.replace(/\s/gi, '+');
	window.location = "http://darkroom.heroku.com/photos/" + username + "/sets/" + setID;
}