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
          use_args = for index in indicies
            original_arguments[index]
        else
          use_args = original_arguments
        @[Sneaker.convention["#{end}Name"] name][0].apply this, use_args

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