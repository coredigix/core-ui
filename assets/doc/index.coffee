Gridfw= require 'gridfw'
Path= require 'path'

app= new Gridfw Path.resolve(__dirname, './config')

# process uncaught errors
process.on 'uncaughtException', (err)->
	app.fatalError 'Process uncaughtException', err
	process.emit 'SIGINT', 1
	return


# wrap
app.wrap '/*', (ctx, next)->
	await ctx.setLocal('en')
	return next()
# params
app.param
	name: 'fold'
	matches: ->true
app.param
	name: 'element'
	matches: ->true
# routes
# Home
app.get '/', -> 'home'
# elements
app.get '/:fold', (ctx)-> ctx.render "others/#{ctx.params.fold}"
app.get '/:fold/:element', (ctx)->
	params= ctx.params
	ctx.render "#{params.fold}/#{params.element}"

# app.get '/build/core-ui.css', (ctx)-> ctx.sendFile 'build/core-ui.css'
# app.get '/build/core-ui.js', (ctx)-> ctx.sendFile 'build/core-ui.js'
app.get '/public/*', (ctx)-> ctx.sendFile Path.join __dirname, 'public', ctx.params['*']


app.listen()