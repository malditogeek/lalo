var http      = require('http');
var ss        = require('socketstream');
var everyauth = require('everyauth');
var User = require('./lib/user.js').User;

// Define a single-page client
ss.client.define('main', {
  view: 'app.jade',
  css:  ['libs', 'app.styl'],
  code: ['libs', 'app'],
  tmpl: '*'
});

// Serve this client on the root URL
ss.http.route('/', function(req, res){
  if (!req.session.userId) {
    res.writeHead(302, {'Location': '/auth/twitter'});
    res.end();
  } else {
    res.serveClient('main');
  }
})

// Code Formatters
ss.client.formatters.add(require('ss-coffee'));
ss.client.formatters.add(require('ss-jade'));
ss.client.formatters.add(require('ss-stylus'));

// Use server-side compiled Hogan (Mustache) templates. Others engines available
ss.client.templateEngine.use(require('ss-hogan'));

// Minimize and pack assets if you type: SS_ENV=production node app.js
if (ss.env == 'production') ss.client.packAssets();

// Start web server
var server = http.Server(ss.http.middleware);
server.listen(process.env.PORT_WWW || 5000);

everyauth.twitter
  .consumerKey(process.env.LALO_TWITTER_KEY)
  .consumerSecret(process.env.LALO_TWITTER_SECRET)
  .findOrCreateUser( function(session, accessToken, accessTokenSecret, twitterUserMetadata) {
    session.userId  = twitterUserMetadata.screen_name;
    session.name    = twitterUserMetadata.name;
    session.nick    = twitterUserMetadata.screen_name;
    session.save();
    return true;
  })
  .redirectPath('/');

ss.http.middleware.prepend(ss.http.connect.bodyParser());
ss.http.middleware.append(everyauth.middleware());

// Start SocketStream
ss.start(server);

// Start IRC server
var ircServer = require('./lib/server.js').Server;
var server = ircServer.boot(ss);
var users = {};

ss.api.add('irc', function(nick, command, args) {
  if (!users[nick]) { users[nick] = new User(null, server); }
  var user = users[nick];
  server.commands[command].apply(server.commands, [user].concat(args));
});
