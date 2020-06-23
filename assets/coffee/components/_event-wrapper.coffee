###*
 * Event wrapper
###
class EventWrapper
	constructor: (eventName, event, currentTarget, target, isSync)->
		@originalEvent= event
		@type= eventName
		@isSync= isSync
		# TARGET
		@target= target
		@realTarget= event.realTarget or event.target
		@currentTarget= currentTarget
		# FLAGS
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

	###* GETTERS ###
	```
	<% ['altKey', 'ctrlKey', 'metaKey', 'shiftKey', 'isTrusted', 'offsetX', 'offsetY', 'timeStamp', 'which'].forEach(function(el){ %>
	get <%-el %>(){ return this.originalEvent.<%-el %>; }
	<% }); %>
	```
	# x and y
	```
	get x(){var o=this.originalEvent; return o.x || o.clientX; }
	get y(){var o=this.originalEvent; return o.y || o.clientY; }
	get path(){
		var path= [];
		var target= this.target;
		while(target && target != document){
			path.push(target);
			target= target.parentNode;
		}
		_defineProperty(this, 'path', {configurable:true, enumerable:true, value:path, writable:true});
		return path;
	}
	```