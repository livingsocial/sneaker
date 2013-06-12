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