describe 'Sneaker View', ->

  it 'resides at Sneaker.View on the global scope', ->
    expect( Sneaker.View ).toBeDefined()

  it 'extends Sneaker.Core', ->
    expect( (new Sneaker.View) instanceof Sneaker.Core ).toBe true


  describe '@has_hook( hooksHash )', ->
    it 'has constructor method @has_hook', ->
      expect( Sneaker.View.has_hook ).toBeDefined()
    it 'has an alias @has_hooks', ->
      expect( Sneaker.View.has_hooks ).toBe Sneaker.View.has_hook

    it 'provides the constructor with instructions for building DOM hooks on instantiation', ->
      class Foo extends Sneaker.View
        @has_base -> '<div>{{stuff}}</div>'
        @has_hook
          captainHook:
            smee: '.yarr'
      expect( Foo::__hooks ).toEqual captainHook: smee: '.yarr'
      foo = new Foo
      expect( foo.dom.captainHook.smee ).toBeDefined()

    it 'deep merges new hashes from descendent classes', ->
      class Foo extends Sneaker.View
        @has_hook
          red:
            pink: '.pink'
            deepred: '.deepred'
      class Bar extends Foo
        @has_hook
          red:
            red: '.red'
      expect( Bar::__hooks ).toEqual red: pink: '.pink', red: '.red', deepred: '.deepred'

    it 'does not backwards-pollute the prototype', ->
      class Foo extends Sneaker.View
        @has_hook
          alpha: 'alpha'
      class Bar extends Foo
        @has_hook
          beta: 'beta'
      expect( Foo::__hooks ).toEqual alpha: 'alpha'
      expect( Bar::__hooks ).toEqual alpha: 'alpha', beta: 'beta'

    it 'freaks out if `hooksHash` is not a hash', ->
      expect( ->
        class Foo extends Sneaker.View
          @has_hook 'foo'
      ).toThrow()

  describe '@has_listener( types, hook, fn )', ->
    it 'has constructor method @has_listener', ->
      expect( Sneaker.View.has_listener ).toBeDefined()

    it 'provides the constructor with instructions for setting up delegated DOM event handlers', ->
      class Foo extends Sneaker.View
        @has_base -> '''
          <div>
            <div class="foo"></div>
            <div class="bar"></div>
          </div>
        '''
        @has_hook
          foo: '.foo'
          bar: '.bar'
        @has_listener 'click', 'foo', -> @switch = 'foo'
        @has_listener 'click', 'bar', -> @switch = 'bar'
      class Bar extends Foo
        @has_listener 'click', 'baz', -> console.log 'baz'
      expect( Foo::__interactions ).toBeDefined()
      expect( Foo::__interaction_cb_1 ).toBeDefined()
      expect( Bar::__interaction_cb_2 ).toBeDefined()
      expect( Foo::__interaction_cb_2 ).not.toBeDefined()
      expect( Foo::__interactions.length ).toBe 2
      expect( Bar::__interactions.length ).toBe 3
      foo = new Foo
      expect( foo.switch ).toBe undefined
      foo.dom.foo.click()
      expect( foo.switch ).toBe 'foo'
      foo.dom.bar.click()
      expect( foo.switch ).toBe 'bar'

    it 'stores the callback functions into the prototype, saving its name for later use', ->
      class Foo extends Sneaker.View
        @has_listener 'click', 'bar', -> 'baz'
      expect( Foo::__interactions[0] ).toEqual {
        types: 'click'
        hook: 'bar'
        fn: '__interaction_cb_0'
      }

    it 'freaks out if `types` is not a string', ->
      expect( ->
        class Foo extends Sneaker.View
          @has_listener {bogus:'nonsense'}, 'wat', -> console.log 'waaaat'
      ).toThrow()

    it 'freaks out if `hook` is not a string', ->
      expect( ->
        class Foo extends Sneaker.View
          @has_listener 'click', {bogus:'nonsense'}, -> console.log 'nope'
      ).toThrow()

    it 'freaks out if `fn` is not either a string or a function', ->
      expect( ->
        class Foo extends Sneaker.View
          @has_listener 'click', 'wat', {bogus:'nonsense'}
      ).toThrow()

  describe '@has_base( templateFn )', ->
    it 'has constructor method @has_base', ->
      expect( Sneaker.View.has_base ).toBeDefined()

    it 'adds the base template to the prototype for use by the constructor', ->
      template = -> '<div class="base"></div>'
      class Foo extends Sneaker.View
        @has_base template
      expect( Foo::__template_base ).toBe template

    it 'freaks out if given anything other than a function', ->
      expect(->
        template = 'bogus'
        class Foo extends Sneaker.View
          @has_base template
      ).toThrow()

  describe '@has_template( name, fn )', ->
    it 'has constructor method @has_template', ->
      expect( Sneaker.View.has_template ).toBeDefined()

    it 'adds a template to the class - intended to hold a reference to a `render` type function', ->
      fn = -> '<div>{{stuff}}</div>'
      class Foo extends Sneaker.View
        @has_template 'bar', fn
      expect( Foo::__template_bar ).toBe fn

    it 'freaks out if `name` is not a string', ->
      expect( ->
        class Foo extends Sneaker.View
          @has_template {}, -> 'foo'
      ).toThrow()

    it 'freaks out if `fn` is not a function', ->
      expect()


  describe '#constructor( [anchor][, args...])', ->

    describe 'sets up instance variables', ->
      beforeEach -> @view = new Sneaker.View
      it 'has @__localDom as a reference to the DOM chunk that belongs to this view', ->
        expect( @view.__localDom ).toBeDefined()
      it 'has an empty jquery as the default for @__localDom', ->
        expect( @view.__localDom ).toEqual $()
      it 'has a cached dom hooks tree at @dom', ->
        expect( @view.dom ).toBeDefined()
      it 'has an empty object other than base (:empty jQuery) as the default for @dom', ->
        expect( @view.dom ).toEqual {base: $()}

    describe 'sets up hooks into the local DOM chunk', ->
      it 'crawls the hook object defined and establishes hooks into the local DOM chunk', ->
        template = -> '''
          <div class="foo">
            <div class="bar"></div>
            <div class="baz">
              <div class="alpha"></div>
              <div class="beta"></div>
            </div>
          </div>
        '''
        class Foo extends Sneaker.View
          @has_base template
          @has_hook
            bar: '.bar'
            baz:
              alpha: '.alpha'
              beta: '.beta'
        @instance = new Foo
        expect( @instance.dom.bar.length ).toBe 1
        expect( @instance.dom.baz.beta.length ).toBe 1

      it 'attaches interactions to the given hook on the given interaction on instantiation', ->
        spy =
          callback: -> console.log 'wat'
        spyOn spy, 'callback'
        class Foo extends Sneaker.View
          @has_base -> '<div><div class="clickThis">Click it</div></div>'
          @has_hook
            clickThis: '.clickThis'
          @has_listener 'click', 'clickThis', spy.callback
        foo = new Foo
        foo.dom.clickThis.click()
        expect( spy.callback ).toHaveBeenCalled()

      it 'throws an exception if the given hook path returns undefined', ->
        expect( ->
          class Foo extends Sneaker.View
            @has_base -> '<div><span></span></div>'
            @has_hook span: 'span'
            @has_listener 'click', 'clearly.bogus', ->
          foo = new Foo
        ).toThrow()

      it 'attaches interactions with the hook specified as `base` to the base element', ->
        spy =
          callback: -> console.log 'wat'
        spyOn spy, 'callback'
        class Foo extends Sneaker.View
          @has_base -> '<div><div class="clickThis">Click it</div></div>'
          @has_hook
            clickThis: '.clickThis'
          @has_listener 'click', 'base', spy.callback
        foo = new Foo
        foo.dom.clickThis.click()
        expect( spy.callback ).toHaveBeenCalled()

      it 'attaches interactions such that the Sneaker object is available to the callback', ->
        class Foo extends Sneaker.View
          @has_base  -> '<div><div class="clickThis">Click it</div></div>'
          @has_hook clickThis: '.clickThis'
          @has_listener 'click', 'clickThis', (event) -> @callMe(event)

          callMe: (event) ->
            console.log target: $(event.target).data()

        bar = new Foo
        baz = new Foo
        spyOn bar, 'callMe'
        spyOn baz, 'callMe'
        bar.dom.clickThis.click()
        expect( bar.callMe ).toHaveBeenCalled()
        expect( baz.callMe ).not.toHaveBeenCalled()

      describe 'renders the base to @dom.base if one is provided', ->
        it 'renders the base if there is one', ->
          class Foo extends Sneaker.View
            @has_base -> '<section class="foo"></section>'
          expect( (new Foo).dom.base.length ).toBe 1
        it 'puts an empty jQuery into @dom.base if there isnt', ->
          class Foo extends Sneaker.View
          expect( (new Foo).dom.base.length ).toBe 0

      it 'assigns the anchor to @dom.base if one is provided and there isnt a base', ->
        $('<div class="view"></div>').appendTo('body')
        class Foo extends Sneaker.View
          @has_anchor '.view'
        expect( (new Foo).dom.base.filter('.view').length ).toBe 1


  describe 'on #quit', ->
    it 'removes the local DOM (View: remove DOM)', ->
      $('<div class="view"></div>').appendTo('body')
      class Foo extends Sneaker.View
        @has_base -> '<div class="foo"></div>'
      foo = new Foo
      foo.appendTo $('.view')
      expect( $('.foo').length ).toBe 1
      foo.quit()
      expect( $('.foo').length ).toBe 0
    it 'does not remove the base element if anchoring was used', ->
      $('<div class="anchor"></div>').appendTo('body')
      class Foo extends Sneaker.View
        @has_anchor '.anchor'
        @has_template 'stuff', -> '<section class="stuff"></section>'
        @has_init 'render stuff', -> @render('stuff').end('base')
      foo = new Foo
      expect( $('.anchor .stuff').length ).toBe 1
      foo.quit()
      expect( $('.anchor .stuff').length ).toBe 0
      expect( $('.anchor').length ).toBe 1



  describe '#rehook()', ->
    it 'runs the dom hooking recursion, so that @dom reflects changes in the local DOM chunk', ->
      class Foo extends Sneaker.View
        @has_base -> '<div><i class="a"></i></div>'
        @has_template 'b', -> '<i class="b"></i>'
        @has_hooks
          a: '.a'
          b: '.b'
        run: -> @render('b').bottom('a')
      foo = new Foo
      expect( foo.dom.b.length ).toBe 0
      do foo.run
      expect( foo.dom.b.length ).toBe 0
      do foo.rehook
      expect( foo.dom.b.length ).toBe 1


  describe '#render( name [, context] )', ->

    it 'has #render as a means of executing a call to a local template', ->
      expect( Sneaker.View::render instanceof Function ).toBe true

    it 'takes a template name as the argument, returning a SneakerPress wrapping the template', ->
      class Foo extends Sneaker.View
        @has_template 'bar', -> 'bar!'
      foo = new Foo
      expect( foo.render('bar') instanceof Sneaker.Press ).toBe true
      expect( foo.render('bar').to_s() ).toBe 'bar!'
      expect( foo.render('bar').dom ).toBe foo.dom

    it 'returns undefined if there is no template under the given name', ->
      class Foo extends Sneaker.View
        @has_template 'bar', -> 'bar!'
      foo = new Foo
      expect( foo.render('baz') ).toBe undefined


  describe '#appendTo', ->
    it 'appends the local dom to the given element', ->
      destination = $('<div>')
      class Foo extends Sneaker.View
        @has_base -> "<div class='foo'></div>"
      foo = new Foo
      foo.appendTo destination
      expect( destination.find('.foo').length ).toBe 1

    it 'appends the local dom to the first element given, if given a set of destination elements', ->
      context = $('<div></div><div></div>')
      destination = context.filter('div')
      class Foo extends Sneaker.View
        @has_base -> '<div class="foo"></div>'
      (new Foo).appendTo destination
      expect( context.eq(0).find('.foo').length ).toBe 1
      expect( context.eq(1).find('.foo').length ).toBe 0

  describe '#prependTo', ->
    it 'prepends the local dom to the given element', ->
      context = $('<div class="context"><div></div></div>')
      class Foo extends Sneaker.View
        @has_base -> '<div class="foo"></div>'
      (new Foo).prependTo context
      expect( context.find('div').eq(0).hasClass('foo') ).toBe true

  describe '#insertAfter', ->
    it 'appends the local dom as a lower sibling to the given element', ->
      context = $('<div><div class="target"></div></div>')
      target = context.find '.target'
      class Foo extends Sneaker.View
        @has_base -> '<div class="foo"></div>'
      (new Foo).insertAfter target
      expect( context.find('.target + .foo').length ).toBe 1

  describe '#insertBefore', ->
    it 'appends the local dom as an upper sibling to the given element', ->
      context = $ '<div><div class="target"></div></div>'
      target = context.find '.target'
      class Foo extends Sneaker.View
        @has_base -> '<div class="foo"></div>'
      (new Foo).insertBefore target
      expect( context.find('.foo + .target').length ).toBe 1
