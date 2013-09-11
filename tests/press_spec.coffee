describe 'Sneaker Press', ->
  it 'resides at Sneaker.Press on the global scope', ->
    expect( Sneaker.Press ).toBeDefined()

  it 'does not extend Sneaker.Core', ->
    expect( Sneaker.Press ).not.toExtend Sneaker.Core


  describe '#constructor( [templateFunction] [, textOnly] )', ->

    describe 'takes a template function as the first argument', ->
      it 'assigns it to @templateFunction', ->
        fn = -> 'foo'
        foo = new Sneaker.Press fn
        expect( foo.templateFunction ).toBe fn
      it 'freaks out if fn is not a function', ->
        fn = 'bogus'
        expect( -> foo = new Sneaker.Press fn ).toThrow()
      it 'defaults to a function that takes no arguments and returns an empty string', ->
        expect( (new Sneaker.Press).templateFunction() ).toBe ''


    describe 'takes a contextual dom tree object as the optional second argument', ->
      it 'assigns it to @dom', ->
        dom = {}
        foo = new Sneaker.Press undefined, dom
        expect( foo.dom ).toBe dom

    it 'assigns an empty object to @context', ->
      expect( _.isEqual (new Sneaker.Press).context, {} ).toBe true


  describe '#with( context )', ->
    it 'has instance method `with`', ->
      expect( (new Sneaker.Press).with ).toBeDefined()
    it 'returns the Press object so as to be chainable', ->
      foo = new Sneaker.Press
      expect( foo.with() ).toBe foo
    describe 'takes an object describing template rendering context as the first argument', ->
      it 'freaks out if context is not an object', ->
        expect( -> (new Sneaker.Press).with(->) ).toThrow()
      it 'replaces the current context of the press with the one given', ->
        foo = (new Sneaker.Press).with(foo:'bar')
        expect( _.isEqual foo.context, foo:'bar').toBe true


  describe '#and( additionalContext )', ->
    it 'has instance method `and`', ->
      expect( (new Sneaker.Press).and ).toBeDefined()
    it 'returns the Press object so as to be chainable', ->
      foo = new Sneaker.Press
      expect( foo.and() ).toBe foo
    describe 'takes an object describing additional template rendering context as the first argument', ->
      it 'freaks out if additionalContext is not an object', ->
        expect( -> (new Sneaker.Press).and(->) ).toThrow()
      it 'merges the additional context passed in with the previously existing context object', ->
        foo = (new Sneaker.Press).with(foo:'bar', baz:'bat').and(baz:'wat')
        expect( _.isEqual foo.context, {foo:'bar', baz:'wat'}).toBe true


  describe '#press', ->
    it 'has an instance method #press', ->
      expect( Sneaker.Press::press ).toBeDefined()
    it 'returns the result of calling the template function with the context as an argument', ->
      template = (context) -> "Template rendered with #{context.foo}"
      foo = new Sneaker.Press template
      expect( foo.with(foo:'bar').press() ).toBe 'Template rendered with bar'

  describe '#to_s', ->
    it 'is an alias for #press', ->
      expect( Sneaker.Press::to_s ).toBe Sneaker.Press::press

  describe '#to_jQuery', ->
    it 'has an instance method #to_jQuery', ->
      expect( Sneaker.Press::to_jQuery ).toBeDefined()
    it 'returns the pressing of the template wrapped in a jQuery object', ->
      foo = new Sneaker.Press -> '<div><span></span></div>'
      expect( foo.to_jQuery().html() ).toBe $('<div><span></span></div>').html()

  describe '#to_$', ->
    it 'is an alias for #to_jQuery', ->
      expect( Sneaker.Press::to_$ ).toBe Sneaker.Press::to_jQuery


  describe 'rendering and putting the result someplace', ->
    beforeEach ->
      @target = $('<div><i>i</i></div><div><i>i</i></div>').filter 'div'
      @simple_target = $ '<div class="press"><div></div><div></div></div>'

    describe '#top', ->
      it 'returns the Press object so as to be chainable, regardless of argument validity', ->
        foo = new Sneaker.Press
        expect( foo.top() ).toBe foo
      describe 'when given a jQuery', ->
        it 'prepends the pressed template result to the element(s) given', ->
          foo = new Sneaker.Press -> '<span>span!</span>'
          foo.top @target
          expect( $ @target[0].innerHTML ).toMatch $ '<span>span!</span><i>i</i>'
          expect( $ @target[1].innerHTML ).toMatch $ '<span>span!</span><i>i</i>'
      describe 'when given a string and the dom context is empty', ->
        it 'runs that as a selector against the document, and prepends to the result', ->
          foo = new Sneaker.Press -> '<span>span!</span>'
          foo.top @target
          expect( $ @target[0].innerHTML ).toMatch $ '<span>span!</span><i>i</i>'
          expect( $ @target[1].innerHTML ).toMatch $ '<span>span!</span><i>i</i>'
      describe 'when given a string that matches a dom context selector provided on instantiation', ->
        it 'prepends the pressed template to the context given', ->
          class View extends Sneaker.View
            @has_base -> '<div class="view"><div><i>i</i></div><div><i>i</i></div></div>'
            @has_hook div: 'div'
          view = new View
          foo = new Sneaker.Press (-> '<span>span!</span>'), view.dom
          foo.top 'div'
          expect( $ view.dom.base.html() ).toMatch $ '<div><span>span!</span><i>i</i></div><div><span>span!</span><i>i</i></div>'

    describe '#end', ->
      it 'returns the Press object so as to be chainable, regardless of argument validity', ->
        foo = new Sneaker.Press
        expect( foo.end() ).toBe foo
      describe 'when given a jQuery', ->
        it 'appends the pressed template result to the element(s) given', ->
          foo = new Sneaker.Press -> '<span>span!</span>'
          foo.end @target
          expect( $ @target[0].innerHTML ).toMatch $ '<i>i</i><span>span!</span>'
          expect( $ @target[1].innerHTML ).toMatch $ '<i>i</i><span>span!</span>'
      describe 'when given a string and the dom context is empty', ->
        it 'runs that as a selector against the document, and appends to the result', ->
          foo = new Sneaker.Press -> '<span>span!</span>'
          foo.end @target
          expect( $ @target[0].innerHTML ).toMatch $ '<i>i</i><span>span!</span>'
          expect( $ @target[1].innerHTML ).toMatch $ '<i>i</i><span>span!</span>'
      describe 'when given a string that matches a dom context selector provided on instantiation', ->
        it 'appends the pressed template to the context given', ->
          class View extends Sneaker.View
            @has_base -> '<div class="view"><div><i>i</i></div><div><i>i</i></div></div>'
            @has_hook div: 'div'
          view = new View
          foo = new Sneaker.Press (-> '<span>span!</span>'), view.dom
          foo.end 'div'
          expect( $ view.dom.base.html() ).toMatch $ '<div><i>i</i><span>span!</span></div><div><i>i</i><span>span!</span></div>'

    describe '#as', ->
      it 'returns the Press object so as to be chainable, regardless of argument validity', ->
        foo = new Sneaker.Press
        expect( foo.as() ).toBe foo
      describe 'when given a jQuery', ->
        it 'replaces the contents of the element(s) given with the pressed template', ->
          foo = new Sneaker.Press -> '<span>span!</span>'
          foo.as @target
          expect( $ @target[0].innerHTML ).toMatch $ '<span>span!</span>'
          expect( $ @target[1].innerHTML ).toMatch $ '<span>span!</span>'
      describe 'when given a string and the dom context is empty', ->
        it 'runs that as a selector against the document, and replaces the contents of the result', ->
          foo = new Sneaker.Press -> '<span>span!</span>'
          foo.as @target
          expect( $ @target[0].innerHTML ).toMatch $ '<span>span!</span>'
          expect( $ @target[1].innerHTML ).toMatch $ '<span>span!</span>'
      describe 'when given a string that matches a dom context selector provided on instantiation', ->
        it 'replaces the contents of the context given with the pressed template', ->
          class View extends Sneaker.View
            @has_base -> '<div class="view"><div><i>i</i></div><div><i>i</i></div></div>'
            @has_hook div: 'div'
          view = new View
          foo = new Sneaker.Press (-> '<span>span!</span>'), view.dom
          foo.as 'div'
          expect( $ view.dom.base.html() ).toMatch $ '<div><span>span!</span></div><div><span>span!</span></div>'

    describe '#before', ->
      it 'returns the Press object so as to be chainable, regardless of argument validity', ->
        foo = new Sneaker.Press
        expect( foo.before() ).toBe foo
      describe 'when given a jQuery', ->
        it 'inserts the result of the pressed template before the selected element(s)', ->
          $('.press').append '<div></div><div></div>'
          foo = new Sneaker.Press -> '<span>span!</span>'
          foo.before $('.press div')
          expect( $ $('.press').html() ).toMatch $ '<span>span!</span><div></div><span>span!</span><div></div>'
      describe 'when given a string and the dom context is empty', ->
        it 'inserts the result of the pressed template before the selected element(s)', ->
          $('.press').append '<div></div><div></div>'
          foo = new Sneaker.Press -> '<span>span!</span>'
          foo.before '.press div'
          expect( $ $('.press').html() ).toMatch $ '<span>span!</span><div></div><span>span!</span><div></div>'
      describe 'when given a string that matches a dom context selector provided on instantiation', ->
        it 'inserts the pressed template before each context given', ->
          class View extends Sneaker.View
            @has_base -> '<div class="view"><div></div><div></div></div>'
            @has_hook div: 'div'
          view = new View
          foo = new Sneaker.Press (-> '<span>span!</span>'), view.dom
          foo.before 'div'
          expect( $ view.dom.base.html() ).toMatch $ '<span>span!</span><div></div><span>span!</span><div></div>'

    describe '#after', ->
      it 'returns the Press object so as to be chainable, regardless of argument validity', ->
        foo = new Sneaker.Press
        expect( foo.after() ).toBe foo
      describe 'when given a jQuery', ->
        it 'inserts the result of the pressed template after the selected element(s)', ->
          target = @simple_target.find('div')
          foo = new Sneaker.Press -> '<span>span!</span>'
          foo.after target
          expect( $ @simple_target.html() ).toMatch $ '<div class="press"<div></div><span>span!</span><div></div><span>span!</span></div>'
      describe 'when given a string and the dom context is empty', ->
        it 'inserts the result of the pressed template before the selected element(s)', ->
          target = @simple_target.find('div')
          foo = new Sneaker.Press -> '<span>span!</span>'
          foo.after target
          expect( $ @simple_target.html() ).toMatch $ '<div class="press"><div></div><span>span!</span><div></div><span>span!</span></div>'
      describe 'when given a string that matches a dom context selector provided on instantiation', ->
        it 'inserts the pressed template after each context given', ->
          class View extends Sneaker.View
            @has_base -> '<div class="view"><div></div><div></div></div>'
            @has_hook div: 'div'
          view = new View
          foo = new Sneaker.Press (-> '<span>span!</span>'), view.dom
          foo.after 'div'
          expect( $ view.dom.base.html() ).toMatch $ '<div></div><span>span!</span><div></div><span>span!</span>'