describe 'Sneaker API Wrapper', ->

  it 'resides at Sneaker.Api on the global scope', ->
    expect( Sneaker.Api ).toBeDefined()

  it 'also resides at Sneaker.API on the global scope', ->
    expect( Sneaker.API ).toBeDefined()

  it 'extends Sneaker.Core', ->
    expect( (new Sneaker.Api) instanceof Sneaker.Core ).toBe true


  describe '@has_default', ->
    it 'has constructor method @has_default', ->
      expect( Sneaker.Api.has_default ).toBeDefined()
    it 'has an alias @has_defaults', ->
      expect( Sneaker.Api.has_defaults ).toBe Sneaker.Api.has_default

    it 'extends the defaults object sitting on the prototype', ->
      class Foo extends Sneaker.Api
        @has_default bar: 'foo'
      class Baz extends Foo
        @has_default baz: 'foo'
      class Bat extends Baz
        @has_default baz: 'baz'
      expect( Foo::__requestDefaults ).toEqual {bar:'foo'}
      expect( Baz::__requestDefaults ).toEqual {bar:'foo',baz:'foo'}
      expect( Bat::__requestDefaults ).toEqual {bar:'foo',baz:'baz'}

  describe '@has_request', ->
    it 'has constructor method @has_request', ->
      expect( Sneaker.Api.has_request ).toBeDefined()

    it 'adds a new request handler to the class according to the provided name', ->
      fn = -> {url: '/foo'}
      class Foo extends Sneaker.Api
        @has_request 'bar', fn
      expect( Foo::__request_bar ).toBe fn

    it 'has the capability of adding handlers with whitespace in the name', ->
      fn = -> {url: '/foo'}
      class Foo extends Sneaker.Api
        @has_request 'send reply', fn
      expect( Foo::['__request_send reply']).toBe fn

    it 'freaks out if `name` is not a string', ->
      expect( ->
        class Foo extends Sneaker.Api
          @has_request {}, -> 'foo'
      ).toThrow()

    it 'freaks out if `fn` is not a function', ->
      expect( ->
        class Foo extends Sneaker.Api
          @has_request 'bar', {}
      ).toThrow()


  describe '#handle', ->

    describe 'when there is neither a handler or a request that matches the action', ->
      it 'returns undefined', ->
        class Foo extends Sneaker.Api
        expect( (new Foo).handle 'something' ).not.toBeDefined()

    describe 'when there is a handler and a request that matches the action', ->
      it 'will call the handler instead of the request, to allow for actions before and after a request', ->
        class Foo extends Sneaker.Api
          @has_handler 'test request', ->
          @has_request 'test request', ->
        spyOn Foo::, '__handle_test request'
        spyOn Foo::, '__request_test request'
        (new Foo).handle 'test request'
        expect( Foo::['__handle_test request'] ).toHaveBeenCalled()
        expect( Foo::['__request_test request'] ).not.toHaveBeenCalled()

    describe 'when there is a request but not a handler that matches the action', ->
      it 'will call the request directly', ->
        class Foo extends Sneaker.Api
          @has_request 'test request', ->
        spyOn Foo::, '__request_test request'
        (new Foo).handle 'test request'
        expect( Foo::['__request_test request'] ).toHaveBeenCalled()

    describe 'returning deferreds', ->
      it 'passes in the eventArgs hash as the first argument', ->
        class Foo extends Sneaker.Api
          @has_handler 'hash', (hash) ->
            @hash = hash
        foo = new Foo
        foo.handle 'hash', foo:'bar'
        expect( foo.hash ).toEqual foo:'bar'
      it 'returns a deferred', ->
        class Foo extends Sneaker.Api
          @has_handler 'ping', ->
        foo = new Foo
        ret = foo.handle 'ping'
        expect( ret.then ).toBeDefined()
      it 'passes the returned deferred as the second argument so it can be resolved', ->
        status = undefined
        class Foo extends Sneaker.Api
          @has_handler 'ping', (event, def) -> def.resolve()
        foo = new Foo
        foo.handle('ping').then(
          -> status = 'resolve'
          -> status = 'reject'
        ).always(
          -> expect( status ).toBe 'resolve'
        )
      it 'passes the returned deferred as the second argument so it can be rejected', ->
        status = undefined
        class Foo extends Sneaker.Api
          @has_handler 'ping', (event, def) -> def.reject()
        foo = new Foo
        foo.handle('ping').then(
          -> status = 'resolve'
          -> status = 'reject'
        ).always(
          -> expect( status ).toBe 'reject'
        )

  describe '#request', ->

    it 'gets called when #request is directly invoked on an object', ->
      class Foo extends Sneaker.Api
      spyOn Foo::, 'request'
      (new Foo).request 'request'
      expect( Foo::request ).toHaveBeenCalled()

    it 'can do with request names that have whitespace', ->
      class Foo extends Sneaker.Api
        @has_request 'send comment', ->
      expect( Foo::['__request_send comment']).toBeDefined()

    it 'looks for the request handler on the prototype and executes it with the event', ->
      event = comment: 'woooooo'
      class Foo extends Sneaker.Api
        @has_request 'send comment', ->
      spyOn Foo::, '__request_send comment'
      foo = new Foo
      foo.handle 'send comment', event
      expect( Foo::['__request_send comment']).toHaveBeenCalledWith event

    it 'calls jQuery ajax with the mashup of the defaults and the return from the request handler', ->
      event = comment: 'woooo'
      class Foo extends Sneaker.Api
        @has_default alpha: 'beta'
        @has_request 'send comment', -> foo: 'bar'
      spyOn jQuery, 'ajax'
      (new Foo).handle 'send comment', event
      expect( $.ajax ).toHaveBeenCalledWith alpha: 'beta', foo: 'bar'



  describe 'mock installation and uninstallation', ->
    it 'has @install to install response mocks, for testing and development purposes', ->
      expect( Sneaker.Api.install ).toBeDefined()
    it 'has @uninstall to dump mocks after testing to not pollute subsequent tests', ->
      expect( Sneaker.Api.uninstall ).toBeDefined()

    describe '@install', ->
      it 'adds the names of the response methods to the array of responses installed', ->
        class Foo extends Sneaker.Api
        class FooMock extends Sneaker.ApiMock
          @has_response 'bar', ->
        Foo.install FooMock
        expect( Foo::__responses ).toEqual ['bar']
      it 'adds the response methods of the provided mock to this API object', ->
        barResponse = -> 'wat'
        class Foo extends Sneaker.Api
        class FooMock extends Sneaker.ApiMock
          @has_response 'bar', barResponse
        Foo.install FooMock
        expect( Foo::__response_bar ).toBe barResponse

    describe '@uninstall', ->
      it 'removes all the response methods installed on this API object', ->
        class Foo extends Sneaker.Api
        class FooMock extends Sneaker.ApiMock
          @has_response 'bar', ->
          @has_response 'baz', ->
        Foo.install FooMock
        Foo.uninstall()
        expect( Foo::__responses ).not.toBeDefined()
        expect( Foo::__response_bar ).not.toBeDefined()

  describe 'hitting a request with a corresponding mock installed', ->
    it 'does not hit $.ajax', ->
      class Foo extends Sneaker.Api
        @has_request 'bar', ->
      class FooMock extends Sneaker.ApiMock
        @has_response 'bar', ->
      Foo.install FooMock
      spyOn $, 'ajax'
      foo = new Foo
      foo.handle 'bar'
      expect( $.ajax ).not.toHaveBeenCalled()
    it 'instead hits the mocked response with the return from the request and the event, resulting in a deferred resolved as if the request had been made', ->
      class Foo extends Sneaker.Api
        @has_request 'bar', (attr) ->
          url: "/bar/#{attr.id}"
      class FooMock extends Sneaker.ApiMock
        @has_response 'bar', (request, attr) ->
          body: attr
      holder = undefined;
      Foo.install FooMock
      foo = new Foo
      foo.handle('bar', id: 1).then (response) -> holder = response
      expect( holder ).toEqual id: 1
