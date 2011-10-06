sys = require 'sys'

express = require 'express'
app = express.createServer()
browserify = require 'browserify'

db = require './lib/scheme'

# Configure website
password = "test123" # TODO: change?

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
  app.use express.bodyParser()
  app.use express.session({ secret: "HIERMOETRANDOMKEYKOMEN" })

  app.use express.errorHandler({ dumpExceptions: true, showStack: true })

app.configure 'production', -> app.use express.errorHandler()

auth = (req, res, next) ->
  user = req.session.user
  db.User.findById user, (err, doc) ->
    if !err and doc != null
      res.local 'loggedin', true
      next()
    else
      res.redirect '/login'

app.all '/*', (req, res, next) ->
  res.local 'loggedin', false
  next()

# Route to index
app.get '/', auth, (req, res) ->
  res.render 'index'


app.post '/hints', auth, (req, res) -> res.redirect '/'

app.get '/hints.json', auth, (req, res) ->
  db.Hint.find {}, (err, docs) ->
    hints = []
    for doc in docs
      hints.push
        type: 'Feature'
        geometry:
          type: 'Point'
          coordinates: [doc.longlat.x, doc.longlat.y]
    res.send
      type: 'FeatureCollection'
      features: hints

app.get '/login', (req, res) -> res.render 'login'
app.get '/logout', auth, (req, res) ->
  req.session.user = false
  res.redirect '/'

app.post '/authenticate', (req, res) ->
  if req.body.password != password
    res.redirect '/login#fail'
    return

  db.User.findOne {'name': req.body.name}, (err, doc) ->
    if !err and doc != null
      req.session.user = doc._id
      res.redirect '/'
      return

    user = new db.User
      name: req.body.name
      ip: req.socket.remoteAddress

    user.save (err) ->
      req.session.user = user._id
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
