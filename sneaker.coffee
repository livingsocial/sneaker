###
Sneaker UI Library
Version 0.8.1

Copyright 2013 LivingSocial, Inc.
Released under the MIT license
###



# indexOf shim
`
if (!Array.prototype.indexOf) {
    Array.prototype.indexOf = function (searchElement) {
        "use strict";
        if (this == null) {
            throw new TypeError();
        }
        var t = Object(this);
        var len = t.length >>> 0;
        if (len === 0) {
            return -1;
        }
        var n = 0;
        if (arguments.length > 1) {
            n = Number(arguments[1]);
            if (n != n) {
                n = 0;
            } else if (n != 0 && n != Infinity && n != -Infinity) {
                n = (n > 0 || -1) * Math.floor(Math.abs(n));
            }
        }
        if (n >= len) {
            return -1;
        }
        var k = n >= 0 ? n : Math.max(len - Math.abs(n), 0);
        for (; k < len; k++) {
            if (k in t && t[k] === searchElement) {
                return k;
            }
        }
        return -1;
    }
}
`

this.Sneaker ||= {}

this.Sneaker.convention =
  anchorName:                       -> "__anchor"
  boxesName:                        -> "__boxes"
  handlerName:               (name) -> "__handle_#{name}"
  hooksName:                        -> "__hooks"
  initName:                  (name) -> "__init_#{name}"
  initsName:                        -> "__inits"
  initsOrderName:                   -> "__inits_order"
  initsSkipName:                    -> "__inits_skip"
  interactionCallbackName:  (index) -> "__interaction_cb_#{index}"
  interactionsName:                 -> "__interactions"
  quitName:                  (name) -> "__quit_#{name}"
  quitsName:                        -> "__quits"
  quitsOrderName:                   -> "__quits_order"
  quitsSkipName:                    -> "__quits_skip"
  requestDefaultsName:              -> "__requestDefaults"
  requestName:               (name) -> "__request_#{name}"
  responsesName:                    -> "__responses"
  responseName:              (name) -> "__response_#{name}"
  templateName:              (name) -> "__template_#{name}"


this.Sneaker.util =
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
  install: (module, target) ->
    for key, method of module
      if module.hasOwnProperty(key) and key isnt 'has_module_setup'
        target[key] = module[key]
    for key, method of module::
      if module::.hasOwnProperty key
        target::[key] = module::[key]
    if module.has_module_setup?
      Sneaker.util.type module.has_module_setup, 'function',
        'If @has_module_setup is defined on a module to be installed, it must be a function'
      module.has_module_setup.apply target

this.Sneaker.ns =
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


class SneakerCore

  constructor: ->
    @init.apply this, arguments

  @has_handler: (phrase, fn) ->
    Sneaker.util.type phrase, 'string',
      '@has_handler expects the first argument to be a string'
    Sneaker.util.type fn, 'function',
      '@has_handler expects the second argument to be a function'

    @::[Sneaker.convention.handlerName phrase] = fn
    return

  handle: (phrase, eventAttributes) ->
    if Sneaker.util.type phrase, 'string'
      handler = @[Sneaker.convention.handlerName phrase]
      handler.call @, eventAttributes if handler?


  has_bookend = (end, name, callback_pack) ->
    switch end
      when 'init', 'quit'
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
        @::[Sneaker.convention["#{end}Name"] name] = [callback, indicies]
        collection = Sneaker.convention["#{end}sName"]()
        @::[collection] = if @::[collection] then @::[collection][..] else []
        @::[collection].push name
        @::[collection] = Sneaker.util.uniq @::[collection]
    return

  has_bookend_order = (end, order) ->
    switch end
      when 'init', 'quit'
        Sneaker.util.type order, 'array',
          "@has_#{end}_order expects an array"
        @::[Sneaker.convention["#{end}sOrderName"]()] = order
    return

  skips_bookend = (end, name) ->
    switch end
      when 'init', 'quit'
        skip = Sneaker.convention["#{end}sSkipName"]()
        @::[skip] = if @::[skip] then @::[skip][..] else []
        @::[skip].push name
    return

  runs_bookend = (end, name) ->
    switch end
      when 'init', 'quit'
        skip = Sneaker.convention["#{end}sSkipName"]()
        @::[skip] = if @::[skip] then @::[skip][..] else []
        index = @::[skip].indexOf name
        @::[skip].splice index, 1 if index >= 0
    return

  @has_init: (name, callback_pack...) -> has_bookend.call this, 'init', name, callback_pack
  @has_init_order: (order) -> has_bookend_order.call this, 'init', order
  @skips_init: (name) -> skips_bookend.call this, 'init', name
  @runs_init: (name) -> runs_bookend.call this, 'init', name

  @has_quit: (name, callback_pack...) -> has_bookend.call this, 'quit', name, callback_pack
  @has_quit_order: (order) -> has_bookend_order.call this, 'quit', order
  @skips_quit: (name) -> skips_bookend.call this, 'quit', name
  @runs_quit: (name) -> runs_bookend.call this, 'quit', name


  run_bookends = (end, args) ->
    run_an_bookend = (name, original_arguments) ->
      if @[Sneaker.convention["#{end}Name"] name]?
        indicies = @[Sneaker.convention["#{end}Name"] name][1]
        if indicies?.length > 0
          args = for index in indicies
            original_arguments[index]
        else
          args = original_arguments
        @[Sneaker.convention["#{end}Name"] name][0].apply this, args

    switch end
      when 'init', 'quit'
        already_ran = []
        for skip in (@[Sneaker.convention["#{end}sSkipName"]()] or [])
          already_ran.push skip
        for ordered in (@[Sneaker.convention["#{end}sOrderName"]()] or [])
          run_an_bookend.call this, ordered, args unless already_ran.indexOf(ordered) >= 0
          already_ran.push ordered
        for bookend in (@[Sneaker.convention["#{end}sName"]()] or [])
          run_an_bookend.call this, bookend, args unless already_ran.indexOf(bookend) >= 0
    return

  init: -> run_bookends.call this, 'init', arguments
  quit: -> run_bookends.call this, 'quit', arguments

Sneaker.ns.set this, 'Sneaker.Core', SneakerCore


class SneakerView extends Sneaker.Core

  @has_listener: (types, hook, fn) ->
    Sneaker.util.type types, 'string',
      '@has_listener expects the first argument to be a string of event types'
    Sneaker.util.type hook, 'string',
      '@has_listener expects the second argument to be a string, to later match against the hooks tree'
    Sneaker.util.type fn, 'function',
      '@has_listener expects the third argument to be a callback function'

    intrs = Sneaker.convention.interactionsName()
    @::[intrs] = if @::[intrs] then @::[intrs][..] else []

    @intrs_cb_index ||= 0
    callbackName = Sneaker.convention.interactionCallbackName @intrs_cb_index
    @intrs_cb_index++

    @::[callbackName] = fn
    @::[intrs].push
      types: types
      hook: hook
      fn: callbackName
    return
  @listens_for: @has_listener

  @has_hook: (hooksHash) ->
    Sneaker.util.type hooksHash, 'object',
     '@has_hook expects to be passed a hash of name/selector pairs'

    @::[Sneaker.convention.hooksName()] = jQuery.extend( true,
      {}, @::[Sneaker.convention.hooksName()], hooksHash
    )
    return
  @has_hooks: @has_hook

  @has_box: (name, box = Sneaker.Box) ->
    Sneaker.util.type name, 'string',
      '@has_box expects to be passed a string for the box name'
    if not ((new box) instanceof Sneaker.Box)
      Sneaker.util.throw '@has_box expects the second argument to be a descendent of Sneaker.Box'
      
    boxes = Sneaker.convention.boxesName()
    @::[boxes] = jQuery.extend true, {}, @::[boxes]
    @::[boxes][name] = box
    return

  @has_base: (templateFn) ->
    Sneaker.util.type templateFn, 'function',
      '@has_base expects to be passed a function'
    @::[Sneaker.convention.templateName 'base'] = templateFn
    return

  @has_anchor: (selector) ->
    Sneaker.util.type name, 'string',
      '@has_anchor expects a string to run as a selector against the document'
    @::[Sneaker.convention.anchorName()] = selector

  @has_template: (name, fn) ->
    Sneaker.util.type name, 'string',
      '@has_template expects the first argument to be a string'
    Sneaker.util.type fn, 'function',
      '@has_template expects the second argument to be a function'

    @::[Sneaker.convention.templateName name] = fn
    return

  #====================================#

  @has_init 'View: reference building', ->
    @ref =
      localDom: jQuery()
      dom: {}
    @dom = @ref.dom
    if @[Sneaker.convention.boxesName()]
      @ref.boxes = {}
      for name, box of @[Sneaker.convention.boxesName()]
        @ref.boxes[name] = new box
        @[name] = @ref.boxes[name]

  @has_init 'View: anchoring', ->
    base = @render('base')
    anchor = @[Sneaker.convention.anchorName()]
    @dom.base = @ref.localDom = if base?
      base.to_jQuery()
    else if anchor?
      $(anchor)
    else
      jQuery()
    do @rehook

  @has_init 'View: handler delegation', ->
    if @dom.base? and @[Sneaker.convention.interactionsName()]
      for interaction in @[Sneaker.convention.interactionsName()]
        do (interaction) =>
          if interaction.hook is 'base'
            @dom.base.on interaction.types, (event) =>
              @[interaction.fn].call @, event
          else
            selector = Sneaker.ns.get @[Sneaker.convention.hooksName()], interaction.hook
            if selector?
              @dom.base.on interaction.types, selector, (event) =>
                @[interaction.fn].call @, event
            else Sneaker.util.throw(
              "Listener setup failed; `#{interaction.hook}` is an invalid hook path, double check it"
            )

  @has_quit 'View: remove DOM', -> do @remove

  @has_quit 'View: clear ref', ->
    delete @ref.localDom
    delete @ref.dom
    delete @ref.boxes

  #====================================#

  rehook: ->
    if @dom.base?
      tree = []
      ref = @ref
      recurse = (hooksObject) ->
        for name, selector of hooksObject
          do (name, selector) ->
            if Sneaker.util.type selector, 'object'
              tree.push name
              recurse selector
              tree.pop()
              return
            else if Sneaker.util.type selector, 'string'
              branch = Sneaker.ns.create ref.dom, tree
              branch[name] = jQuery selector, ref.localDom
              return
        return
      recurse @[Sneaker.convention.hooksName()]
      return
    return

  render: (name) ->
    template = @[Sneaker.convention.templateName name]
    return new Sneaker.Press( template, @ref.dom ) if template?
    return

  appendTo:   (container) -> @moving 'appendTo', container
  prependTo:  (container) -> @moving 'prependTo', container
  insertAfter:  (sibling) -> @moving 'insertAfter', sibling
  insertBefore: (sibling) -> @moving 'insertBefore', sibling

  moving: ( jQueryMethod, target ) ->
    switch jQueryMethod
      when 'appendTo', 'prependTo', 'insertAfter', 'insertBefore'
        wrapped_target = if target? then jQuery(target).first() else []
        @ref.localDom[jQueryMethod](wrapped_target) if wrapped_target.length is 1

  detach: -> @ref.localDom.detach()
  remove: -> @ref.localDom.remove()
  show:   -> @ref.localDom.show()
  hide:   -> @ref.localDom.hide()

Sneaker.ns.set this, 'Sneaker.View', SneakerView


class SneakerPress

  constructor: (@templateFunction = (-> ''), @dom) ->
    Sneaker.util.type @templateFunction, 'function',
      'SneakerPress expects a function as its first argument'

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


Sneaker.ns.set this, 'Sneaker.Press', SneakerPress


class SneakerBox extends Sneaker.Core

  constructor: ->
    do @dump
    for arg in arguments
      @stack.push arg


  dump: ->
    @stack = []
    this

  junk: ->
    if @stack?
      for member in @stack
        if member instanceof Sneaker.Core and jQuery.type(member.quit) is 'function'
          member.quit()
    do @dump


  concat: ->
    @stack = @stack.concat.apply @stack, arguments
    this

  every: (callback, localThis) ->
    if Array.prototype.every?
      @stack.every callback, localThis

  filter: (callback, localThis) ->
    if Array.prototype.filter?
      (new @constructor).concat @stack.filter callback, localThis

  first: ->
    @stack[0]

  forEach: (callback, localThis) ->
    if Array.prototype.forEach?
      @stack.forEach callback, localThis
      this

  indexOf: (searchFor, fromIndex) ->
    if Array.prototype.indexOf?
      @stack.indexOf searchFor, fromIndex

  join: (separator) ->
    @stack.join separator

  last: ->
    @stack[ @stack.length - 1 ]

  lastIndexOf: (searchFor, fromIndex) ->
    if Array.prototype.lastIndexOf?
      @stack.lastIndexOf searchFor, (fromIndex || (@stack.length - 1)) # FF fix

  length: ->
    @stack.length

  map: (callback, localThis) ->
    if Array.prototype.map?
      (new @constructor).concat @stack.map callback, localThis

  pop: ->
    @stack.pop()

  push: ->
    @stack.push.apply @stack, arguments
    this

  reduce: (callback, initialValue) ->
    if Array.prototype.reduce?
      if initialValue? # reduce chokes if undefined is passed into initialValue
        @stack.reduce callback, initialValue
      else
        @stack.reduce callback

  reduceRight: (callback, initialValue) ->
    if Array.prototype.reduce?
      if initialValue? # reduce chokes if undefined is passed into initialValue
        @stack.reduceRight callback, initialValue
      else
        @stack.reduceRight callback

  reverse: ->
    @stack.reverse()
    this

  shift: ->
    @stack.shift()

  slice: (start, end) ->
    if end? # older IE chokes on `end` set to undefined
      (new @constructor).concat @stack.slice start, end
    else
      (new @constructor).concat @stack.slice start

  some: (callback, localThis) ->
    if Array.prototype.some?
      @stack.some callback, localThis

  sort: (fn) ->
    @stack.sort fn
    this

  splice: (index, howMany = 0, insertionArray) ->
    if insertionArray instanceof Sneaker.Box
      insert = insertionArray.stack
    else if $.type(insertionArray) is 'array'
      insert = insertionArray
    else
      insert = []
    applyWith = [index, howMany].concat insert
    (new @constructor).concat @stack.splice.apply @stack, applyWith

  unshift: ->
    @stack.unshift.apply @stack, arguments
    this

  add: ->
    @push.apply this, arguments


  @runs: (name) ->
    @::[name] = ->
      for thing in @stack
        thing[name].apply thing, arguments if thing[name]?

  @runs 'handle'

Sneaker.ns.set this, 'Sneaker.Box', SneakerBox


class SneakerApi extends Sneaker.Core

  @has_default: (hash) ->
    Sneaker.util.type hash, 'object', '@default expects to be passed a hash of name/value pairs'
    defaults = Sneaker.convention.requestDefaultsName()
    @::[defaults] = jQuery.extend( true, {}, @::[defaults], hash )
    return
  @has_defaults: @has_default

  @has_request: (name, fn) ->
    Sneaker.util.type name, 'string', '@request expects the first argument to be a string'
    Sneaker.util.type fn, 'function', '@request expects the second argument to be a function'

    @::[Sneaker.convention.requestName name] = fn
    return

  @install: (mock) ->
    responses = Sneaker.convention.responsesName()
    @::[responses] ||= ( @::[responses]?.slice(0) || [] )

    for response in mock::[responses]
      @::[responses].push response
      @::[responses] = Sneaker.util.uniq @::[responses]

      name = Sneaker.convention.responseName response
      @::[name] = mock::[name]
    return

  @uninstall: ->
    for response in @::[Sneaker.convention.responsesName()]
      delete @::[Sneaker.convention.responseName response]
    delete @::[Sneaker.convention.responsesName()]
    return

  handle: (phrase, eventAttributes) ->
    if Sneaker.util.type phrase, 'string'
      handler = @[Sneaker.convention.handlerName phrase]
      if handler
        deferred = jQuery.Deferred()
        handler.call @, eventAttributes, deferred
        deferred
      else
        @request phrase, eventAttributes

  request: (phrase, eventAttributes) ->
    if Sneaker.util.type phrase, 'string'
      defaults = @[Sneaker.convention.requestDefaultsName()] || {}
      requestHandler = @[Sneaker.convention.requestName phrase]
      if requestHandler?
        request = requestHandler.call this, eventAttributes
        merged = jQuery.extend {}, defaults, request
        responseMock = @[Sneaker.convention.responseName phrase]
        if responseMock?
          Sneaker.ApiMock::respond responseMock.call this, merged, eventAttributes
        else
          jQuery.ajax merged

Sneaker.ns.set this, 'Sneaker.Api', SneakerApi
Sneaker.ns.set this, 'Sneaker.API', SneakerApi


class SneakerApiMock

  @has_response: (name, fn) ->
    Sneaker.util.type name, 'string', '@response expects `name` to be a string'
    Sneaker.util.type fn, 'function', '@response expects the second argument to be a function'

    responses = Sneaker.convention.responsesName()
    (@::[responses] = (@::[responses] || []).slice 0).push name
    @::[Sneaker.convention.responseName name] = fn

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

Sneaker.ns.set this, 'Sneaker.ApiMock', SneakerApiMock