Sneaker.Press = class SneakerPress extends Sneaker.Core

  constructor: (@templateFunction = (-> ''), @dom) ->
    Sneaker.util.type @templateFunction, 'function',
      'SneakerPress expects a function as its first argument'

    @context = {}

  with: (context = {}) ->
    Sneaker.util.type context, 'object', 'SneakerPress expects an object as context'
    @context = jQuery.extend {}, context
    this

  and: (additionalContext = {}) ->
    Sneaker.util.type additionalContext, 'object', 'SneakerPress expects an object as context'
    @context = jQuery.extend @context, additionalContext
    this

  press: -> @templateFunction @context
  to_s: @::press

  to_jQuery: -> jQuery @press()
  to_$: @::to_jQuery

  top:       (target) -> @__publish target, 'prepend'
  beginning: @::top
  end:       (target) -> @__publish target, 'append'
  bottom:    @::end
  as:        (target) -> @__publish target, 'as'
  into:      @::as
  before:    (target) -> @__publish target, 'before'
  front:     @::before
  ahead:     @::before
  after:     (target) -> @__publish target, 'after'
  back:      @::after
  behind:    @::after

  __publish: (target, method) ->
    if method is 'as'
      if target instanceof jQuery
        target.empty().append do @press
      else if jQuery.type(target) is 'string'
        if @dom?
          (Sneaker.ns.get @dom, target).empty().append do @press
        else
          jQuery(target).empty().append do @press
    else
      if target instanceof jQuery
        target[method] do @press
      else if jQuery.type(target) is 'string'
        if @dom?
          (Sneaker.ns.get @dom, target)[method] do @press
        else
          jQuery(target)[method] do @press
    this
