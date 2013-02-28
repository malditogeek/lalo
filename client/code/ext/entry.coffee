window.ss = require('socketstream')

showNotification = (body, persistent) ->
  msg = {
    type: 'notification'
    message: body
    persistent: true # persistent || false
  }
  parent.postMessage(msg, '*')

ss.event.on 'notification', (json) ->
  showNotification(json.message)

ss.server.on 'disconnect', ->
  console.log 'Oops, connection down...'
  #showNotification('Disonnected.')

ss.server.on 'ready', ->
  ss.rpc 'chat.notifications', (logged_in) ->
    showNotification('Please login to enable notifications.') unless logged_in
      
  # Wait for the DOM to finish loading
  jQuery ->
