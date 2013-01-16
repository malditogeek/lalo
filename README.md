# Lalo

![Lalo Schifrin](http://i.imgur.com/aU3Ol.jpg)

An experimental Node.js IRC server with a WebSocket based interface.

A mashup between [IRCd.js](git://github.com/alexyoung/ircd.js.git) and [SocketStream](https://github.com/socketstream/socketstream).

Backbone.js and Bootstrap for the interface.

## Getting Started

Clone and install deps:

        $> npm install
        $> node app.js

This will start an IRC server with the following details:
        Host: 127.0.0.1
        Port: 6667
        Password: inhackwetrust
        SSL: enabled

To try the Web interface, you'll need to [create a Twitter application](https://dev.twitter.com/apps), use 'http://127.0.0.1:5000/' for the Website and 'http://127.0.0.1:5000/auth/twitter/callback' for the Callback URL.

Set the Twitter OAuth tokens:

        export LALO_TWITTER_SECRET=your_app_secret
        export LALO_TWITTER_KEY=your_app_key

Restart the app and point your browser at: http://127.0.0.1:5000/

## Deployment

Since Heroku doesn't support WebSockets or arbitrary ports this won't run there. But works perfectly on DotCloud. Will add some instructions soon.
