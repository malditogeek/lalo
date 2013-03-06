var http      = require('http');
var ss        = require('socketstream');
var everyauth = require('everyauth');
var _         = require('underscore');

var User      = require('./lib/user.js').User;
var ircServer = require('./lib/server.js').Server;

// Chat client
ss.client.define('main', {
  view: 'app.jade',
  css:  ['libs', 'app.styl'],
  code: ['libs', 'app'],
  tmpl: '*'
});

// Notifications client
ss.client.define('ext', {
  view: 'ext.jade',
  css:  ['libs', 'app.styl'],
  code: ['libs', 'ext'],
  tmpl: '*'
});


// Serve this client on the root URL
ss.http.route('/', function(req, res){
  res.serveClient('main');
})

ss.http.route('/ext', function(req, res){
  res.serveClient('ext');
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
  .consumerKey('0OoKDg61Joe9QSdYBIe7RA')
  .consumerSecret('DN65E4txvljwLPDmu3kpgDOdbii75ZryDA90FIwL4')
  .findOrCreateUser( function(session, accessToken, accessTokenSecret, twitterUserMetadata) {
    session.userId  = twitterUserMetadata.screen_name;
    session.name    = twitterUserMetadata.name;
    session.nick    = twitterUserMetadata.screen_name;
    session.token   = accessToken;
    session.save();
    return true;
  })
  .redirectPath('/welcome');

ss.http.middleware.prepend(ss.http.connect.bodyParser());
ss.http.middleware.append(everyauth.middleware());

// Start SocketStream
ss.start(server);

// Start IRC server
var server = ircServer.boot(ss);
var ws_users = {};

ss.api.add('serverCmd', function(nick, command, args) {
  console.log('nick: ' + nick + ' | cmd: ' + command + ' | args: ' + JSON.stringify(args));

  if (!ws_users[nick]) { 
    u = new User(null, server);
    u.webclient = true;
    ws_users[nick] = u;
  }

  var user = ws_users[nick];
  server.commands[command].apply(server.commands, [user].concat(args));
});

ss.api.add('channelRoster', function(target) {
  var channel = server.channels.find(target) || [];
  users = []
  if (channel) { channel.users.forEach(function(user) { users.push(user.nick) }); }
  return users;
});
