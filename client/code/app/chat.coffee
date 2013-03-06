InputView = Backbone.View.extend
  
  events: 
    'keypress'    : 'keypress'
    'click .btn'  : 'send'

  initialize: ->

  render: ->
    $(@el).html(ss.tmpl['chat-input'].render())
    return this

  keypress: (e) ->
    if e.keyCode == 13
      this.send()

  send: (e) ->
    self = this
    message = $('#textbox')[0].value
    console.log message
    if message != ''
      $('#textbox')[0].value = ''
      ss.rpc('chat.message', message, self.options.channel)
      $('#messages')[0].scrollTop = 10000

##
## Chat
##

Message = Backbone.Model.extend
  initialize: (message) ->
    @set 'nick',   message.nick
    @set 'timestamp', new Date() # moment().calendar()

    # Sanitize
    body = message.body.replace(/<|>/g, '')

    # Auto-link
    if url = body.match(/https?:\/\/\S+/)
      @set 'body', body.replace(url[0], "<a href='#{url[0]}' target='_blank'>#{url[0]}</a>")
    else
      @set 'body', body

MessagesCollection = Backbone.Collection.extend
  model: Message

MessagesView = Backbone.View.extend
 
  tagName: 'ul'
  className: 'unstyled'

  initialize: ->
    self = this
    @collection.bind("reset", this.render, this)
    @collection.bind "add", (message) ->
      $(self.el).append(new MessageItemView({model: message}).render().el)

  render: ->
    return this

MessageItemView = Backbone.View.extend

  tagName:"li"

  initialize: ->
    @model.bind("change", this.render, this)
    @model.bind("destroy", this.close, this)

  render: ->
    $(@el).html(ss.tmpl['chat-message'].render(@model.toJSON()))
    $(@el).embedly()
    $('#messages')[0].scrollTop = 10000
    return this

##
## Roster
##

User = Backbone.Model.extend
  initialize: (nick) ->
    @set 'id'  , nick
    @set 'nick', nick

RosterCollection = Backbone.Collection.extend
  model: User

RosterView = Backbone.View.extend
 
  tagName: 'ul'
  className: 'unstyled'

  initialize: ->
    self = this
    @collection.bind("reset", this.render, this)
    @collection.bind("add", this.render, this)
    @collection.bind("remove", this.render, this)
    #@collection.bind "add", (message) ->
    #  $(self.el).append(new RosterItemView({model: user}).render().el)

  render: ->
    $(@el).html('')
    self = this
    @collection.forEach (user) ->
      $(self.el).append(new RosterItemView({model: user}).render().el)
    return this

RosterItemView = Backbone.View.extend

  tagName:"li"

  initialize: ->
    @model.bind("change", this.render, this)
    @model.bind("destroy", this.close, this)

  render: ->
    $(@el).html(ss.tmpl['chat-user'].render(@model.toJSON()))
    return this

ChannelView = Backbone.View.extend
  render: ->
    $(@el).html("<h1>#{@options.channel}</h1>")
    return this

window.adjust_chat = ->
  h = $(window).height()
  $('#chat').height(h - 150)
  $('#messages').height(h - 230)
  $('#messages')[0].scrollTop = 10000

AppRouter = Backbone.Router.extend
 
  routes:
    ''          : 'root'
    ':channel'  : 'join_channel'

  initialize: ->

  join_channel: (channel) ->
    channel = "##{channel}"

    ss.rpc 'chat.connect', channel, (roster) ->

      channelView = new ChannelView({channel: channel})
      $('#channel').html(channelView.render().el)

      users = new RosterCollection()
      rosterView = new RosterView({collection: users})
      $('#roster').html(rosterView.render().el)

      roster.forEach (user) ->
        users.add(new User(user)) 

      messages = new MessagesCollection()
      messagesView = new MessagesView({collection: messages})
      $('#messages').html(messagesView.render().el)

      inputView = new InputView(channel: channel)
      $('#input').html(inputView.render().el)

      window.adjust_chat()
      $(window).resize(window.adjust_chat)

      window.onbeforeunload = ->
        ss.rpc('chat.disconnect', channel)

      ss.event.on 'ircd.msg', (msg) ->
        #console.log "ircd.msg: #{JSON.stringify(msg)}"
        m = msg.match(/:(\w+)\!\S+ (\w+) (:?#?\w+)/)

        if m.length != 4
          return
       
        nick  = m[1]
        cmd   = m[2]
        body  = m[3]
      
        switch cmd
          when 'JOIN'
            if body == channel
              users.add(new User(nick))
          when 'PART'
            if body == channel
              u = users.get(nick)
              users.remove(u)

      ss.event.on 'ircd.privmsg', (msg) ->
        message = new Message(msg)
        messages.add(message)

  root: ->
    $('#welcome').fadeIn()
    App.navigate('welcome', trigger: true)

window.App = new AppRouter()
Backbone.history.start({pushState: true})
