###
Sneaker UI Library
Version 0.9.0

Copyright 2013 LivingSocial, Inc.
Released under the MIT license
###



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



Sneaker.View = class SneakerView extends Sneaker.Core

  @has_listener: (types, hook, fn) ->
    Sneaker.util.type types, 'string',
      '@has_listener expects the first argument to be a string of event types'
    Sneaker.util.type hook, 'string',
      '@has_listener expects the second argument to be a string, to later match against the hooks tree'
    Sneaker.util.type fn, 'function',
      '@has_listener expects the third argument to be a callback function'

    intrs = Sneaker.ref.interactionsName()
    @::[intrs] = if @::[intrs] then @::[intrs][..] else []

    @callbackIndex ||= 0
    callbackName = Sneaker.ref.interactionCallbackName @callbackIndex++

    @::[callbackName] = fn
    @::[intrs].push
      types: types
      hook: hook
      fn: callbackName

  @has_hook: (hooksHash) ->
    Sneaker.util.type hooksHash, 'object',
     '@has_hook expects to be passed a hash (with nested hashes) of name/selector pairs'
    hooks = Sneaker.ref.hooksName()
    @::[hooks] = jQuery.extend true, {}, @::[hooks], hooksHash

  @has_hooks: @has_hook

  @has_base: (templateFn) ->
    Sneaker.util.type templateFn, 'function',
      '@has_base expects to be passed a function'
    @::[Sneaker.ref.templateName 'base'] = templateFn

  @has_anchor: (selector) ->
    Sneaker.util.type name, 'string',
      '@has_anchor expects a string to run as a selector against the document'
    @::[Sneaker.ref.anchorName()] = selector

  @has_template: (name, fn) ->
    Sneaker.util.type name, 'string',
      '@has_template expects the first argument to be a string'
    Sneaker.util.type fn, 'function',
      '@has_template expects the second argument to be a function'
    @::[Sneaker.ref.templateName name] = fn

  #====================================#

  @has_init 'View: reference building', ->
    @__localDom = jQuery()
    @dom = {}

  @has_init 'View: anchoring', ->
    base = @render('base')
    anchor = @[Sneaker.ref.anchorName()]
    @dom.base = @__localDom = if base?
      base.to_jQuery()
    else if anchor?
      $(anchor).first()
    else
      jQuery()
    do @rehook

  @has_init 'View: handler delegation', ->
    if @dom.base? and @[Sneaker.ref.interactionsName()]
      for interaction in @[Sneaker.ref.interactionsName()]
        do (interaction) =>
          if interaction.hook is 'base'
            @dom.base.on interaction.types, (event) =>
              @[interaction.fn].call @, event
          else
            selector = Sneaker.ns.get @[Sneaker.ref.hooksName()], interaction.hook
            if selector?
              @dom.base.on interaction.types, selector, (event) =>
                @[interaction.fn].call @, event
            else Sneaker.util.throw(
              "Listener setup failed; `#{interaction.hook}` is an invalid hook path, double check it"
            )

  @has_quit 'View: remove DOM', ->
    if @[Sneaker.ref.anchorName()]? then do @dom.base.empty else do @remove

  @has_quit 'View: clear ref', ->
    delete @__localDom
    delete @dom

  #====================================#

  rehook: ->
    if @dom.base?
      tree = []
      recurse = (hooksObject) =>
        for name, selector of hooksObject
          do (name, selector) =>
            if Sneaker.util.type selector, 'object'
              tree.push name
              recurse selector
              tree.pop()
            else if Sneaker.util.type selector, 'string'
              branch = Sneaker.ns.create @dom, tree
              branch[name] = jQuery selector, @__localDom
      recurse @[Sneaker.ref.hooksName()]
    @dom

  render: (name) ->
    template = @[Sneaker.ref.templateName name]
    new Sneaker.Press( template, @dom ) if template?

  detach: ->
    @__localDom.detach()

  remove: ->
    @__localDom.remove()

  show:   ->
    @__localDom.show()

  hide:   ->
    @__localDom.hide()

  appendTo:   (container) ->
    @__moving 'appendTo', container

  prependTo:  (container) ->
    @__moving 'prependTo', container

  insertAfter:  (sibling) ->
    @__moving 'insertAfter', sibling

  insertBefore: (sibling) ->
    @__moving 'insertBefore', sibling

  #====================================#

  __moving: ( jQueryMethod, target ) ->
    if( ['appendTo', 'prependTo', 'insertAfter', 'insertBefore'].some (valid) -> ~jQueryMethod.indexOf valid )
      wrapped_target = if target? then jQuery(target).first() else []
      @__localDom[jQueryMethod](wrapped_target) if wrapped_target.length is 1



Sneaker.Press = class SneakerPress extends Sneaker.Core

  constructor: (@templateFunction = (-> ''), @dom) ->
    Sneaker.util.type @templateFunction, 'function',
      'SneakerPress expects a function as its first argument'
    if @dom?
      Sneaker.util.type @dom, 'object',
        'SneakerPress expects a hash (or a nested hash tree) of name:jQuery selections as its second argument'

    @context = {}

  with: (context = {}) ->
    Sneaker.util.type context, 'object', 'SneakerPress expects an object as context'
    @context = jQuery.extend {}, context
    this

  and: (additionalContext = {}) ->
    Sneaker.util.type additionalContext, 'object', 'SneakerPress expects an object as context'
    @context = jQuery.extend @context, additionalContext
    this

  press: -> @templateFunction @context
  to_s: @::press

  to_jQuery: -> jQuery @press()
  to_$: @::to_jQuery

  top:       (target) -> @__publish target, 'prepend'
  beginning: @::top
  end:       (target) -> @__publish target, 'append'
  bottom:    @::end
  as:        (target) -> @__publish target, 'as'
  into:      @::as
  before:    (target) -> @__publish target, 'before'
  front:     @::before
  ahead:     @::before
  after:     (target) -> @__publish target, 'after'
  back:      @::after
  behind:    @::after

  __publish: (target, method) ->
    if method is 'as'
      if target instanceof jQuery
        target.empty().append do @press
      else if jQuery.type(target) is 'string'
        if @dom?
          (Sneaker.ns.get @dom, target).empty().append do @press
        else
          jQuery(target).empty().append do @press
    else
      if target instanceof jQuery
        target[method] do @press
      else if jQuery.type(target) is 'string'
        if @dom?
          (Sneaker.ns.get @dom, target)[method] do @press
        else
          jQuery(target)[method] do @press
    this



Sneaker.Api = Sneaker.API = class SneakerApi extends Sneaker.Core

  @has_default: (hash) ->
    Sneaker.util.type hash, 'object', '@default expects to be passed a hash of name/value pairs'
    defaults = Sneaker.ref.requestDefaultsName()
    @::[defaults] = jQuery.extend( true, {}, @::[defaults], hash )
    return
  @has_defaults: @has_default

  @has_request: (name, fn) ->
    Sneaker.util.type name, 'string', '@request expects the first argument to be a string'
    Sneaker.util.type fn, 'function', '@request expects the second argument to be a function'

    @::[Sneaker.ref.requestName name] = fn
    return

  @install: (mock) ->
    responses = Sneaker.ref.responsesName()
    @::[responses] ||= ( @::[responses]?.slice(0) || [] )

    for response in mock::[responses]
      @::[responses].push response
      @::[responses] = Sneaker.util.uniq @::[responses]

      name = Sneaker.ref.responseName response
      @::[name] = mock::[name]
    return

  @uninstall: ->
    for response in @::[Sneaker.ref.responsesName()]
      delete @::[Sneaker.ref.responseName response]
    delete @::[Sneaker.ref.responsesName()]
    return

  handle: (phrase, eventAttributes) ->
    if Sneaker.util.type phrase, 'string'
      handler = @[Sneaker.ref.handlerName phrase]
      if handler
        deferred = jQuery.Deferred()
        handler.call @, eventAttributes, deferred
        deferred
      else
        @request phrase, eventAttributes

  request: (phrase, eventAttributes) ->
    if Sneaker.util.type phrase, 'string'
      defaults = @[Sneaker.ref.requestDefaultsName()] || {}
      requestHandler = @[Sneaker.ref.requestName phrase]
      if requestHandler?
        request = requestHandler.call this, eventAttributes
        merged = jQuery.extend {}, defaults, request
        responseMock = @[Sneaker.ref.responseName phrase]
        if responseMock?
          Sneaker.ApiMock::respond responseMock.call this, merged, eventAttributes
        else
          jQuery.ajax merged



Sneaker.ApiMock = class SneakerApiMock

  @has_response: (name, fn) ->
    Sneaker.util.type name, 'string', '@response expects `name` to be a string'
    Sneaker.util.type fn, 'function', '@response expects the second argument to be a function'

    responses = Sneaker.ref.responsesName()
    (@::[responses] = (@::[responses] || []).slice 0).push name
    @::[Sneaker.ref.responseName name] = fn

  respond: (mockedResponse = {}) ->
    status = mockedResponse.status ||= 200
    mockedResponse.body ||= null

    statusCodes =
      100: "Continue",
      101: "Switching Protocols",
      200: "OK",
      201: "Created",
      202: "Accepted",
      203: "Non-Authoritative Information",
      204: "No Content",
      205: "Reset Content",
      206: "Partial Content",
      300: "Multiple Choice",
      301: "Moved Permanently",
      302: "Found",
      303: "See Other",
      304: "Not Modified",
      305: "Use Proxy",
      307: "Temporary Redirect",
      400: "Bad Request",
      401: "Unauthorized",
      402: "Payment Required",
      403: "Forbidden",
      404: "Not Found",
      405: "Method Not Allowed",
      406: "Not Acceptable",
      407: "Proxy Authentication Required",
      408: "Request Timeout",
      409: "Conflict",
      410: "Gone",
      411: "Length Required",
      412: "Precondition Failed",
      413: "Request Entity Too Large",
      414: "Request-URI Too Long",
      415: "Unsupported Media Type",
      416: "Requested Range Not Satisfiable",
      417: "Expectation Failed",
      422: "Unprocessable Entity",
      500: "Internal Server Error",
      501: "Not Implemented",
      502: "Bad Gateway",
      503: "Service Unavailable",
      504: "Gateway Timeout",
      505: "HTTP Version Not Supported"

    if ( status >= 200 and status < 300 ) or status is 304 or status is 1223 or status is 0
      jQuery.Deferred().resolveWith this, [mockedResponse.body, statusCodes[status], {}]
    else
      jQuery.Deferred().rejectWith this, [{}, statusCodes[status], new Error statusCodes[status]]
