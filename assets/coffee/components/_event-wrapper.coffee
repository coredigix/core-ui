###*
 * Event wrapper
###
class EventWrapper
	constructor: (isSync, eventName, customEvent, event, eventPath, currentTarget, component, target)->
		@isPassive= @isAsync= !isSync # is event passive (async)
		@originalEvent= event
		@type= customEvent		# custom event type
		@originalType= eventName # native event type
		# target
		@target= target
		@realTarget= event.target
		@currentTarget= currentTarget
		@component=	component
		@path= eventPath
		# flags
		@bubbles= true
		@bubblesImmediate= yes
		return

	### HELPERS ###
	stopPropagation: ->
		@bubbles= off
		this # chain
	stopImmediatePropagation: ->
		@bubbles= off
		@bubblesImmediate = off
		this # chain

	###* GETTERS ONCE ###
	```
	<% ['altKey', 'ctrlKey', 'shiftKey', 'timeStamp', 'which', 'x', 'y'].forEach(function(el){ %>
	get <%-el %>(){
		var v= this.originalEvent.<%-el %>;
		_defineProperty(this, '<%-el %>', {value:v});
		return v;
	}
	<% }); %>
	```