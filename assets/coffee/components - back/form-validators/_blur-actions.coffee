###*
 * Action related to input blur event
 * Supported actions
 * 		v-fixed:	Convert number to fixed decimal
 * 		v-min, v-max, v-gte, v-gt, v-lte, v-lt: Compare numbers
 * 		v-match="regex" use a regex to match value
 * 		v-type="" : Check for predefined type
 * 				empty, email, number, 
 *
 * ::vAdd::call(element, value, param)
###
###* TRIM ###
'v-trim': (value)-> value.trim()
###* REGEX ###
'v-regex': (value, param)->
	throw false unless (new RegExp param).test value
	return value

###* NUMBERS COMPARE, FILES COUNT ###
<% function _validatorCompare(expr){ %>(value, param)->
	vl= +param
	throw "Illegal param: #{param}" if isNaN(vl)
	if @type is 'file'
		result= (@[F_FILES_LIST] or @files)?.length
		throw no if <%-expr %>
	else
		result= +value
		throw no if isNaN(result) or <%-expr %>
	return value
<% } %>
'v-max':	<% _validatorCompare('result > vl') %>
'v-lte':	<% _validatorCompare('result > vl') %>
'v-lt':		<% _validatorCompare('result >= vl') %>

'v-min':	<% _validatorCompare('result < vl') %>
'v-gte':	<% _validatorCompare('result < vl') %>
'v-gt':		<% _validatorCompare('result <= vl') %>

###* FILE MAX SIZE ###
<% function _validatorBytes(expr){ %>(value, param)->
	# Prepare param
	param= param.toLowerCase()
	if param is 'infinity'
		bytes= Infinity
	else
		bytes= Core.toBytes param
		throw new Error "Illegal param: #{param}" unless bytes?
	# Check
	if (@type is 'file') and (files= @[F_FILES_LIST] or @files)
		total= 0
		for f in files
			total+= f.size
		throw false if <%- expr %>
	return value
<% } %>
'v-max-bytes': <% _validatorBytes('total > bytes') %>
'v-min-bytes': <% _validatorBytes('total < bytes') %>

###* EACH FILE MAX/MIN BYTES ###
<% function _validatorEachBytes(expr){ %>(value, param)->
	# Prepare param
	param= param.toLowerCase()
	if param is 'infinity'
		bytes= Infinity
	else
		bytes= Core.toBytes param
		throw new Error "Illegal param: #{param}" unless bytes?
	# Check
	if (@type is 'file') and (files= @[F_FILES_LIST] or @files)
		for f in files
			throw false if <%- expr %>
	return value
<% } %>
'v-each-max-bytes': <% _validatorEachBytes('f.size > bytes') %>
'v-each-min-bytes': <% _validatorEachBytes('f.size < bytes') %>

###* TYPE VALIDATION ###
'v-type': (value, param, component)->
	param= param.trim().toLowerCase()
	return value unless param
	for tp in param.split(/[\s,]+/)
		continue unless tp
		op= component.type._vTypes[tp]
		throw new Error "Unknown type: #{tp}" unless op
		return value if op.call this, value, component
	throw no

# Cb
'v-cb': (value, param, component)->
	param= param.trim()
	return value unless param
	parts= param.split /\s+/
	fxName= part[0].toLowerCase()
	fx= component.type._vCb[fxName]
	throw new Error "Unknown validation callback: #{fxName}" unless fx
	return fx.call this, value, parts, component

###* FIXED ###
'v-fixed': (value, param)->
	fixed= parseInt param
	throw new Error "v-fixed:: Illegal param: #{param}" if isNaN fixed
	result= parseFloat value
	throw no if isNaN result
	return value.toFixed fixed

'v-checked': (value, param)->
	throw no unless @checked
	return value
