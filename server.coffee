sys = require 'sys'

express = require 'express'
app = express.createServer()
browserify = require 'browserify'

db = require 'lib/scheme'

# Configure website
app.configure ->
  app.register '.coffee', require('coffeekup').adapters.express

  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'coffee'
  #app.set 'view options', {layout: 'layout'}

  app.use express.static(__dirname + '/public')
  app.use browserify
    mount: '/app.js'
    entry: "#{__dirname}/lib/client.coffee"
    watch: true
    #filter: require('uglify-js')
  app.use express.cookieParser()
  app.use express.session({ secret: "HIERMOETRANDOMKEYKOMEN" })

  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', -> app.use express.errorHandler()

auth = (req, res, next) ->
  return next() #TODO: remove
  logged_in = false

  user = req.session.user
  if user
    db.User.findById user, (err, doc) ->
      return if err
      logged_in = true
      next()

  res.redirect '/login' unless logged_in

# Route to index]
app.get '/', auth, (req, res) ->
  res.render 'index'

app.post '/hints', auth, (req, res) ->
  res.redirect '/'


app.get '/hints.json', auth, (req, res) ->
  db.Hint.find {}, (err, docs) ->
    hints = []
    for doc in docs
      hints << {
        type: 'Feature'
        geometry:
          type: 'Point'
          coordinates: [doc.loc_lng.x, doc.loc_lng.y]
      }
    res.send
      type: 'FeatureCollection'
      features: hints

app.get '/login', (req, res) -> res.render 'login'

app.post '/authenticate', (req, res) ->
  User.findOne {}
  req.session.user = true
  res.redirect '/'

# Less
fs = require 'fs'
path = require 'path'
app.get '/css/*.*', (req, res) ->
  file = req.params[0] + '.less'
  file = path.join('./style/', path.normalize(file))
  fs.readFile file, 'utf-8', (e, str) ->
    return res.send 'Not found.', 404 if e

    new(require('less').Parser)({paths: [path.dirname(file)], optimization: 0 })
      .parse str, (err, tree) -> res.send tree.toCSS(), {'Content-Type': 'text/css'}, 201

# Start application
startServer = (host, port) ->
  app.listen port, host
  console.log "Server opgestart op http://#{host}:#{port}"

startServer '0.0.0.0', 8124
