/**
 * Pug runtime
 */
var pug_match_html=/["&<>]/;
var pug_has_own_property=Object.prototype.hasOwnProperty;
var pug={
	escape:function(e){var a=""+e,t=pug_match_html.exec(a);if(!t)return e;var r,c,n,s="";for(r=t.index,c=0;r<a.length;r++){switch(a.charCodeAt(r)){case 34:n="&quot;";break;case 38:n="&amp;";break;case 60:n="&lt;";break;case 62:n="&gt;";break;default:continue;}c!==r&&(s+=a.substring(c,r)),c=r+1,s+=n;}return c!==r?s+a.substring(c,r):s;},
	rethrow:function(n,e,r,t){if(!(n instanceof Error))throw n;if(!("undefined"==typeof window&&e||t))throw n.message+=" on line "+r,n;try{t=t||require("fs").readFileSync(e,"utf8");}catch(e){pug.rethrow(n,null,r);}var i=3,a=t.split("\n"),o=Math.max(r-i,0),h=Math.min(a.length,r+i),i=a.slice(o,h).map(function(n,e){var t=e+o+1;return(t==r?"  > ":"    ")+t+"| "+n;}).join("\n");throw n.path=e,n.message=(e||"Pug")+":"+r+"\n"+i+"\n\n"+n.message,n;},
	attr:function(t,e,n,f){return!1!==e&&null!=e&&(e||"class"!==t&&"style"!==t)?!0===e?" "+(f?t:t+'="'+t+'"'):("function"==typeof e.toJSON&&(e=e.toJSON()),"string"==typeof e||(e=JSON.stringify(e),n||-1===e.indexOf('"'))?(n&&(e=pug.escape(e))," "+t+'="'+e+'"'):" "+t+"='"+e.replace(/'/g,"&#39;")+"'"):"";},
	classes:function(s,r){return Array.isArray(s)?pug.classes_array(s,r):s&&"object"==typeof s?pug.classes_object(s):s||"";},
	classes_array:function(r,a){for(var s,e="",u="",c=Array.isArray(a),g=0;g<r.length;g++)(s=pug.classes(r[g]))&&(c&&a[g]&&(s=pug.escape(s)),e=e+u+s,u=" ");return e;},
	classes_object:function(r){var a="",n="";for(var o in r)o&&r[o]&&pug_has_own_property.call(r,o)&&(a=a+n+o,n=" ");return a;},
	merge:function(e,r){if(1===arguments.length){for(var t=e[0],g=1;g<e.length;g++)t=pug.merge(t,e[g]);return t;}for(var l in r)if("class"===l){var n=e[l]||[];e[l]=(Array.isArray(n)?n:[n]).concat(r[l]||[]);}else if("style"===l){var n=pug.style(e[l]);n=n&&";"!==n[n.length-1]?n+";":n;var a=pug.style(r[l]);a=a&&";"!==a[a.length-1]?a+";":a,e[l]=n+a;}else e[l]=r[l];return e;},
	style:function(r){if(!r)return"";if("object"==typeof r){var t="";for(var e in r)pug_has_own_property.call(r,e)&&(t=t+e+":"+r[e]+";");return t;}return r+"";},
	attrs:function(t,r){var a="";for(var s in t)if(pug_has_own_property.call(t,s)){var u=t[s];if("class"===s){u=pug.classes(u),a=pug.attr(s,u,!1,r)+a;continue;}"style"===s&&(u=pug.style(u)),a+=pug.attr(s,u,!1,r);}return a;}
};