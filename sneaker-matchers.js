/*
Sneaker UI Library Jasmine Matchers
Version 0.8.1

Copyright 2013 LivingSocial, Inc.
Released under the MIT license
*/

beforeEach(function() {
  var toBox, toHandle, toHook, toListenFor, toTemplate;
  toHandle = function(expected) {
    var handler, name, nt;
    name = this.actual.name;
    handler = this.actual.prototype[Sneaker.convention.handlerName(expected)];
    nt = this.isNot ? 'not handle' : 'handle';
    this.message = function() {
      return "Expected " + name + " to " + nt + " events where action is `" + expected + "`.";
    };
    return handler != null;
  };
  toHook = function(namespace, selector) {
    var hooks, name, nt;
    name = this.actual.name;
    hooks = this.actual.prototype[Sneaker.convention.hooksName()];
    nt = this.isNot ? 'not have' : 'have';
    this.message = function() {
      return "Expected " + name + " to " + nt + " hook `" + selector + "` to `" + namespace + "`.";
    };
    if (selector != null) {
      return (Sneaker.ns.get(hooks, namespace)) === selector;
    } else {
      return (Sneaker.ns.get(hooks, namespace)) != null;
    }
  };
  toListenFor = function(event, hookPath) {
    var found, interaction, name, nt, types, _i, _len, _ref;
    name = this.actual.name;
    nt = this.isNot ? 'not' : '';
    this.message = function() {
      return "Expected " + name + " to " + nt + " listen for `" + event + "` at `" + namespace + "`";
    };
    found = false;
    _ref = this.actual.prototype[Sneaker.convention.interactionsName()];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      interaction = _ref[_i];
      if (!found) {
        if (interaction.hook === hookPath) {
          types = interaction.types.split(' ');
          if (_.contains(types, event)) {
            found = true;
          }
        }
      }
    }
    return found;
  };
  toBox = function(boxName, box) {
    var boxes, name, nt;
    if (box == null) {
      box = Sneaker.Box;
    }
    nt = this.isNot ? 'not have' : 'have';
    name = this.actual.name;
    this.message = function() {
      return "Expected " + name + " to " + nt + " a box at " + name;
    };
    boxes = this.actual.prototype[Sneaker.convention.boxesName()];
    if (boxes != null) {
      return boxes[boxName] === box && (new this.actual)[boxName] instanceof box;
    } else {
      return false;
    }
  };
  toTemplate = function(expected) {
    var name, nt, template;
    name = this.actual.name;
    template = this.actual.prototype[Sneaker.convention.templateName(expected)];
    nt = this.isNot ? 'not have' : 'have';
    this.message = function() {
      return "Expected " + name + " to " + nt + " a template named `" + expected + "`";
    };
    return template != null;
  };
  return this.addMatchers({
    toHandle: toHandle,
    toHaveHandler: toHandle,
    toHook: toHook,
    toHaveHook: toHook,
    toListenFor: toListenFor,
    toHaveListener: toListenFor,
    toBox: toBox,
    toHaveBox: toBox,
    toTemplate: toTemplate,
    toHaveTemplate: toTemplate,
    toExtend: function(cls) {
      var name, nt;
      name = this.actual.name;
      nt = this.isNot ? 'not extend' : 'extend';
      this.message = function() {
        return "Expected " + name + " to " + nt + " " + cls.name;
      };
      return (new this.actual) instanceof cls;
    },
    toAlter: function(valueFn) {
      var before, nt;
      Sneaker.util.type(this.actual, 'function', '#toAlter needs a function as the expected');
      Sneaker.util.type(valueFn, 'function', '#toAlter needs a function as the target');
      nt = this.isNot ? 'not have' : 'have';
      this.message = function() {
        return "Expected the object given to " + nt + " changed.";
      };
      before = valueFn();
      this.actual();
      return !_.isEqual(before, valueFn());
    },
    toAlterContentsOf: function(container) {
      var after, before, nt;
      nt = this.isNot ? 'not have' : 'have';
      this.message = function() {
        return "Expected the contents of the element given to " + nt + " changed.";
      };
      before = _.cloneDeep(jQuery(container).html());
      this.actual();
      after = _.cloneDeep(jQuery(container).html());
      return !_.isEqual(before, after);
    },
    toHaveRequest: function(phrase) {
      var name, nt;
      name = this.actual.name;
      nt = this.isNot ? 'not have' : 'have';
      this.message = function() {
        return "Expected " + name + " to " + nt + " a request named " + phrase + ".";
      };
      return this.actual.prototype[Sneaker.convention.requestName(phrase)] != null;
    }
  });
});
