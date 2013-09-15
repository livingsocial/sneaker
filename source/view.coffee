Sneaker.View = class SneakerView extends Sneaker.Core

  @has_listener: (types, hook, fn) ->
    Sneaker.util.type types, 'string',
      '@has_listener expects the first argument to be a string of event types'
    Sneaker.util.type hook, 'string',
      '@has_listener expects the second argument to be a string, to later match against the hooks tree'
    Sneaker.util.type fn, 'function',
      '@has_listener expects the third argument to be a callback function'

    intrs = Sneaker.ref.interactionsName()
    @::[intrs] = if @::[intrs] then @::[intrs][..] else []

    @callbackIndex ||= 0
    callbackName = Sneaker.ref.interactionCallbackName @callbackIndex++

    @::[callbackName] = fn
    @::[intrs].push
      types: types
      hook: hook
      fn: callbackName

  @has_hook: (hooksHash) ->
    Sneaker.util.type hooksHash, 'object',
     '@has_hook expects to be passed a hash (with nested hashes) of name/selector pairs'
    hooks = Sneaker.ref.hooksName()
    @::[hooks] = jQuery.extend true, {}, @::[hooks], hooksHash

  @has_hooks: @has_hook

  @has_base: (templateFn) ->
    Sneaker.util.type templateFn, 'function',
      '@has_base expects to be passed a function'
    @::[Sneaker.ref.templateName 'base'] = templateFn

  @has_anchor: (selector) ->
    Sneaker.util.type name, 'string',
      '@has_anchor expects a string to run as a selector against the document'
    @::[Sneaker.ref.anchorName()] = selector

  @has_template: (name, fn) ->
    Sneaker.util.type name, 'string',
      '@has_template expects the first argument to be a string'
    Sneaker.util.type fn, 'function',
      '@has_template expects the second argument to be a function'
    @::[Sneaker.ref.templateName name] = fn

  #====================================#

  @has_init 'View: reference building', ->
    @__localDom = jQuery()
    @dom = {}

  @has_init 'View: anchoring', ->
    base = @render('base')
    anchor = @[Sneaker.ref.anchorName()]
    @dom.base = @__localDom = if base?
      base.to_jQuery()
    else if anchor?
      $(anchor).first()
    else
      jQuery()
    do @rehook

  @has_init 'View: handler delegation', ->
    if @dom.base? and @[Sneaker.ref.interactionsName()]
      for interaction in @[Sneaker.ref.interactionsName()]
        do (interaction) =>
          if interaction.hook is 'base'
            @dom.base.on interaction.types, (event) =>
              @[interaction.fn].call @, event
          else
            selector = Sneaker.ns.get @[Sneaker.ref.hooksName()], interaction.hook
            if selector?
              @dom.base.on interaction.types, selector, (event) =>
                @[interaction.fn].call @, event
            else Sneaker.util.throw(
              "Listener setup failed; `#{interaction.hook}` is an invalid hook path, double check it"
            )

  @has_quit 'View: remove DOM', ->
    if @[Sneaker.ref.anchorName()]? then do @dom.base.empty else do @remove

  @has_quit 'View: clear ref', ->
    delete @__localDom
    delete @dom

  #====================================#

  rehook: ->
    if @dom.base?
      tree = []
      recurse = (hooksObject) =>
        for name, selector of hooksObject
          do (name, selector) =>
            if Sneaker.util.type selector, 'object'
              tree.push name
              recurse selector
              tree.pop()
            else if Sneaker.util.type selector, 'string'
              branch = Sneaker.ns.create @dom, tree
              branch[name] = jQuery selector, @__localDom
      recurse @[Sneaker.ref.hooksName()]
    @dom

  render: (name) ->
    template = @[Sneaker.ref.templateName name]
    new Sneaker.Press( template, @dom ) if template?

  detach: ->
    @__localDom.detach()

  remove: ->
    @__localDom.remove()

  show:   ->
    @__localDom.show()

  hide:   ->
    @__localDom.hide()

  appendTo:   (container) ->
    @__moving 'appendTo', container

  prependTo:  (container) ->
    @__moving 'prependTo', container

  insertAfter:  (sibling) ->
    @__moving 'insertAfter', sibling

  insertBefore: (sibling) ->
    @__moving 'insertBefore', sibling

  #====================================#

  __moving: ( jQueryMethod, target ) ->
    if( ['appendTo', 'prependTo', 'insertAfter', 'insertBefore'].some (valid) -> ~jQueryMethod.indexOf valid )
      wrapped_target = if target? then jQuery(target).first() else []
      @__localDom[jQueryMethod](wrapped_target) if wrapped_target.length is 1
