# Server-side Code

exports.actions = (req, res, ss) ->

  req.use('session')

  irc: (command, args) ->
    console.log "[WS] #{command}, #{args}"
    ss.irc(req.session.userId, command, args)

  connect: ->
    console.log "[WS] Connected: #{req.session.userId}"
    if req.session.userId
      ss.irc(req.session.userId, 'PASS', ['inhackwetrust'])
      ss.irc(req.session.userId, 'USER', [req.session.nick, 'WS', 'Lalo', req.session.name])
      ss.irc(req.session.userId, 'NICK', [req.session.nick,''])
      ss.irc(req.session.userId, 'JOIN', ['#fwd',''])
