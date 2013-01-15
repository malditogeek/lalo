# Server-side Code

exports.actions = (req, res, ss) ->

  send_msg: (user, msg) ->
    console.log "[web] #{user}: #{msg}"
