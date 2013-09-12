describe 'Sneaker Core', ->
  it 'resides at Sneaker on the global scope', ->
    expect( Sneaker ).toBeDefined()


  describe 'Utility functions', ->

    describe '#type', ->
      it 'does nothing, returns true when the type matches the thing', ->
        expect( Sneaker.util.type 'string', 'string', 'nope' ).toBe true
      it 'throws an error when the type and the thing do not match', ->
        expect( ->
          Sneaker.util.type 'string', 'array', 'thrown!'
        ).toThrow()

    describe '#uniq', ->
      it 'takes an array and returns it uniquified!', ->
        expect( Sneaker.util.uniq [1,1,2,3,3,4,4] ).toEqual [1,2,3,4]


  describe 'Namespace functions', ->

    describe '#getNamespace', ->
      describe 'takes a string or array representing an object path, and the object to trace that path over...', ->

        it '(string) and returns the object at the path, if it exists', ->
          obj =
            what:
              okay:
                yeah: 'what'
          namespace = 'what.okay.yeah'
          expect( Sneaker.ns.get obj, namespace ).toBe obj.what.okay.yeah

        it '(array) and returns the object at the path, if it exists', ->
          obj =
            what:
              okay:
                yeah: 'what'
          namespace = ['what', 'okay', 'yeah']
          expect( Sneaker.ns.get obj, namespace ).toBe obj.what.okay.yeah

        it 'and returns undefined if it does not exist', ->
          obj =
            what:
              nope: 'nope'
          namespace = 'okay.garbage.what'
          expect( Sneaker.ns.get obj, namespace ).toBe undefined

    describe '#createNamespace', ->
      describe 'takes a string or array representing an object path, and the object to create that path under...', ->

        it '(string) and returns the object at the end of the new namespace', ->
          obj = {}
          namespace = 'what.okay.yeah'
          Sneaker.ns.create obj, namespace
          expect( obj.what.okay.yeah ).toBeDefined()

        it '(array) and returns the object at the end of the new namespace', ->
          obj = {}
          namespace = ['what', 'okay', 'yeah']
          Sneaker.ns.create obj, namespace
          expect( obj.what.okay.yeah ).toBeDefined()

    describe '#setNamespace', ->
      it 'assigns the given object to the namespace provided under the object provided', ->
        obj = {}
        namespace = 'what.okay'
        value = 'yeah'
        Sneaker.ns.set obj, namespace, value
        expect( obj.what.okay ).toEqual value


#==================================================================================================#

  describe 'Sneaker Core object', ->
    it 'resides at Sneaker.Core on the global scope', ->
      expect( Sneaker.Core ).toBeDefined()

    describe '@include( module )', ->
      it 'has a constructor method @include for including modules', ->
        expect( Sneaker.Core.include ).toBeDefined()
      it 'runs through the constructor methods on the module object and adds them to this class', ->
        class Foo extends Sneaker.Core
        class FooModule
          @bar: ->
          @baz: ->
        Foo.include FooModule
        expect( Foo.bar ).toBeDefined
        expect( Foo.baz ).toBeDefined
      it 'runs through the methods on the module object and adds them to the prototype of this class', ->
        class Foo extends Sneaker.Core
        class FooModule
          bar: ->
          baz: ->
        Foo.include FooModule
        expect( Foo::bar ).toBeDefined()
        expect( Foo::baz ).toBeDefined()
      it 'looks for a special constructor method `@has_module_setup` and runs that against the class', ->
        class Foo extends Sneaker.Core
        class FooModule
          @has_module_setup: ->
            @has_init 'b', ->
        Foo.include FooModule
        expect( Foo::__inits.length ).toBe 1


    describe '@has_handler( phrase, fn )', ->

      it 'has a constructor method @has_handler', ->
        expect( Sneaker.Core.has_handler ).toBeDefined()

      it 'adds a new event handler to the class according to the provided phrase', ->
        fn = -> console.log 'handled'
        class Foo extends Sneaker.Core
          @has_handler 'bar', fn
        expect( Foo::__handle_bar ).toBe fn

      it 'has the capability of adding handlers with whitespace in the name', ->
        fn = -> console.log 'whitespace'
        class Foo extends Sneaker.Core
          @has_handler 'do something', fn
        expect( Foo::['__handle_do something']).toBe fn

      it 'freaks out if `phrase` is not a string', ->
        expect( ->
          class Foo extends Sneaker.Core
            @has_handler {}, -> 'foo'
        ).toThrow()

      it 'freaks out if `fn` is not a function', ->
        expect( ->
          class Foo extends Sneaker.Core
            @has_handler 'bar', {}
        ).toThrow()


    describe '#handle( phrase, eventAttributes )', ->
      it 'exposes #handle as a means of notifying a Sneaker of events', ->
        expect( (new Sneaker.Core ).handle instanceof Function ).toBe true

      describe 'takes the handler phrase as the first argument', ->
        it 'looks for `__handle_{{name}}` (under default refs) and calls it'
        class Foo extends Sneaker.Core
          @has_handler 'trigger this handler', ->
        instance = new Foo
        spyOn instance, '__handle_trigger this handler'
        instance.handle 'trigger this handler'
        expect( instance['__handle_trigger this handler'] ).toHaveBeenCalled()

      describe 'takes a hash of additional attributes as the second argument', ->
        it 'it calls the handler with the provided attributes hash', ->
          class Foo extends Sneaker.Core
            @has_handler 'bar', (attr) ->
          instance = new Foo
          spyOn instance, '__handle_bar'
          instance.handle 'bar', baz: 'bat'
          expect( instance.__handle_bar ).toHaveBeenCalledWith baz: 'bat'

    describe '@has_init', ->
      it 'adds the callback to the prototype', ->
        fn = ->
        class Foo extends Sneaker.Core
          @has_init 'bar', fn
        expect( Foo::__init_bar ).toBeDefined
        expect( Foo::__init_bar[0] ).toBe fn
        expect( Foo::__init_bar[1] ).toEqual []
      it 'adds the callback to the prototype with indicies', ->
        class Foo extends Sneaker.Core
          @has_init 'bar', [5,6], ->
        expect( Foo::__init_bar[1] ).toEqual [5,6]
      it 'adds the name to the end init array', ->
        class Foo extends Sneaker.Core
          @has_init 'bar', ->
        expect( Foo::__inits[0] ).toBe 'bar'
      it 'the callback is run with the Sneaker as this', ->
        class Foo extends Sneaker.Core
          @has_init 'bar', -> @x = 5
        expect( (new Foo).x ).toBe 5
      it 'the callback is called with all args passed to constructor if no arg indices are given', ->
        class Foo extends Sneaker.Core
          @has_init 'bar', (@x, @y) ->
        expect( (new Foo 2, 3).y ).toBe 3
      it 'the callback is called with just the args indicated in indices if provided', ->
        class Foo extends Sneaker.Core
          @has_init 'bar', [1,2], (@x, @y) ->
          @has_init 'baz', [0], (@z) ->
        foo = new Foo 'a', 'b', 'c'
        expect( foo.y ).toBe 'c'
        expect( foo.z ).toBe 'a'
      it 'checks to see if indicies (if provided) is an array and throws', ->
        expect( ->
          class Foo extends Sneaker.Core
            @has_init 'bar', 'bogus', ->
        ).toThrow()
      it 'checks to see if callback is a function and throws', ->
        expect( ->
          class Foo extends Sneaker.Core
            @has_init 'bar', 'bogus'
        ).toThrow()
        expect( ->
          class Foo extends Sneaker.Core
            @has_init 'bar', [1], 'bogus'
        ).toThrow()
      it 'allows overwriting - does not add name to list twice', ->
        class Foo extends Sneaker.Core
          @has_init 'bar', ->
        class Goo extends Foo
          @has_init 'bar', ->
        expect( Goo::__inits.length ).toBe 1

    describe '@has_init_order', ->
      it 'checks that it is an array and throws', ->
        expect( ->
          class Foo extends Sneaker.Core
            @has_init_order 'bogus'
        ).toThrow()
      it 'replaces the order array with the one provided', ->
        class Foo extends Sneaker.Core
          @has_init_order ['bar', 'baz']
        expect( Foo::__inits_order ).toEqual ['bar', 'baz']
        class Foo1 extends Foo
        expect( Foo1::__inits_order ).toEqual ['bar', 'baz']
        class Foo2 extends Foo1
          @has_init_order ['baz', 'bar']
        expect( Foo1::__inits_order ).toEqual ['bar', 'baz']
        expect( Foo2::__inits_order ).toEqual ['baz', 'bar']
      it 'the callbacks are run in the order provided', ->
        class Foo extends Sneaker.Core
          @has_init 'foo', -> @x = 'foo'
          @has_init 'bar', -> @x = 'bar'
        expect( (new Foo).x ).toBe 'bar'
        class Foo1 extends Foo
          @has_init_order ['bar', 'foo']
        expect( (new Foo1).x ).toBe 'foo'
      it 'the callbacks not mentioned in the order array are run after, in the order added', ->
        class Foo extends Sneaker.Core
          @has_init 'a', -> @x = 'a'
          @has_init 'b', -> @x = 'b'
          @has_init 'c', -> @x = 'c'
          @has_init 'd', -> @x = 'd'
          @has_init_order ['c', 'd']
        expect( (new Foo).x ).toBe 'b'

    describe '@skips_init', ->
      it 'adds the name to the skip array', ->
        class Foo extends Sneaker.Core
          @skips_init 'bar'
        expect( Foo::__inits_skip ).toEqual ['bar']
      it 'does not run the callbacks in the skip array', ->
        class Foo extends Sneaker.Core
          @has_init 'a', -> @x = 'a'
          @has_init 'b', -> @x = 'b'
          @skips_init 'b'
        expect( (new Foo).x ).toBe 'a'

    describe '@runs_init', ->
      it 'removes the name from the skip array', ->
        class Foo extends Sneaker.Core
          @skips_init 'bar'
        class Goo extends Foo
          @runs_init 'bar'
        expect( Foo::__inits_skip ).toEqual ['bar']
        expect( Goo::__inits_skip ).toEqual []
      it 'runs the callback', ->
        class Foo extends Sneaker.Core
          @has_init 'a', -> @x = 1
          @has_init 'b', -> @x = 2
          @skips_init 'b'
        class Goo extends Foo
          @runs_init 'b'
        expect( (new Foo).x ).toBe 1
        expect( (new Goo).x ).toBe 2


    describe '@has_quit', ->
      it 'adds the callback to the prototype', ->
        fn = ->
        class Foo extends Sneaker.Core
          @has_quit 'bar', fn
        expect( Foo::__quit_bar ).toBeDefined
        expect( Foo::__quit_bar[0] ).toBe fn
        expect( Foo::__quit_bar[1] ).toEqual []
      it 'adds the callback to the prototype with indicies', ->
        class Foo extends Sneaker.Core
          @has_quit 'bar', [5,6], ->
        expect( Foo::__quit_bar[1] ).toEqual [5,6]
      it 'adds the name to the end quit array', ->
        class Foo extends Sneaker.Core
          @has_quit 'bar', ->
        expect( Foo::__quits[0] ).toBe 'bar'
      it 'the callback is run with the Sneaker as this on #quit', ->
        x = 0
        class Foo extends Sneaker.Core
          @has_quit 'bar', -> x = 5
        (new Foo).quit()
        expect( x ).toBe 5
      it 'the callback is called with all args passed to #quit if no arg indices are given', ->
        class Foo extends Sneaker.Core
          @has_quit 'bar', (@x, @y) ->
        foo = new Foo
        foo.quit 2, 3
        expect( foo.y ).toBe 3
      it 'the callback is called with just the args indicated in indices if provided', ->
        class Foo extends Sneaker.Core
          @has_quit 'bar', [1,2], (@x, @y) ->
        foo = new Foo
        foo.quit 'a', 'b', 'c'
        expect( foo.y ).toBe 'c'
      it 'checks to see if indicies (if provided) is an array and throws', ->
        expect( ->
          class Foo extends Sneaker.Core
            @has_quit 'bar', 'bogus', ->
        ).toThrow()
      it 'checks to see if callback is a function and throws', ->
        expect( ->
          class Foo extends Sneaker.Core
            @has_quit 'bar', 'bogus'
        ).toThrow()
        expect( ->
          class Foo extends Sneaker.Core
            @has_quit 'bar', [1], 'bogus'
        ).toThrow()
      it 'allows overwriting - does not add name to list twice', ->
        class Foo extends Sneaker.Core
          @has_quit 'bar', ->
        class Goo extends Foo
          @has_quit 'bar', ->
        expect( Goo::__quits.length ).toBe 1

    describe '@has_quit_order', ->
      it 'checks that it is an array and throws', ->
        expect( ->
          class Foo extends Sneaker.Core
            @has_quit_order 'bogus'
        ).toThrow()
      it 'replaces the order array with the one provided', ->
        class Foo extends Sneaker.Core
          @has_quit_order ['bar', 'baz']
        expect( Foo::__quits_order ).toEqual ['bar', 'baz']
        class Foo1 extends Foo
        expect( Foo1::__quits_order ).toEqual ['bar', 'baz']
        class Foo2 extends Foo1
          @has_quit_order ['baz', 'bar']
        expect( Foo1::__quits_order ).toEqual ['bar', 'baz']
        expect( Foo2::__quits_order ).toEqual ['baz', 'bar']
      it 'the callbacks are run in the order provided', ->
        class Foo extends Sneaker.Core
          @has_quit 'foo', -> @x = 'foo'
          @has_quit 'bar', -> @x = 'bar'
        foo = new Foo
        foo.quit()
        expect( foo.x ).toBe 'bar'
        class Foo1 extends Foo
          @has_quit_order ['bar', 'foo']
        foo1 = new Foo1
        foo1.quit()
        expect( foo1.x ).toBe 'foo'
      it 'the callbacks not mentioned in the order array are run after, in the order added', ->
        class Foo extends Sneaker.Core
          @has_quit 'a', -> @x = 'a'
          @has_quit 'b', -> @x = 'b'
          @has_quit 'c', -> @x = 'c'
          @has_quit 'd', -> @x = 'd'
          @has_quit_order ['c', 'd']
        foo = new Foo
        foo.quit()
        expect( foo.x ).toBe 'b'

    describe '@skips_quit', ->
      it 'adds the name to the skip array', ->
        class Foo extends Sneaker.Core
          @skips_quit 'bar'
        expect( Foo::__quits_skip ).toEqual ['bar']
      it 'does not run the callbacks in the skip array', ->
        class Foo extends Sneaker.Core
          @has_quit 'a', -> @x = 'a'
          @has_quit 'b', -> @x = 'b'
          @skips_quit 'b'
        foo = new Foo
        foo.quit()
        expect( foo.x ).toBe 'a'

    describe '@runs_quit', ->
      it 'removes the name from the skip array', ->
        class Foo extends Sneaker.Core
          @skips_quit 'bar'
        class Goo extends Foo
          @runs_quit 'bar'
        expect( Foo::__quits_skip ).toEqual ['bar']
        expect( Goo::__quits_skip ).toEqual []
      it 'runs the callback', ->
        class Foo extends Sneaker.Core
          @has_quit 'a', -> @x = 1
          @has_quit 'b', -> @x = 2
          @skips_quit 'b'
        class Goo extends Foo
          @runs_quit 'b'
        foo = new Foo
        foo.quit()
        goo = new Goo
        goo.quit()
        expect( foo.x ).toBe 1
        expect( goo.x ).toBe 2
