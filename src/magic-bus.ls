class magic-bus
  ->
    # setup localstorage trigger
    window.addEventListener 'storage' @on-storage-change
    # private
    @store = {}
    @once-store = {}
    @store-event = (event, action, store) ->
      filter = ->
        it == action or it.to-string! == action.to-string!

      actions = (store[event] = store[event] or [])
      actions.push action if !actions.filter(filter).length

    @on-storage-change = !-> @fire it.new-value

  # public interface
  on: (event, action) !->
    @store-event(event, action, @store)

  once: (event, action) !->
    @store-event(event, action, @once-store)

  fire: (event) !->
    args = [].slice.call(arguments, 1)
    actions = (@store[event] or []) ++ (@once-store[event] or [])
    delete @once-store[event]
    actions.for-each !-> it.apply(@, args)

  off: (event) !->
    delete @store[event]
    delete @once-store[event]

  #aliases
  raise: @::fire
  trigger: @::fire
  unregister: @::off
