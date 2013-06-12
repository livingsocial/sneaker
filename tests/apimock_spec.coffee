describe 'Sneaker API Mocker', ->
  it 'resides at `Sneaker.ApiMock`', ->
    expect( Sneaker.ApiMock ).toBeDefined()

  describe '@has_response', ->
    it 'has @has_response to provide a mocked response to a particular request', ->
      expect( Sneaker.ApiMock.has_response ).toBeDefined()

    it 'adds the name of the response to the responses array', ->
      class Foo extends Sneaker.ApiMock
        @has_response 'bar', ->
      expect( Foo::__responses ).toEqual ['bar']

    it 'adds the provided function to the prototype', ->
      baz = -> console.log 'baz'
      class Foo extends Sneaker.ApiMock
        @has_response 'bar', baz
      expect( Foo::__response_bar ).toBe baz

    it 'freaks out if `name` is not a string', ->
      expect( ->
        class Foo extends Sneaker.ApiMock
          @has_response {}, ->
      ).toThrow()

    it 'freaks out if `fn` is not a function', ->
      expect( ->
        class Foo extends Sneaker.ApiMock
          @has_response 'bar', {}
      ).toThrow()


  describe '#respond', ->
    it 'returns a deferred mimicking the behavior of $.ajax', ->
      expect( Sneaker.ApiMock::respond().done ).toBeDefined()

    it 'resolves to the success path when it is mocking a successful status code', ->
      result = undefined;
      Sneaker.ApiMock::respond(status:200).then(
        -> result = 'success'
        -> result = 'fail'
      ).always(
        -> expect( result ).toEqual 'success'
      )


    it 'resolves to the fail path when it is mocking an error status code', ->
      result = undefined;
      Sneaker.ApiMock::respond(status:500).then(
        -> result = 'success'
        -> result = 'fail'
      ).always(
        -> expect( result ).toEqual 'fail'
      )


    it 'by default responds with a status of 200/OK', ->
      status = undefined
      Sneaker.ApiMock::respond().then(
        (body, statusText) -> status = statusText
        () ->
      ).always(
        -> expect( status ).toEqual 'OK'
      )

    it 'by default responds with a null body', ->
      respBody = undefined
      Sneaker.ApiMock::respond().then(
        (body) -> respBody = body
        () ->
      ).always(
        -> expect( respBody ).toBe null
      )
