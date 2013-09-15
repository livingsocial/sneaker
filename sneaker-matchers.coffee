###
Sneaker UI Library Jasmine Matchers
Version 0.9.0

Copyright 2013 LivingSocial, Inc.
Released under the MIT license
###
beforeEach -> @addMatchers

  toHaveHandler: (expected) ->
    name = @actual.name
    handler = @actual::[Sneaker.ref.handlerName expected]
    nt = if @isNot then 'not handle' else 'handle'
    @message = -> "Expected #{name} to #{nt} events where action is `#{expected}`."
    handler?

  toHaveHook: (namespace, selector) ->
    name = @actual.name
    hooks = @actual::[Sneaker.ref.hooksName()]
    nt = if @isNot then 'not have' else 'have'
    @message = -> "Expected #{name} to #{nt} hook `#{selector}` to `#{namespace}`."
    if selector?
      (Sneaker.ns.get hooks, namespace) is selector
    else
      (Sneaker.ns.get hooks, namespace)?

  toHaveListener: (event, hookPath) ->
    name = @actual.name
    nt = if @isNot then 'not' else ''
    @message = -> "Expected #{name} to #{nt} listen for `#{event}` at `#{namespace}`"
    found = false
    for interaction in @actual::[Sneaker.ref.interactionsName()]
      if not found
        if interaction.hook is hookPath
          types = interaction.types.split(' ')
          if _.contains types, event
            found = true
    found

  toHaveTemplate: (expected) ->
    name = @actual.name
    template = @actual::[Sneaker.ref.templateName expected]
    nt = if @isNot then 'not have' else 'have'
    @message = -> "Expected #{name} to #{nt} a template named `#{expected}`"
    template?

  toHaveRequest: (phrase) ->
    name = @actual.name
    nt = if @isNot then 'not have' else 'have'
    @message = -> "Expected #{name} to #{nt} a request named #{phrase}."
    @actual::[Sneaker.ref.requestName phrase]?

  toExtend: (cls) ->
    name = @actual.name
    nt = if @isNot then 'not extend' else 'extend'
    @message = -> "Expected #{name} to #{nt} #{cls.name}"
    (new @actual) instanceof cls

  toAlter: (valueFn) ->
    Sneaker.util.type _, 'function', '#toAlter matcher needs underscore.js or lodash.js to work'
    Sneaker.util.type @actual, 'function', '#toAlter needs a function as the expected'
    Sneaker.util.type valueFn, 'function', '#toAlter needs a function as the target'
    nt = if @isNot then 'not have' else 'have'
    @message = -> "Expected the object given to #{nt} changed."
    before = valueFn()
    @actual()
    not _.isEqual before, valueFn()

  toAlterContentsOf: (container) ->
    Sneaker.util.type _, 'function', '#toAlter matcher needs underscore.js or lodash.js to work'
    nt = if @isNot then 'not have' else 'have'
    @message = -> "Expected the contents of the element given to #{nt} changed."
    before = _.cloneDeep jQuery(container).html()
    @actual()
    after = _.cloneDeep jQuery(container).html()
    not _.isEqual before, after
