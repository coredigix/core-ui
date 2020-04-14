###*
 * Parmas for the precompilator
 * TO change app params, goto: assets/app/config.coffee
###
<%
var port= 3020;
var baseURL= isProd? 'https://core-ui.gridfw.com/': `http://localhost:${port}/`
%>

###* PARAMS ###
isProd:		<%-isProd %>
appVersion: 0	# Used to bypasse navigator & proxy caches for served client files

port:		'<%-port %>'
baseURL:	'<%-baseURL %>'
basePATH:	'<%-new URL(baseURL).pathname %>'

appName:	'Core-ui' # Add your app name
author:		'Coredigix'	# Add your name here
email:		'hello@coredigix.com'	# Add your email here
appCategory: 'website'
themeColor:	'#282828' # Add your app theme color
copyright:	(new Date()).getFullYear()


###*
 * CACHE in production mode
###
publicFilesMaxAge: '7d' # Public files max age


###*
 * Add your google analytics id here
###
analytics: ''