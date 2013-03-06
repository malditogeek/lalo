# Server-side Code

exports.actions = (req, res, ss) ->

  req.use('session')

  irc: (command, args) ->
    if user = req.session.userId
      ss.serverCmd(req.session.userId, command, args)

  connect: (channel) ->
    if user = req.session.userId
      console.log channel

      ss.serverCmd(user, 'PASS', ['inhackwetrust'])
      ss.serverCmd(user, 'USER', [user, 'WS', 'Lalo', user])
      ss.serverCmd(user, 'NICK', [user,''])
      ss.serverCmd(user, 'JOIN', [channel, ''])

      #ss.publish.user(user, 'notification', {message: 'Connected!'})

      # Reply with the roster
      res ss.channelRoster(channel)

  disconnect: (channel) ->
    if user = req.session.userId
      ss.serverCmd(user, 'PART', [channel, ''])

  message: (msg, channel) ->
    if user = req.session.userId
      ss.serverCmd(user, 'PRIVMSG', [channel, msg])

  notifications: ->
    if req.session.userId then res(true) else res(false)
