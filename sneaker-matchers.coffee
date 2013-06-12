###
Sneaker UI Library Jasmine Matchers
Version 0.8.1

Copyright 2013 LivingSocial, Inc.
Released under the MIT license
###
beforeEach ->

  toHandle = (expected) ->
    name = @actual.name
    handler = @actual::[Sneaker.convention.handlerName expected]
    nt = if @isNot then 'not handle' else 'handle'
    @message = -> "Expected #{name} to #{nt} events where action is `#{expected}`."
    handler?

  toHook = (namespace, selector) ->
    name = @actual.name
    hooks = @actual::[Sneaker.convention.hooksName()]
    nt = if @isNot then 'not have' else 'have'
    @message = -> "Expected #{name} to #{nt} hook `#{selector}` to `#{namespace}`."
    if selector?
      (Sneaker.ns.get hooks, namespace) is selector
    else
      (Sneaker.ns.get hooks, namespace)?


  toListenFor = (event, hookPath) ->
    name = @actual.name
    nt = if @isNot then 'not' else ''
    @message = -> "Expected #{name} to #{nt} listen for `#{event}` at `#{namespace}`"
    found = false
    for interaction in @actual::[Sneaker.convention.interactionsName()]
      if not found
        if interaction.hook is hookPath
          types = interaction.types.split(' ')
          if _.contains types, event
            found = true
    found

  toBox = (boxName, box = Sneaker.Box) ->
    nt = if @isNot then 'not have' else 'have'
    name = @actual.name
    @message = -> "Expected #{name} to #{nt} a box at #{name}"
    boxes = @actual::[Sneaker.convention.boxesName()]
    if boxes?
      boxes[boxName] is box and (new @actual)[boxName] instanceof box
    else false

  toTemplate = (expected) ->
    name = @actual.name
    template = @actual::[Sneaker.convention.templateName expected]
    nt = if @isNot then 'not have' else 'have'
    @message = -> "Expected #{name} to #{nt} a template named `#{expected}`"
    template?



  @addMatchers

    toHandle: toHandle
    toHaveHandler: toHandle

    toHook: toHook
    toHaveHook: toHook

    toListenFor: toListenFor
    toHaveListener: toListenFor

    toBox: toBox
    toHaveBox: toBox

    toTemplate: toTemplate
    toHaveTemplate: toTemplate


    toExtend: (cls) ->
      name = @actual.name
      nt = if @isNot then 'not extend' else 'extend'
      @message = -> "Expected #{name} to #{nt} #{cls.name}"
      (new @actual) instanceof cls

    toAlter: (valueFn) ->
      Sneaker.util.type @actual, 'function', '#toAlter needs a function as the expected'
      Sneaker.util.type valueFn, 'function', '#toAlter needs a function as the target'
      nt = if @isNot then 'not have' else 'have'
      @message = -> "Expected the object given to #{nt} changed."
      before = valueFn()
      @actual()
      not _.isEqual before, valueFn()

    toAlterContentsOf: (container) ->
      nt = if @isNot then 'not have' else 'have'
      @message = -> "Expected the contents of the element given to #{nt} changed."
      before = _.cloneDeep jQuery(container).html()
      @actual()
      after = _.cloneDeep jQuery(container).html()
      not _.isEqual before, after

    toHaveRequest: (phrase) ->
      name = @actual.name
      nt = if @isNot then 'not have' else 'have'
      @message = -> "Expected #{name} to #{nt} a request named #{phrase}."
      @actual::[Sneaker.convention.requestName phrase]?
