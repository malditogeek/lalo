# This file automatically gets called first by SocketStream and must always exist

# Make 'ss' available to all modules and the browser console
window.ss = require('socketstream')

ss.server.on 'disconnect', ->
  console.log('Oops, connection down...')

ss.server.on 'reconnect', ->
  console.log('Yay, connection recovered!')

ss.server.on 'ready', ->

  # Wait for the DOM to finish loading
  jQuery ->
    
    # Load app
    ss.chat = require('/chat')
