describe 'SneakerBox', ->
  it 'resides at Sneaker.Box on the global scope', ->
    expect( Sneaker.Box ).toBeDefined()

  it 'extends Sneaker.Core', ->
    expect( Sneaker.Box ).toExtend Sneaker.Core


  describe '.stack', ->
    it "is the array that the SneakerBox wraps", ->
      expect( (new Sneaker.Box).stack ).toBeDefined()


  describe '#constructor', ->
    it 'pushes each argument to the stack', ->
      a = new Sneaker.Box 1,2,3
      expect( a.stack ).toMatch [1,2,3]


  describe '#concat', ->
    beforeEach ->
      @box = new Sneaker.Box
      @box.push 2
      @result = @box.concat [3,4,5]
    it 'runs #concat against the stack', ->
      expect( @box.stack ).toEqual [2,3,4,5]
    it 'returns the box', ->
      expect( @result ).toBe @box

  describe '#dump', ->
    it "empties the stack", ->
      box = new Sneaker.Box
      box.add thing:true
      box.dump()
      expect( box.length() ).toBe 0
    it 'returns the box', ->
      box = new Sneaker.Box
      expect( box.dump() ).toBe box

  describe '#junk', ->
    it 'runs #quit on all members if present', ->
      x = 1
      class Foo extends Sneaker.Core
        @has_quit 'x', -> x = 2
      box = new Sneaker.Box (new Foo)
      box.junk()
      expect( x ).toBe 2
    it "empties the stack", ->
      box = new Sneaker.Box
      box.add thing:true
      box.junk()
      expect( box.length() ).toBe 0
    it 'returns the box', ->
      box = new Sneaker.Box
      expect( box.junk() ).toBe box


  describe '#every', ->
    if Array.prototype.every?
      it 'runs #every against the stack', ->
        box = new Sneaker.Box
        box.push 2,4,6
        expect( box.every((x) -> x % 2 is 0) ).toBe true
        box.dump().push 2,4,5
        expect( box.every((x) -> x % 2 is 0) ).toBe false
    else
      it 'returns undefined', ->
        box = new Sneaker.Box
        box.push 2,4,6
        expect( box.every((x) -> x % 2 is 0) ).toBe undefined

  describe '#filter', ->
    if Array.prototype.filter?
      describe 'returns a new box of the same class wrapping the items that meet the given filter', ->
        it 'returns a new box', ->
          class Crate extends Sneaker.Box
          c = new Crate
          expect( c.filter(-> true) instanceof Sneaker.Box ).toBe true
        it 'is a box of the same class', ->
          class Crate extends Sneaker.Box
          c = new Crate
          expect( c.filter(-> true) instanceof Crate ).toBe true
        it 'wraps the items that meet the filter', ->
          b = new Sneaker.Box
          b.push 2,4,6
          expect( b.filter((x)->x % 4 is 0).length() ).toBe 1
    else
      # repeated thrice to keep spec counts identical
      it 'returns undefined', -> expect( (new Sneaker.Box).filter(-> true) ).toBe undefined
      it 'returns undefined', -> expect( (new Sneaker.Box).filter(-> true) ).toBe undefined
      it 'returns undefined', -> expect( (new Sneaker.Box).filter(-> true) ).toBe undefined

  describe '#first', ->
    it 'returns the first element of the stack', ->
      b = new Sneaker.Box 0,1,2,3
      expect( b.first() ).toBe 0
    it 'returns undefined if the stack is empty', ->
      b = new Sneaker.Box
      expect( b.first() ).toBe undefined

  describe '#forEach', ->
    if Array.prototype.forEach?
      it 'runs #forEach against the stack', ->
        b = new Sneaker.Box
        sum = 0
        indices = 0
        array = undefined
        b.push(2,4,6).forEach((x, i, a) ->
          sum += x
          indices++
          array = a
        )
        expect( sum ).toBe 12
        expect( indices ).toBe 3
        expect( array ).toBe b.stack
      it 'returns the box', ->
        b = new Sneaker.Box
        expect( b.forEach(->) ).toBe b
    else
      # repeated twice to keep spec counts identical
      it 'returns undefined', -> expect( (new Sneaker.Box).forEach(->) ).toBe undefined
      it 'returns undefined', -> expect( (new Sneaker.Box).forEach(->) ).toBe undefined

  describe '#indexOf', ->
    if Array.prototype.indexOf?
      it 'runs #indexOf against the stack', ->
        expect( (new Sneaker.Box 2,4,6).indexOf(4) ).toBe 1
    else
      it 'returns undefined', ->
        expect( (new Sneaker.Box 2,4,6).indexOf(4) ).toBe undefined

  describe '#join', ->
    it 'runs #join against the stack', ->
      expect( (new Sneaker.Box 2,4,6).join('-') ).toBe '2-4-6'

  describe '#last', ->
    it 'returns the last element in the stack', ->
      b = new Sneaker.Box 0,1,2,3
      expect( b.last() ).toBe 3
    it 'returns undefined if the stack is empty', ->
      b = new Sneaker.Box
      expect( b.last() ).toBe undefined

  describe '#lastIndexOf', ->
    if Array.prototype.lastIndexOf?
      it 'runs #lastIndexOf against the stack', ->
        expect( (new Sneaker.Box 2,4,6,4).lastIndexOf(4) ).toBe 3
    else
      it 'returns undefined', ->
        expect( (new Sneaker.Box 2,4,6,4).lastIndexOf(4) ).toBe undefined

  describe '#length', ->
    it "returns the stack's length", ->
      box = new Sneaker.Box
      box.add thing:true
      expect( box.length() ).toBe 1

  describe '#map', ->
    if Array.prototype.map?
      describe 'returns a new box of the same type wrapping the results of the map', ->
        it 'returns a new box', ->
          class Crate extends Sneaker.Box
          c = new Crate
          expect( c.map((x)->x*2) instanceof Sneaker.Box ).toBe true
        it 'is a box of the same class', ->
          class Crate extends Sneaker.Box
          c = new Crate
          expect( c.map((x)->x*2) instanceof Crate ).toBe true
        it 'wraps the results of the map', ->
          b = new Sneaker.Box
          b.push 2,4,6
          expect( b.map((x)->x*2).stack ).toMatch [4,8,12]
    else
      # repeated thrice to keep spec counts identical
      it 'returns undefined', -> expect( (new Sneaker.Box).map(->) ).toBe undefined
      it 'returns undefined', -> expect( (new Sneaker.Box).map(->) ).toBe undefined
      it 'returns undefined', -> expect( (new Sneaker.Box).map(->) ).toBe undefined

  describe '#pop', ->
    it 'returns the last element in the stack', ->
      expect( (new Sneaker.Box 2,4,6).pop() ).toBe 6
    it 'removes the last element from the stack', ->
      b = (new Sneaker.Box 2,4,6)
      b.pop()
      expect( b.stack ).toMatch [2,4]

  describe '#push( thing )', ->
    it "adds a thing to the end of the box's stack", ->
      box = new Sneaker.Box
      box.push thing:true
      expect( box.stack[0] ).toEqual thing:true
    it 'returns the box', ->
      expect( (new Sneaker.Box).push(2,4,6) instanceof Sneaker.Box ).toBe true
    it 'has an alias #add', ->
      box = new Sneaker.Box
      box.add thing:true
      expect( box.stack[0] ).toEqual thing:true

  describe '#reduce', ->
    if Array.prototype.reduce?
      it 'reduces the stack with the callback and initial value given, and returns that', ->
        b = new Sneaker.Box
        b.push(0,1,2,3,4)
        expect( b.reduce (a,b) -> a+b ).toBe 10
    else
      it 'returns undefined', ->
        expect( (new Sneaker.Box).push(2,4,6).reduce(-> 8) ).toBe undefined

  describe '#reduceRight', ->
    if Array.prototype.reduceRight?
      it 'reduces the stack in reverse with the callback and initial value given, and returns that', ->
        b = new Sneaker.Box
        b.push(0,1,2,3,4)
        expect( b.reduceRight (a,b) -> a-b ).toBe -2
    else
      it 'returns undefined', ->
        expect( (new Sneaker.Box).push(2,4,6).reduceRight(-> 8) ).toBe undefined

  describe '#reverse', ->
    it 'reverses the stack', ->
      expect( (new Sneaker.Box).push(1,2,3,4).reverse().stack ).toMatch [4,3,2,1]
    it 'returns the box', ->
      b = new Sneaker.Box
      expect( b.push(1,2,3,4).reverse() ).toBe b

  describe '#shift', ->
    it 'returns the first element in the stack', ->
      expect( (new Sneaker.Box).push(2,4,6).shift() ).toBe 2
    it 'removes the first element from the stack', ->
      b = (new Sneaker.Box).push(2,4,6)
      b.shift()
      expect( b.stack ).toMatch [4,6]

  describe '#slice', ->
    it 'returns a new box of the same type', ->
      b = new Sneaker.Box
      b.push 0,1,2,3,4
      expect( b.slice(0,3) instanceof Sneaker.Box ).toBe true
      expect( b.slice(0,3) ).not.toBe b
    it 'wraps the result of the slice', ->
      b = new Sneaker.Box
      b.push 0,1,2,3,4
      expect( b.slice(0,3).stack ).toMatch [0,1,2]
    it 'works without an end parameter', ->
      b = new Sneaker.Box
      b.push 0,1,2,3,4
      expect( b.slice(2).stack ).toMatch [2,3,4]
    it 'works without a start parameter', ->
      b = new Sneaker.Box
      b.push 0,1,2,3,4
      expect( b.slice().stack ).toMatch [0,1,2,3,4]

  describe '#some', ->
    if Array.prototype.some?
      it 'runs #some against the stack', ->
        b = (new Sneaker.Box).push(7,8,9)
        expect(b.some( (x) -> x % 3 is 0 ) ).toBe true
        expect(b.some( (x) -> x % 5 is 0 ) ).toBe false
    else
      it 'returns undefined', -> expect( (new Sneaker.Box).some(-> true) ).toBe undefined

  describe '#sort', ->
    it 'runs #sort against the stack', ->
      b = new Sneaker.Box
      b.push 3,7,5,4,6
      expect( b.sort((a,b)->a-b).stack ).toMatch [3,4,5,6,7]
    it 'returns the box', ->
      b = new Sneaker.Box
      expect( b.sort() ).toBe b

  describe '#splice', ->
    it 'returns a new box', ->
      b = new Sneaker.Box
      expect( b.splice() ).not.toBe b
      expect( b.splice() instanceof Sneaker.Box ).toBe true
    it 'wraps the spliced out elements', ->
      a = new Sneaker.Box
      a.push 0,1,2,3
      b = a.splice 1,2
      expect( b instanceof Sneaker.Box ).toBe true
      expect( b.stack ).toMatch [1,2]
    it 'accepts an array of new elements to be spliced in', ->
      a = (new Sneaker.Box).push 0,1,2,3
      a.splice 1,2,['a','b']
      expect( a.stack ).toMatch [0,'a','b',3]
    it 'accepts a box of new elements to be spliced in', ->
      a = (new Sneaker.Box).push 0,1,2,3
      b = (new Sneaker.Box).push 'a','b'
      a.splice 1,2,b
      expect( a.stack ).toMatch [0,'a','b',3]

  describe '#unshift', ->
    it "adds a thing to the front of the box's stack", ->
      box = new Sneaker.Box
      box.push 1
      box.unshift 2
      expect( box.stack ).toMatch [2,1]
    it 'returns the box', ->
      expect( (new Sneaker.Box).unshift(2,4,6) instanceof Sneaker.Box ).toBe true


  describe '@runs( name )', ->
    it "adds a method to the prototype with the given name", ->
      class Foo extends Sneaker.Box
        @runs 'bar'
      expect( Foo::bar ).toBeDefined()

    it "allows for the calling of the same named method on everything in the stack, if each has it defined", ->
      class Box extends Sneaker.Box
        @runs 'bar'
      class Foo
        bar: ->
      box = new Box
      alpha = new Foo
      beta = new Foo
      box.push alpha
      box.push beta
      spyOn alpha, 'bar'
      spyOn beta, 'bar'
      box.bar()
      expect( alpha.bar ).toHaveBeenCalled()
      expect( beta.bar ).toHaveBeenCalled()

    it "calls the method on each with the arguments passed in", ->
      class Box extends Sneaker.Box
        @runs 'bar'
      class Foo
        bar: ->
      box = new Box
      foo = new Foo
      box.push foo
      spyOn foo, 'bar'
      box.bar wat:'okay'
      expect( foo.bar ).toHaveBeenCalledWith wat:'okay'


  describe '#handle( event )', ->
    it 'has #handle', ->
      expect((new Sneaker.Box).handle ).toBeDefined()
    it 'calls #handle with the given event on all the things inside, if defined', ->
      box = new Sneaker.Box
      class Foo extends Sneaker.Core
      class Bar
      foo = new Foo
      spyOn foo, 'handle'
      bar = new Bar
      box.add foo
      box.add bar
      box.handle 'baz'
      expect( foo.handle ).toHaveBeenCalledWith 'baz'