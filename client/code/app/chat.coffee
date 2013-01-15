ss.event.on 'privmsg', (json) ->
  message = new Message(json)
  App.messages.add(message)
  #$('.message').embedly()

window.Message = Backbone.Model.extend({
  initialize: (message) ->
    this.set 'nick',   message.nick
    this.set 'target', message.target
    this.set 'timestamp', new Date() # moment().calendar()

    # Auto-link
    if url = message.body.match(/https?:\/\/\S+/)
      this.set 'body', message.body.replace(url[0], 
      "<a href='#{url[0]}' target='_blank'>#{url[0]}</a>")
    else
      this.set 'body', message.body
})

window.MessagesCollection = Backbone.Collection.extend({
  model: Message
})

window.MessagesView = Backbone.View.extend({
 
  tagName: 'ul'
  className:'messages'

  initialize: ->
    self = this
    this.collection.bind("reset", this.render, this)
    this.collection.bind("add", (message) ->
      $(self.el).prepend(new MessageItemView({model: message}).render().el)
    )

  render: (eventName) ->
    _.each(this.collection.models, (message) ->
      $(this.el).prepend(new MessageItemView({model: message}).render().el)
    , this)
    return this
 
})

window.MessageItemView = Backbone.View.extend({

  tagName:"li"

  initialize: ->
    this.model.bind("change", this.render, this)
    this.model.bind("destroy", this.close, this)

  render: ->
    $(this.el).html(this.template(this.model.toJSON()))
    return this

})

AppRouter = Backbone.Router.extend({
 
  routes:{
    '/': 'root',
  },

  initialize: ->
    this.messages = new MessagesCollection()
    this.messagesView = new MessagesView({collection: this.messages})
    $('#messages').html(this.messagesView.render().el)

  root: ->

})

# Pre-load templates
window.templateLoader = {
    load: (views, callback) ->
      deferreds = []
      $.each(views, (index, view) ->
        if window[view] 
          deferreds.push($.get('templates/' + view + '.html', (data) ->
            window[view].prototype.template = _.template(data)
          , 'html'))
        else 
          alert(view + " not found")
      )
      $.when.apply(null, deferreds).done(callback)
}

# Pre-laod templates and start the app.
templateLoader.load(['MessageItemView'], ->
  window.App = new AppRouter()
  Backbone.history.start()
)
