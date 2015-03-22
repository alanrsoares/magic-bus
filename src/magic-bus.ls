let
  # private members
  store = {}
  once-store = {}
  store-event = (event, action, store) ->
    filter = ->
      it == action or it.to-string! == action.to-string!

    actions = (store[event] = store[event] or [])
    actions.push action if !actions.filter(filter).length

  STORAGE_KEY = 'magic-buz-event-store'

  storage-change = (event) !->
    window.bus.fire(event.newValue) if event.key is STORAGE_KEY

  class magic-bus
    ->
      local-storage.set-item(STORAGE_KEY, '')
      window.add-event-listener 'storage' storage-change

    # public interface
    on: (event, action) !->
      store-event(event, action, store)

    once: (event, action) !->
      store-event(event, action, once-store)

    fire: (event) !->
      args = [].slice.call(arguments, 1)
      actions = (store[event] or []) ++ (once-store[event] or [])
      delete once-store[event]
      actions.for-each !-> it.apply(@, args)

      local-storage.set-item STORAGE_KEY, event

    off: (event) !->
      delete store[event]
      delete once-store[event]

    #aliases
    raise: @::fire
    trigger: @::fire
    register: @::on
    unregister: @::off

  window.bus = window.bus or new magic-bus!


window.bus.on \foo -> console.log \foo it
