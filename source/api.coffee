class SneakerApi extends Sneaker.Core

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

Sneaker.ns.set this, 'Sneaker.Api', SneakerApi
Sneaker.ns.set this, 'Sneaker.API', SneakerApi