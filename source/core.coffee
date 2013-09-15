@Sneaker = {}

Sneaker.ref =
  anchorName:                       -> "__anchor"
  boxesName:                        -> "__boxes"
  handlerName:               (name) -> "__handle_#{name}"
  hooksName:                        -> "__hooks"
  init:
    name:                    (name) -> "__init_#{name}"
    collectionName:                 -> "__inits"
    orderName:                      -> "__inits_order"
    skipName:                       -> "__inits_skip"
  interactionCallbackName:  (index) -> "__interaction_cb_#{index}"
  interactionsName:                 -> "__interactions"
  quit:
    name:                    (name) -> "__quit_#{name}"
    collectionName:                 -> "__quits"
    orderName:                      -> "__quits_order"
    skipName:                       -> "__quits_skip"
  requestDefaultsName:              -> "__requestDefaults"
  requestName:               (name) -> "__request_#{name}"
  responsesName:                    -> "__responses"
  responseName:              (name) -> "__response_#{name}"
  templateName:              (name) -> "__template_#{name}"


Sneaker.util =
  type: (thing, type, error) ->
    if type isnt jQuery.type thing
      Sneaker.util.throw error
      false
    else true
  uniq: (array) ->
    output = {}
    output[array[key]] = array[key] for key in [0...array.length]
    value for key, value of output
  throw: (message) ->
    throw "Sneaker: #{message}, please" if message?

Sneaker.ns =
  get: (object, path) ->
    tokens = Sneaker.ns.tokens path
    obj = object
    while tokens.length > 0
      t = tokens.shift()
      obj = obj[t] if obj?
    obj
  create: (object, path) ->
    tokens = Sneaker.ns.tokens path
    while tokens.length > 0 and object? and Sneaker.util.type object, 'object'
      token = tokens.shift()
      if token.length > 0
        object[token] ||= {}
        object = object[token]
    object
  set: (object, path, value) ->
    tokens = Sneaker.ns.tokens path
    Sneaker.ns.create(object, tokens.slice 0, -1)[tokens.slice -1] = value
  tokens: (path) ->
    switch jQuery.type path
      when 'string' then path.split /\.|\//
      when 'array'  then path.slice 0
      else []


Sneaker.Core = class SneakerCore

  @include: (module) ->
    for key, method of module
      if module.hasOwnProperty( key ) and key isnt 'has_module_setup'
        this[key] = module[key]
    for key, method of module::
      if module::.hasOwnProperty key
        this::[key] = module::[key]
    if module.has_module_setup?
      Sneaker.util.type module.has_module_setup, 'function',
        '@has_module setup, if defined on a module, must be a function'
      module.has_module_setup.apply this

  @has_handler: (phrase, fn) ->
    Sneaker.util.type phrase, 'string',
      '@has_handler expects the first argument to be a string'
    Sneaker.util.type fn, 'function',
      '@has_handler expects the second argument to be a function'

    @::[Sneaker.ref.handlerName phrase] = fn
    return

  @has_init: (name, callback_pack...) ->
    __has_bookend.call this, 'init', name, callback_pack

  @has_init_order: (order) ->
    __has_bookend_order.call this, 'init', order

  @skips_init: (name) ->
    __skips_bookend.call this, 'init', name

  @runs_init: (name) ->
    __runs_bookend.call this, 'init', name

  @has_quit: (name, callback_pack...) ->
    __has_bookend.call this, 'quit', name, callback_pack

  @has_quit_order: (order) ->
    __has_bookend_order.call this, 'quit', order

  @skips_quit: (name) ->
    __skips_bookend.call this, 'quit', name

  @runs_quit: (name) ->
    __runs_bookend.call this, 'quit', name

  #====================================#

  constructor: ->
    @init.apply this, arguments

  handle: (phrase, eventAttributes) ->
    if Sneaker.util.type phrase, 'string'
      handler = @[Sneaker.ref.handlerName phrase]
      handler.call @, eventAttributes if handler?

  init: ->
    __run_bookends.call this, 'init', arguments

  quit: ->
    __run_bookends.call this, 'quit', arguments

  #====================================#

  __has_bookend = (end, name, callback_pack) ->
    if( ['init', 'quit'].some (valid) -> ~end.indexOf valid )
      if callback_pack.length is 1
        callback = callback_pack[0]
        indicies = []
      else
        callback = callback_pack[1]
        indicies = callback_pack[0]
      Sneaker.util.type indicies, 'array',
        "@has_#{end} expects provided indicies to be an array"
      Sneaker.util.type callback, 'function',
        "@has_#{end} expects the callback to be a function"
      @::[Sneaker.ref[end].name name] = [callback, indicies]
      collection = Sneaker.ref[end].collectionName()
      @::[collection] = if @::[collection] then @::[collection][..] else []
      @::[collection].push name
      @::[collection] = Sneaker.util.uniq @::[collection]

  __has_bookend_order = (end, order) ->
    if( ['init', 'quit'].some (valid) -> ~end.indexOf valid )
      Sneaker.util.type order, 'array',
        "@has_#{end}_order expects an array"
      @::[Sneaker.ref[end].orderName()] = order

  __skips_bookend = (end, name) ->
    if( ['init', 'quit'].some (valid) -> ~end.indexOf valid )
      skip = Sneaker.ref[end].skipName()
      @::[skip] = if @::[skip] then @::[skip][..] else []
      @::[skip].push name

  __runs_bookend = (end, name) ->
    if( ['init', 'quit'].some (valid) -> ~end.indexOf valid )
      skip = Sneaker.ref[end].skipName()
      @::[skip] = if @::[skip] then @::[skip][..] else []
      index = @::[skip].indexOf name
      @::[skip].splice index, 1 if index >= 0

  __run_bookends = (end, args) ->
    run_an_bookend = (name, original_arguments) ->
      if @[Sneaker.ref[end].name name]?
        indicies = @[Sneaker.ref[end].name name][1]
        if indicies?.length > 0
          use_args = for index in indicies
            original_arguments[index]
        else
          use_args = original_arguments
        @[Sneaker.ref[end].name name][0].apply this, use_args

    if( ['init', 'quit'].some (valid) -> ~end.indexOf valid )
      already_ran = []
      for skip in (@[Sneaker.ref[end].skipName()] or [])
        already_ran.push skip
      for ordered in (@[Sneaker.ref[end].orderName()] or [])
        run_an_bookend.call this, ordered, args unless already_ran.indexOf(ordered) >= 0
        already_ran.push ordered
      for bookend in (@[Sneaker.ref[end].collectionName()] or [])
        run_an_bookend.call this, bookend, args unless already_ran.indexOf(bookend) >= 0
