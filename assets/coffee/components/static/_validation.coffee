###*
 * Add validation attributes
 * You chould call a component method, we keep using functions for performance reason
 * @example
 * 	::vSet('v-trim', function(value, element, args){return value.trim()})
 * 	::vSet('v-type', function(value, element, args){return this.vType(value, element, args)})
###
@vSet: (attrName, handler)->
	throw new Error 'Illegal arguments' unless arguments.length is 2 and typeof attrName is 'string' and typeof handler is 'function'
	@prototype._vAttrs[attrName.toLowerCase()]= handler
	this # chain
