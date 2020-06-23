###*
 * Mime types
###
MIME_TYPES=
	json		: 'application/json'
	xml			: 'application/xml'
	urlencoded	: 'application/x-www-form-urlencoded'
	text		: 'text/plain'
	multipart	: 'multipart/form-data'

EMAIL_REGEX= /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
TEL_REGEX=	/^[0+][\d\s-]{5,}$/
IS_NUMBER= /^\d+$/
HEX_REGEX= /^[\da-f]+$/i

###*
 * SYMBOLS
###
F_FILES_LIST=	Symbol('files')

