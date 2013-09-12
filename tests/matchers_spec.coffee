describe 'Jasmine matchers for Sneaker', ->

  describe '#toExtend', ->
    it 'can text whether a class extends another class', ->
      class Foo extends Sneaker.View
      expect( Foo ).toExtend Sneaker.View
    it 'can test whether a class does not extend another class', ->
      class Foo extends Sneaker.View
      expect( Foo ).not.toExtend Sneaker.Api


  describe '#toHandle', ->
    it 'can test whether a class is equipped to handle an event of a particular name', ->
      class Foo extends Sneaker.View
        @has_handler 'bar', ->
      expect( Foo ).toHandle 'bar'
    it 'can test whether a class is not equipped to handle an event of a particular name', ->
      class Foo extends Sneaker.View
        @has_handler 'bar', ->
      expect( Foo ).not.toHandle 'baz'
    it 'has an alias #toHaveHandler', ->
      class Foo extends Sneaker.View
        @has_handler 'bar', ->
      expect( Foo ).toHaveHandler 'bar'
      class Foo extends Sneaker.View
        @has_handler 'bar', ->
      expect( Foo ).not.toHaveHandler 'baz'


  describe '#toHook', ->
    it 'can test whether a class is written to establish a hook at the given namespace and selector', ->
      class Foo extends Sneaker.View
        @has_hook foo: bar: '.baz'
      expect( Foo ).toHook 'foo.bar', '.baz'
    it 'can test whether a class is not written to establish a hook at the given namespace and selector', ->
      class Foo extends Sneaker.View
        @has_hook foo: bar: '.baz'
      expect( Foo ).toHook 'foo.bar', '.baz'
    it 'can test whether a class is written to establish a hook at the given namespace (selector omitted)', ->
      class Foo extends Sneaker.View
        @has_hook foo: 'bar'
      expect( Foo ).toHook 'foo'
    it 'can test whether a class is not written to establish a hook at the given namespace (selector omitted)', ->
      class Foo extends Sneaker.View
        @has_hook foo: 'bar'
      expect( Foo ).not.toHook 'baz'
    it 'has an alias #toHaveHook', ->
      class Foo extends Sneaker.View
        @has_hook foo: bar: '.baz'
      expect( Foo ).toHaveHook 'foo.bar', '.baz'
      class Foo extends Sneaker.View
        @has_hook foo: bar: '.baz'
      expect( Foo ).toHaveHook 'foo.bar', '.baz'


  describe '#toListenFor', ->
    it 'can test whether a class is written to listen for a DOM event of a particular type/hook combination', ->
      class Foo extends Sneaker.View
        @has_hook a: '.a'
        @has_listener 'click', 'a', ->
      expect( Foo ).toListenFor 'click', 'a'
    it 'can test whether a class is not written to listen for a DOM event of a particular type/hook combination', ->
      class Foo extends Sneaker.View
        @has_hook a: '.a'
        @has_listener 'mouseover', 'a', ->
      expect( Foo ).not.toListenFor 'click', 'a'
    it 'has an alias #toHaveListener', ->
      class Foo extends Sneaker.View
        @has_hook a: '.a'
        @has_listener 'click', 'a', ->
      expect( Foo ).toHaveListener 'click', 'a'
      class Foo extends Sneaker.View
        @has_hook a: '.a'
        @has_listener 'mouseover', 'a', ->
      expect( Foo ).not.toHaveListener 'click', 'a'


  describe '#toTemplate', ->
    it 'can test whether a class has a template with the given name', ->
      class Foo extends Sneaker.View
        @has_template 'bar', ->
      expect( Foo ).toTemplate 'bar'
    it 'can test whether a class does not have a template with the given name', ->
      class Foo extends Sneaker.View
        @has_template 'bar', ->
      expect( Foo ).not.toTemplate 'baz'
    it 'has an alias #toHaveTemplate', ->
      class Foo extends Sneaker.View
        @has_template 'bar', ->
      expect( Foo ).toHaveTemplate 'bar'
      class Foo extends Sneaker.View
        @has_template 'bar', ->
      expect( Foo ).not.toHaveTemplate 'baz'


  describe '#toHaveRequest', ->
    it 'can test whether an API has a request under the given phrase', ->
      class Foo extends Sneaker.API
        @has_request 'bar', ->
      expect( Foo ).toHaveRequest 'bar'
    it 'can test whether an API does not have a request under the given phrase', ->
      class Foo extends Sneaker.API
        @has_request 'bar', ->
      expect( Foo ).not.toHaveRequest 'rat'



  describe '#toAlter', ->
    it 'can test whether executing a function changes something', ->
      class Foo extends Sneaker.View
        init: -> @data = 0
        @has_handler 'change', ->
          @data = 1

      foo = new Foo
      expect( -> foo.handle 'change' ).toAlter -> foo.data

    it 'can test whether executing a function does not changes something', ->
      class Foo extends Sneaker.View
        init: -> @data = 0
        @has_handler 'change', -> #nothing

      foo = new Foo
      expect( -> foo.handle 'change' ).not.toAlter -> foo.data


  describe '#toAlterContentsOf', ->
    it 'can test whether executing a function changes the contents of an element', ->
      class Foo extends Sneaker.View
        @has_base -> '<div class="foo">bar</div>'
        @has_handler 'baz', -> @dom.base.html '<div class="baz">baz</div>'

      foo = new Foo
      expect( -> foo.handle 'baz' ).toAlterContentsOf foo.dom.base

    it 'can test whether executing a function does not change the contents of an element', ->
      class Foo extends Sneaker.View
        @has_base -> '<div class="foo">bar</div>'
        @has_handler 'baz', -> #nothing

      foo = new Foo
      expect( -> foo.handle 'baz' ).not.toAlterContentsOf foo.dom.base
