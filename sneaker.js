/*
Sneaker UI Library
Version 0.8.1

Copyright 2013 LivingSocial, Inc.
Released under the MIT license
*/


(function() {
  
if (!Array.prototype.indexOf) {
    Array.prototype.indexOf = function (searchElement) {
        "use strict";
        if (this == null) {
            throw new TypeError();
        }
        var t = Object(this);
        var len = t.length >>> 0;
        if (len === 0) {
            return -1;
        }
        var n = 0;
        if (arguments.length > 1) {
            n = Number(arguments[1]);
            if (n != n) {
                n = 0;
            } else if (n != 0 && n != Infinity && n != -Infinity) {
                n = (n > 0 || -1) * Math.floor(Math.abs(n));
            }
        }
        if (n >= len) {
            return -1;
        }
        var k = n >= 0 ? n : Math.max(len - Math.abs(n), 0);
        for (; k < len; k++) {
            if (k in t && t[k] === searchElement) {
                return k;
            }
        }
        return -1;
    }
}
;

  var SneakerApi, SneakerApiMock, SneakerBox, SneakerCore, SneakerPress, SneakerView,
    __slice = [].slice,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  this.Sneaker || (this.Sneaker = {});

  this.Sneaker.convention = {
    anchorName: function() {
      return "__anchor";
    },
    boxesName: function() {
      return "__boxes";
    },
    handlerName: function(name) {
      return "__handle_" + name;
    },
    hooksName: function() {
      return "__hooks";
    },
    initName: function(name) {
      return "__init_" + name;
    },
    initsName: function() {
      return "__inits";
    },
    initsOrderName: function() {
      return "__inits_order";
    },
    initsSkipName: function() {
      return "__inits_skip";
    },
    interactionCallbackName: function(index) {
      return "__interaction_cb_" + index;
    },
    interactionsName: function() {
      return "__interactions";
    },
    quitName: function(name) {
      return "__quit_" + name;
    },
    quitsName: function() {
      return "__quits";
    },
    quitsOrderName: function() {
      return "__quits_order";
    },
    quitsSkipName: function() {
      return "__quits_skip";
    },
    requestDefaultsName: function() {
      return "__requestDefaults";
    },
    requestName: function(name) {
      return "__request_" + name;
    },
    responsesName: function() {
      return "__responses";
    },
    responseName: function(name) {
      return "__response_" + name;
    },
    templateName: function(name) {
      return "__template_" + name;
    }
  };

  this.Sneaker.util = {
    type: function(thing, type, error) {
      if (type !== jQuery.type(thing)) {
        Sneaker.util["throw"](error);
        return false;
      } else {
        return true;
      }
    },
    uniq: function(array) {
      var key, output, value, _i, _ref, _results;
      output = {};
      for (key = _i = 0, _ref = array.length; 0 <= _ref ? _i < _ref : _i > _ref; key = 0 <= _ref ? ++_i : --_i) {
        output[array[key]] = array[key];
      }
      _results = [];
      for (key in output) {
        value = output[key];
        _results.push(value);
      }
      return _results;
    },
    "throw": function(message) {
      if (message != null) {
        throw "Sneaker: " + message + ", please";
      }
    },
    install: function(module, target) {
      var key, method, _ref;
      for (key in module) {
        method = module[key];
        if (module.hasOwnProperty(key) && key !== 'has_module_setup') {
          target[key] = module[key];
        }
      }
      _ref = module.prototype;
      for (key in _ref) {
        method = _ref[key];
        if (module.prototype.hasOwnProperty(key)) {
          target.prototype[key] = module.prototype[key];
        }
      }
      if (module.has_module_setup != null) {
        Sneaker.util.type(module.has_module_setup, 'function', 'If @has_module_setup is defined on a module to be installed, it must be a function');
        return module.has_module_setup.apply(target);
      }
    }
  };

  this.Sneaker.ns = {
    get: function(object, path) {
      var obj, t, tokens;
      tokens = Sneaker.ns.tokens(path);
      obj = object;
      while (tokens.length > 0) {
        t = tokens.shift();
        if (obj != null) {
          obj = obj[t];
        }
      }
      return obj;
    },
    create: function(object, path) {
      var token, tokens;
      tokens = Sneaker.ns.tokens(path);
      while (tokens.length > 0 && (object != null) && Sneaker.util.type(object, 'object')) {
        token = tokens.shift();
        if (token.length > 0) {
          object[token] || (object[token] = {});
          object = object[token];
        }
      }
      return object;
    },
    set: function(object, path, value) {
      var tokens;
      tokens = Sneaker.ns.tokens(path);
      return Sneaker.ns.create(object, tokens.slice(0, -1))[tokens.slice(-1)] = value;
    },
    tokens: function(path) {
      switch (jQuery.type(path)) {
        case 'string':
          return path.split(/\.|\//);
        case 'array':
          return path.slice(0);
        default:
          return [];
      }
    }
  };

  SneakerCore = (function() {
    var has_bookend, has_bookend_order, run_bookends, runs_bookend, skips_bookend;

    function SneakerCore() {
      this.init.apply(this, arguments);
    }

    SneakerCore.has_handler = function(phrase, fn) {
      Sneaker.util.type(phrase, 'string', '@has_handler expects the first argument to be a string');
      Sneaker.util.type(fn, 'function', '@has_handler expects the second argument to be a function');
      this.prototype[Sneaker.convention.handlerName(phrase)] = fn;
    };

    SneakerCore.prototype.handle = function(phrase, eventAttributes) {
      var handler;
      if (Sneaker.util.type(phrase, 'string')) {
        handler = this[Sneaker.convention.handlerName(phrase)];
        if (handler != null) {
          return handler.call(this, eventAttributes);
        }
      }
    };

    has_bookend = function(end, name, callback_pack) {
      var callback, collection, indicies;
      switch (end) {
        case 'init':
        case 'quit':
          if (callback_pack.length === 1) {
            callback = callback_pack[0];
            indicies = [];
          } else {
            callback = callback_pack[1];
            indicies = callback_pack[0];
          }
          Sneaker.util.type(indicies, 'array', "@has_" + end + " expects provided indicies to be an array");
          Sneaker.util.type(callback, 'function', "@has_" + end + " expects the callback to be a function");
          this.prototype[Sneaker.convention["" + end + "Name"](name)] = [callback, indicies];
          collection = Sneaker.convention["" + end + "sName"]();
          this.prototype[collection] = this.prototype[collection] ? this.prototype[collection].slice(0) : [];
          this.prototype[collection].push(name);
          this.prototype[collection] = Sneaker.util.uniq(this.prototype[collection]);
      }
    };

    has_bookend_order = function(end, order) {
      switch (end) {
        case 'init':
        case 'quit':
          Sneaker.util.type(order, 'array', "@has_" + end + "_order expects an array");
          this.prototype[Sneaker.convention["" + end + "sOrderName"]()] = order;
      }
    };

    skips_bookend = function(end, name) {
      var skip;
      switch (end) {
        case 'init':
        case 'quit':
          skip = Sneaker.convention["" + end + "sSkipName"]();
          this.prototype[skip] = this.prototype[skip] ? this.prototype[skip].slice(0) : [];
          this.prototype[skip].push(name);
      }
    };

    runs_bookend = function(end, name) {
      var index, skip;
      switch (end) {
        case 'init':
        case 'quit':
          skip = Sneaker.convention["" + end + "sSkipName"]();
          this.prototype[skip] = this.prototype[skip] ? this.prototype[skip].slice(0) : [];
          index = this.prototype[skip].indexOf(name);
          if (index >= 0) {
            this.prototype[skip].splice(index, 1);
          }
      }
    };

    SneakerCore.has_init = function() {
      var callback_pack, name;
      name = arguments[0], callback_pack = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return has_bookend.call(this, 'init', name, callback_pack);
    };

    SneakerCore.has_init_order = function(order) {
      return has_bookend_order.call(this, 'init', order);
    };

    SneakerCore.skips_init = function(name) {
      return skips_bookend.call(this, 'init', name);
    };

    SneakerCore.runs_init = function(name) {
      return runs_bookend.call(this, 'init', name);
    };

    SneakerCore.has_quit = function() {
      var callback_pack, name;
      name = arguments[0], callback_pack = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      return has_bookend.call(this, 'quit', name, callback_pack);
    };

    SneakerCore.has_quit_order = function(order) {
      return has_bookend_order.call(this, 'quit', order);
    };

    SneakerCore.skips_quit = function(name) {
      return skips_bookend.call(this, 'quit', name);
    };

    SneakerCore.runs_quit = function(name) {
      return runs_bookend.call(this, 'quit', name);
    };

    run_bookends = function(end, args) {
      var already_ran, bookend, ordered, run_an_bookend, skip, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2;
      run_an_bookend = function(name, original_arguments) {
        var index, indicies;
        if (this[Sneaker.convention["" + end + "Name"](name)] != null) {
          indicies = this[Sneaker.convention["" + end + "Name"](name)][1];
          if ((indicies != null ? indicies.length : void 0) > 0) {
            args = (function() {
              var _i, _len, _results;
              _results = [];
              for (_i = 0, _len = indicies.length; _i < _len; _i++) {
                index = indicies[_i];
                _results.push(original_arguments[index]);
              }
              return _results;
            })();
          } else {
            args = original_arguments;
          }
          return this[Sneaker.convention["" + end + "Name"](name)][0].apply(this, args);
        }
      };
      switch (end) {
        case 'init':
        case 'quit':
          already_ran = [];
          _ref = this[Sneaker.convention["" + end + "sSkipName"]()] || [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            skip = _ref[_i];
            already_ran.push(skip);
          }
          _ref1 = this[Sneaker.convention["" + end + "sOrderName"]()] || [];
          for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
            ordered = _ref1[_j];
            if (!(already_ran.indexOf(ordered) >= 0)) {
              run_an_bookend.call(this, ordered, args);
            }
            already_ran.push(ordered);
          }
          _ref2 = this[Sneaker.convention["" + end + "sName"]()] || [];
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            bookend = _ref2[_k];
            if (!(already_ran.indexOf(bookend) >= 0)) {
              run_an_bookend.call(this, bookend, args);
            }
          }
      }
    };

    SneakerCore.prototype.init = function() {
      return run_bookends.call(this, 'init', arguments);
    };

    SneakerCore.prototype.quit = function() {
      return run_bookends.call(this, 'quit', arguments);
    };

    return SneakerCore;

  })();

  Sneaker.ns.set(this, 'Sneaker.Core', SneakerCore);

  SneakerView = (function(_super) {

    __extends(SneakerView, _super);

    function SneakerView() {
      return SneakerView.__super__.constructor.apply(this, arguments);
    }

    SneakerView.has_listener = function(types, hook, fn) {
      var callbackName, intrs;
      Sneaker.util.type(types, 'string', '@has_listener expects the first argument to be a string of event types');
      Sneaker.util.type(hook, 'string', '@has_listener expects the second argument to be a string, to later match against the hooks tree');
      Sneaker.util.type(fn, 'function', '@has_listener expects the third argument to be a callback function');
      intrs = Sneaker.convention.interactionsName();
      this.prototype[intrs] = this.prototype[intrs] ? this.prototype[intrs].slice(0) : [];
      this.intrs_cb_index || (this.intrs_cb_index = 0);
      callbackName = Sneaker.convention.interactionCallbackName(this.intrs_cb_index);
      this.intrs_cb_index++;
      this.prototype[callbackName] = fn;
      this.prototype[intrs].push({
        types: types,
        hook: hook,
        fn: callbackName
      });
    };

    SneakerView.listens_for = SneakerView.has_listener;

    SneakerView.has_hook = function(hooksHash) {
      Sneaker.util.type(hooksHash, 'object', '@has_hook expects to be passed a hash of name/selector pairs');
      this.prototype[Sneaker.convention.hooksName()] = jQuery.extend(true, {}, this.prototype[Sneaker.convention.hooksName()], hooksHash);
    };

    SneakerView.has_hooks = SneakerView.has_hook;

    SneakerView.has_box = function(name, box) {
      var boxes;
      if (box == null) {
        box = Sneaker.Box;
      }
      Sneaker.util.type(name, 'string', '@has_box expects to be passed a string for the box name');
      if (!((new box) instanceof Sneaker.Box)) {
        Sneaker.util["throw"]('@has_box expects the second argument to be a descendent of Sneaker.Box');
      }
      boxes = Sneaker.convention.boxesName();
      this.prototype[boxes] = jQuery.extend(true, {}, this.prototype[boxes]);
      this.prototype[boxes][name] = box;
    };

    SneakerView.has_base = function(templateFn) {
      Sneaker.util.type(templateFn, 'function', '@has_base expects to be passed a function');
      this.prototype[Sneaker.convention.templateName('base')] = templateFn;
    };

    SneakerView.has_anchor = function(selector) {
      Sneaker.util.type(name, 'string', '@has_anchor expects a string to run as a selector against the document');
      return this.prototype[Sneaker.convention.anchorName()] = selector;
    };

    SneakerView.has_template = function(name, fn) {
      Sneaker.util.type(name, 'string', '@has_template expects the first argument to be a string');
      Sneaker.util.type(fn, 'function', '@has_template expects the second argument to be a function');
      this.prototype[Sneaker.convention.templateName(name)] = fn;
    };

    SneakerView.has_init('View: reference building', function() {
      var box, name, _ref, _results;
      this.ref = {
        localDom: jQuery(),
        dom: {}
      };
      this.dom = this.ref.dom;
      if (this[Sneaker.convention.boxesName()]) {
        this.ref.boxes = {};
        _ref = this[Sneaker.convention.boxesName()];
        _results = [];
        for (name in _ref) {
          box = _ref[name];
          this.ref.boxes[name] = new box;
          _results.push(this[name] = this.ref.boxes[name]);
        }
        return _results;
      }
    });

    SneakerView.has_init('View: anchoring', function() {
      var anchor, base;
      base = this.render('base');
      anchor = this[Sneaker.convention.anchorName()];
      this.dom.base = this.ref.localDom = base != null ? base.to_jQuery() : anchor != null ? $(anchor) : jQuery();
      return this.rehook();
    });

    SneakerView.has_init('View: handler delegation', function() {
      var interaction, _i, _len, _ref, _results,
        _this = this;
      if ((this.dom.base != null) && this[Sneaker.convention.interactionsName()]) {
        _ref = this[Sneaker.convention.interactionsName()];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          interaction = _ref[_i];
          _results.push((function(interaction) {
            var selector;
            if (interaction.hook === 'base') {
              return _this.dom.base.on(interaction.types, function(event) {
                return _this[interaction.fn].call(_this, event);
              });
            } else {
              selector = Sneaker.ns.get(_this[Sneaker.convention.hooksName()], interaction.hook);
              if (selector != null) {
                return _this.dom.base.on(interaction.types, selector, function(event) {
                  return _this[interaction.fn].call(_this, event);
                });
              } else {
                return Sneaker.util["throw"]("Listener setup failed; `" + interaction.hook + "` is an invalid hook path, double check it");
              }
            }
          })(interaction));
        }
        return _results;
      }
    });

    SneakerView.has_quit('View: remove DOM', function() {
      return this.remove();
    });

    SneakerView.has_quit('View: clear ref', function() {
      delete this.ref.localDom;
      delete this.ref.dom;
      return delete this.ref.boxes;
    });

    SneakerView.prototype.rehook = function() {
      var recurse, ref, tree;
      if (this.dom.base != null) {
        tree = [];
        ref = this.ref;
        recurse = function(hooksObject) {
          var name, selector, _fn;
          _fn = function(name, selector) {
            var branch;
            if (Sneaker.util.type(selector, 'object')) {
              tree.push(name);
              recurse(selector);
              tree.pop();
            } else if (Sneaker.util.type(selector, 'string')) {
              branch = Sneaker.ns.create(ref.dom, tree);
              branch[name] = jQuery(selector, ref.localDom);
            }
          };
          for (name in hooksObject) {
            selector = hooksObject[name];
            _fn(name, selector);
          }
        };
        recurse(this[Sneaker.convention.hooksName()]);
        return;
      }
    };

    SneakerView.prototype.render = function(name) {
      var template;
      template = this[Sneaker.convention.templateName(name)];
      if (template != null) {
        return new Sneaker.Press(template, this.ref.dom);
      }
    };

    SneakerView.prototype.appendTo = function(container) {
      return this.moving('appendTo', container);
    };

    SneakerView.prototype.prependTo = function(container) {
      return this.moving('prependTo', container);
    };

    SneakerView.prototype.insertAfter = function(sibling) {
      return this.moving('insertAfter', sibling);
    };

    SneakerView.prototype.insertBefore = function(sibling) {
      return this.moving('insertBefore', sibling);
    };

    SneakerView.prototype.moving = function(jQueryMethod, target) {
      var wrapped_target;
      switch (jQueryMethod) {
        case 'appendTo':
        case 'prependTo':
        case 'insertAfter':
        case 'insertBefore':
          wrapped_target = target != null ? jQuery(target).first() : [];
          if (wrapped_target.length === 1) {
            return this.ref.localDom[jQueryMethod](wrapped_target);
          }
      }
    };

    SneakerView.prototype.detach = function() {
      return this.ref.localDom.detach();
    };

    SneakerView.prototype.remove = function() {
      return this.ref.localDom.remove();
    };

    SneakerView.prototype.show = function() {
      return this.ref.localDom.show();
    };

    SneakerView.prototype.hide = function() {
      return this.ref.localDom.hide();
    };

    return SneakerView;

  })(Sneaker.Core);

  Sneaker.ns.set(this, 'Sneaker.View', SneakerView);

  SneakerPress = (function() {

    function SneakerPress(templateFunction, dom) {
      this.templateFunction = templateFunction != null ? templateFunction : (function() {
        return '';
      });
      this.dom = dom;
      Sneaker.util.type(this.templateFunction, 'function', 'SneakerPress expects a function as its first argument');
      this.context = {};
    }

    SneakerPress.prototype["with"] = function(context) {
      if (context == null) {
        context = {};
      }
      Sneaker.util.type(context, 'object', 'SneakerPress expects an object as context');
      this.context = jQuery.extend({}, context);
      return this;
    };

    SneakerPress.prototype.and = function(additionalContext) {
      if (additionalContext == null) {
        additionalContext = {};
      }
      Sneaker.util.type(additionalContext, 'object', 'SneakerPress expects an object as context');
      this.context = jQuery.extend(this.context, additionalContext);
      return this;
    };

    SneakerPress.prototype.press = function() {
      return this.templateFunction(this.context);
    };

    SneakerPress.prototype.to_s = SneakerPress.prototype.press;

    SneakerPress.prototype.to_jQuery = function() {
      return jQuery(this.press());
    };

    SneakerPress.prototype.to_$ = SneakerPress.prototype.to_jQuery;

    SneakerPress.prototype.top = function(target) {
      return this.__publish(target, 'prepend');
    };

    SneakerPress.prototype.beginning = SneakerPress.prototype.top;

    SneakerPress.prototype.end = function(target) {
      return this.__publish(target, 'append');
    };

    SneakerPress.prototype.bottom = SneakerPress.prototype.end;

    SneakerPress.prototype.as = function(target) {
      return this.__publish(target, 'as');
    };

    SneakerPress.prototype.into = SneakerPress.prototype.as;

    SneakerPress.prototype.before = function(target) {
      return this.__publish(target, 'before');
    };

    SneakerPress.prototype.front = SneakerPress.prototype.before;

    SneakerPress.prototype.ahead = SneakerPress.prototype.before;

    SneakerPress.prototype.after = function(target) {
      return this.__publish(target, 'after');
    };

    SneakerPress.prototype.back = SneakerPress.prototype.after;

    SneakerPress.prototype.behind = SneakerPress.prototype.after;

    SneakerPress.prototype.__publish = function(target, method) {
      if (method === 'as') {
        if (target instanceof jQuery) {
          target.empty().append(this.press());
        } else if (jQuery.type(target) === 'string') {
          if (this.dom != null) {
            (Sneaker.ns.get(this.dom, target)).empty().append(this.press());
          } else {
            jQuery(target).empty().append(this.press());
          }
        }
      } else {
        if (target instanceof jQuery) {
          target[method](this.press());
        } else if (jQuery.type(target) === 'string') {
          if (this.dom != null) {
            (Sneaker.ns.get(this.dom, target))[method](this.press());
          } else {
            jQuery(target)[method](this.press());
          }
        }
      }
      return this;
    };

    return SneakerPress;

  })();

  Sneaker.ns.set(this, 'Sneaker.Press', SneakerPress);

  SneakerBox = (function(_super) {

    __extends(SneakerBox, _super);

    function SneakerBox() {
      var arg, _i, _len;
      this.dump();
      for (_i = 0, _len = arguments.length; _i < _len; _i++) {
        arg = arguments[_i];
        this.stack.push(arg);
      }
    }

    SneakerBox.prototype.dump = function() {
      this.stack = [];
      return this;
    };

    SneakerBox.prototype.junk = function() {
      var member, _i, _len, _ref;
      if (this.stack != null) {
        _ref = this.stack;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          member = _ref[_i];
          if (member instanceof Sneaker.Core && jQuery.type(member.quit) === 'function') {
            member.quit();
          }
        }
      }
      return this.dump();
    };

    SneakerBox.prototype.concat = function() {
      this.stack = this.stack.concat.apply(this.stack, arguments);
      return this;
    };

    SneakerBox.prototype.every = function(callback, localThis) {
      if (Array.prototype.every != null) {
        return this.stack.every(callback, localThis);
      }
    };

    SneakerBox.prototype.filter = function(callback, localThis) {
      if (Array.prototype.filter != null) {
        return (new this.constructor).concat(this.stack.filter(callback, localThis));
      }
    };

    SneakerBox.prototype.first = function() {
      return this.stack[0];
    };

    SneakerBox.prototype.forEach = function(callback, localThis) {
      if (Array.prototype.forEach != null) {
        this.stack.forEach(callback, localThis);
        return this;
      }
    };

    SneakerBox.prototype.indexOf = function(searchFor, fromIndex) {
      if (Array.prototype.indexOf != null) {
        return this.stack.indexOf(searchFor, fromIndex);
      }
    };

    SneakerBox.prototype.join = function(separator) {
      return this.stack.join(separator);
    };

    SneakerBox.prototype.last = function() {
      return this.stack[this.stack.length - 1];
    };

    SneakerBox.prototype.lastIndexOf = function(searchFor, fromIndex) {
      if (Array.prototype.lastIndexOf != null) {
        return this.stack.lastIndexOf(searchFor, fromIndex || (this.stack.length - 1));
      }
    };

    SneakerBox.prototype.length = function() {
      return this.stack.length;
    };

    SneakerBox.prototype.map = function(callback, localThis) {
      if (Array.prototype.map != null) {
        return (new this.constructor).concat(this.stack.map(callback, localThis));
      }
    };

    SneakerBox.prototype.pop = function() {
      return this.stack.pop();
    };

    SneakerBox.prototype.push = function() {
      this.stack.push.apply(this.stack, arguments);
      return this;
    };

    SneakerBox.prototype.reduce = function(callback, initialValue) {
      if (Array.prototype.reduce != null) {
        if (initialValue != null) {
          return this.stack.reduce(callback, initialValue);
        } else {
          return this.stack.reduce(callback);
        }
      }
    };

    SneakerBox.prototype.reduceRight = function(callback, initialValue) {
      if (Array.prototype.reduce != null) {
        if (initialValue != null) {
          return this.stack.reduceRight(callback, initialValue);
        } else {
          return this.stack.reduceRight(callback);
        }
      }
    };

    SneakerBox.prototype.reverse = function() {
      this.stack.reverse();
      return this;
    };

    SneakerBox.prototype.shift = function() {
      return this.stack.shift();
    };

    SneakerBox.prototype.slice = function(start, end) {
      if (end != null) {
        return (new this.constructor).concat(this.stack.slice(start, end));
      } else {
        return (new this.constructor).concat(this.stack.slice(start));
      }
    };

    SneakerBox.prototype.some = function(callback, localThis) {
      if (Array.prototype.some != null) {
        return this.stack.some(callback, localThis);
      }
    };

    SneakerBox.prototype.sort = function(fn) {
      this.stack.sort(fn);
      return this;
    };

    SneakerBox.prototype.splice = function(index, howMany, insertionArray) {
      var applyWith, insert;
      if (howMany == null) {
        howMany = 0;
      }
      if (insertionArray instanceof Sneaker.Box) {
        insert = insertionArray.stack;
      } else if ($.type(insertionArray) === 'array') {
        insert = insertionArray;
      } else {
        insert = [];
      }
      applyWith = [index, howMany].concat(insert);
      return (new this.constructor).concat(this.stack.splice.apply(this.stack, applyWith));
    };

    SneakerBox.prototype.unshift = function() {
      this.stack.unshift.apply(this.stack, arguments);
      return this;
    };

    SneakerBox.prototype.add = function() {
      return this.push.apply(this, arguments);
    };

    SneakerBox.runs = function(name) {
      return this.prototype[name] = function() {
        var thing, _i, _len, _ref, _results;
        _ref = this.stack;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          thing = _ref[_i];
          if (thing[name] != null) {
            _results.push(thing[name].apply(thing, arguments));
          } else {
            _results.push(void 0);
          }
        }
        return _results;
      };
    };

    SneakerBox.runs('handle');

    return SneakerBox;

  })(Sneaker.Core);

  Sneaker.ns.set(this, 'Sneaker.Box', SneakerBox);

  SneakerApi = (function(_super) {

    __extends(SneakerApi, _super);

    function SneakerApi() {
      return SneakerApi.__super__.constructor.apply(this, arguments);
    }

    SneakerApi.has_default = function(hash) {
      var defaults;
      Sneaker.util.type(hash, 'object', '@default expects to be passed a hash of name/value pairs');
      defaults = Sneaker.convention.requestDefaultsName();
      this.prototype[defaults] = jQuery.extend(true, {}, this.prototype[defaults], hash);
    };

    SneakerApi.has_defaults = SneakerApi.has_default;

    SneakerApi.has_request = function(name, fn) {
      Sneaker.util.type(name, 'string', '@request expects the first argument to be a string');
      Sneaker.util.type(fn, 'function', '@request expects the second argument to be a function');
      this.prototype[Sneaker.convention.requestName(name)] = fn;
    };

    SneakerApi.install = function(mock) {
      var name, response, responses, _base, _i, _len, _ref, _ref1;
      responses = Sneaker.convention.responsesName();
      (_base = this.prototype)[responses] || (_base[responses] = ((_ref = this.prototype[responses]) != null ? _ref.slice(0) : void 0) || []);
      _ref1 = mock.prototype[responses];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        response = _ref1[_i];
        this.prototype[responses].push(response);
        this.prototype[responses] = Sneaker.util.uniq(this.prototype[responses]);
        name = Sneaker.convention.responseName(response);
        this.prototype[name] = mock.prototype[name];
      }
    };

    SneakerApi.uninstall = function() {
      var response, _i, _len, _ref;
      _ref = this.prototype[Sneaker.convention.responsesName()];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        response = _ref[_i];
        delete this.prototype[Sneaker.convention.responseName(response)];
      }
      delete this.prototype[Sneaker.convention.responsesName()];
    };

    SneakerApi.prototype.handle = function(phrase, eventAttributes) {
      var deferred, handler;
      if (Sneaker.util.type(phrase, 'string')) {
        handler = this[Sneaker.convention.handlerName(phrase)];
        if (handler) {
          deferred = jQuery.Deferred();
          handler.call(this, eventAttributes, deferred);
          return deferred;
        } else {
          return this.request(phrase, eventAttributes);
        }
      }
    };

    SneakerApi.prototype.request = function(phrase, eventAttributes) {
      var defaults, merged, request, requestHandler, responseMock;
      if (Sneaker.util.type(phrase, 'string')) {
        defaults = this[Sneaker.convention.requestDefaultsName()] || {};
        requestHandler = this[Sneaker.convention.requestName(phrase)];
        if (requestHandler != null) {
          request = requestHandler.call(this, eventAttributes);
          merged = jQuery.extend({}, defaults, request);
          responseMock = this[Sneaker.convention.responseName(phrase)];
          if (responseMock != null) {
            return Sneaker.ApiMock.prototype.respond(responseMock.call(this, merged, eventAttributes));
          } else {
            return jQuery.ajax(merged);
          }
        }
      }
    };

    return SneakerApi;

  })(Sneaker.Core);

  Sneaker.ns.set(this, 'Sneaker.Api', SneakerApi);

  Sneaker.ns.set(this, 'Sneaker.API', SneakerApi);

  SneakerApiMock = (function() {

    function SneakerApiMock() {}

    SneakerApiMock.has_response = function(name, fn) {
      var responses;
      Sneaker.util.type(name, 'string', '@response expects `name` to be a string');
      Sneaker.util.type(fn, 'function', '@response expects the second argument to be a function');
      responses = Sneaker.convention.responsesName();
      (this.prototype[responses] = (this.prototype[responses] || []).slice(0)).push(name);
      return this.prototype[Sneaker.convention.responseName(name)] = fn;
    };

    SneakerApiMock.prototype.respond = function(mockedResponse) {
      var status, statusCodes;
      if (mockedResponse == null) {
        mockedResponse = {};
      }
      status = mockedResponse.status || (mockedResponse.status = 200);
      mockedResponse.body || (mockedResponse.body = null);
      statusCodes = {
        100: "Continue",
        101: "Switching Protocols",
        200: "OK",
        201: "Created",
        202: "Accepted",
        203: "Non-Authoritative Information",
        204: "No Content",
        205: "Reset Content",
        206: "Partial Content",
        300: "Multiple Choice",
        301: "Moved Permanently",
        302: "Found",
        303: "See Other",
        304: "Not Modified",
        305: "Use Proxy",
        307: "Temporary Redirect",
        400: "Bad Request",
        401: "Unauthorized",
        402: "Payment Required",
        403: "Forbidden",
        404: "Not Found",
        405: "Method Not Allowed",
        406: "Not Acceptable",
        407: "Proxy Authentication Required",
        408: "Request Timeout",
        409: "Conflict",
        410: "Gone",
        411: "Length Required",
        412: "Precondition Failed",
        413: "Request Entity Too Large",
        414: "Request-URI Too Long",
        415: "Unsupported Media Type",
        416: "Requested Range Not Satisfiable",
        417: "Expectation Failed",
        422: "Unprocessable Entity",
        500: "Internal Server Error",
        501: "Not Implemented",
        502: "Bad Gateway",
        503: "Service Unavailable",
        504: "Gateway Timeout",
        505: "HTTP Version Not Supported"
      };
      if ((status >= 200 && status < 300) || status === 304 || status === 1223 || status === 0) {
        return jQuery.Deferred().resolveWith(this, [mockedResponse.body, statusCodes[status], {}]);
      } else {
        return jQuery.Deferred().rejectWith(this, [{}, statusCodes[status], new Error(statusCodes[status])]);
      }
    };

    return SneakerApiMock;

  })();

  Sneaker.ns.set(this, 'Sneaker.ApiMock', SneakerApiMock);

}).call(this);
