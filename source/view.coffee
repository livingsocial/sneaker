class SneakerView extends Sneaker.Core

  @has_listener: (types, hook, fn) ->
    Sneaker.util.type types, 'string',
      '@has_listener expects the first argument to be a string of event types'
    Sneaker.util.type hook, 'string',
      '@has_listener expects the second argument to be a string, to later match against the hooks tree'
    Sneaker.util.type fn, 'function',
      '@has_listener expects the third argument to be a callback function'

    intrs = Sneaker.convention.interactionsName()
    @::[intrs] = if @::[intrs] then @::[intrs][..] else []

    @intrs_cb_index ||= 0
    callbackName = Sneaker.convention.interactionCallbackName @intrs_cb_index
    @intrs_cb_index++

    @::[callbackName] = fn
    @::[intrs].push
      types: types
      hook: hook
      fn: callbackName
    return
  @listens_for: @has_listener

  @has_hook: (hooksHash) ->
    Sneaker.util.type hooksHash, 'object',
     '@has_hook expects to be passed a hash of name/selector pairs'

    @::[Sneaker.convention.hooksName()] = jQuery.extend( true,
      {}, @::[Sneaker.convention.hooksName()], hooksHash
    )
    return
  @has_hooks: @has_hook

  @has_box: (name, box = Sneaker.Box) ->
    Sneaker.util.type name, 'string',
      '@has_box expects to be passed a string for the box name'
    if not ((new box) instanceof Sneaker.Box)
      Sneaker.util.throw '@has_box expects the second argument to be a descendent of Sneaker.Box'
      
    boxes = Sneaker.convention.boxesName()
    @::[boxes] = jQuery.extend true, {}, @::[boxes]
    @::[boxes][name] = box
    return

  @has_base: (templateFn) ->
    Sneaker.util.type templateFn, 'function',
      '@has_base expects to be passed a function'
    @::[Sneaker.convention.templateName 'base'] = templateFn
    return

  @has_anchor: (selector) ->
    Sneaker.util.type name, 'string',
      '@has_anchor expects a string to run as a selector against the document'
    @::[Sneaker.convention.anchorName()] = selector

  @has_template: (name, fn) ->
    Sneaker.util.type name, 'string',
      '@has_template expects the first argument to be a string'
    Sneaker.util.type fn, 'function',
      '@has_template expects the second argument to be a function'

    @::[Sneaker.convention.templateName name] = fn
    return

  #====================================#

  @has_init 'View: reference building', ->
    @ref =
      localDom: jQuery()
      dom: {}
    @dom = @ref.dom
    if @[Sneaker.convention.boxesName()]
      @ref.boxes = {}
      for name, box of @[Sneaker.convention.boxesName()]
        @ref.boxes[name] = new box
        @[name] = @ref.boxes[name]

  @has_init 'View: anchoring', ->
    base = @render('base')
    anchor = @[Sneaker.convention.anchorName()]
    @dom.base = @ref.localDom = if base?
      base.to_jQuery()
    else if anchor?
      $(anchor)
    else
      jQuery()
    do @rehook

  @has_init 'View: handler delegation', ->
    if @dom.base? and @[Sneaker.convention.interactionsName()]
      for interaction in @[Sneaker.convention.interactionsName()]
        do (interaction) =>
          if interaction.hook is 'base'
            @dom.base.on interaction.types, (event) =>
              @[interaction.fn].call @, event
          else
            selector = Sneaker.ns.get @[Sneaker.convention.hooksName()], interaction.hook
            if selector?
              @dom.base.on interaction.types, selector, (event) =>
                @[interaction.fn].call @, event
            else Sneaker.util.throw(
              "Listener setup failed; `#{interaction.hook}` is an invalid hook path, double check it"
            )

  @has_quit 'View: remove DOM', -> do @remove

  @has_quit 'View: clear ref', ->
    delete @ref.localDom
    delete @ref.dom
    delete @ref.boxes

  #====================================#

  rehook: ->
    if @dom.base?
      tree = []
      ref = @ref
      recurse = (hooksObject) ->
        for name, selector of hooksObject
          do (name, selector) ->
            if Sneaker.util.type selector, 'object'
              tree.push name
              recurse selector
              tree.pop()
              return
            else if Sneaker.util.type selector, 'string'
              branch = Sneaker.ns.create ref.dom, tree
              branch[name] = jQuery selector, ref.localDom
              return
        return
      recurse @[Sneaker.convention.hooksName()]
      return
    return

  render: (name) ->
    template = @[Sneaker.convention.templateName name]
    return new Sneaker.Press( template, @ref.dom ) if template?
    return

  appendTo:   (container) -> @moving 'appendTo', container
  prependTo:  (container) -> @moving 'prependTo', container
  insertAfter:  (sibling) -> @moving 'insertAfter', sibling
  insertBefore: (sibling) -> @moving 'insertBefore', sibling

  moving: ( jQueryMethod, target ) ->
    switch jQueryMethod
      when 'appendTo', 'prependTo', 'insertAfter', 'insertBefore'
        wrapped_target = if target? then jQuery(target).first() else []
        @ref.localDom[jQueryMethod](wrapped_target) if wrapped_target.length is 1

  detach: -> @ref.localDom.detach()
  remove: -> @ref.localDom.remove()
  show:   -> @ref.localDom.show()
  hide:   -> @ref.localDom.hide()

Sneaker.ns.set this, 'Sneaker.View', SneakerView