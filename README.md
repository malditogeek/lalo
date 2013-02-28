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

To try the Web interface point your browser at: http://127.0.0.1:5000/channelname

Lalo web client kinda looks like this:

![Lalo UI](http://i.imgur.com/eGqqjSY.png)

## Deployment

Since Heroku doesn't support WebSockets or arbitrary ports this won't run there. But works perfectly on DotCloud. Will add some instructions soon.

DotCloud deployment instructions.

  * Create an app using the mongo/node stack
  * Follow the instructions and clone the boilerplate
  * Your DotCloud manifest should look like this:

        chat:
            type: nodejs
            approot: app
            processes:
                app: node app.js
            config:
                node_version: v0.8.x
            ports:
                www: http
                irc: tcp
            
        db:
            type: mongodb

  * Deploy with: dotcloud push


Once deployed, you should be able to connect to your app, authenticate with Twitter and join a room.

Reminder: IRC channels are represented by URLs, so if you want to join room #foo, point your browser to http://yourapp/foo

To connect using an IRC client, use the host of your DotCloud app and the IRC port shown in the Environment tab in the [DotCloud Dashboard](http://i.imgur.com/kDKAMPy.png)

There's a public Lalo instance running at: [http://lalo-g7stltno.dotcloud.com/](http://lalo-g7stltno.dotcloud.com/) (IRC port in the screenshot above)
