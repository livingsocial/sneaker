#Sneaker.coffee

Sneaker is object-oriented, highly testable jQuery.  Bring some structure to your jQuery-based user interfaces.

+ **Extends jQuery.** Sneaker lends object-oriented organization to the main purposes of jQuery.  Contrary to other sales pitches flying about - you ***can*** write well structured code that, at its core, leverages jQuery, and Sneaker will help you.
+ **Written for CoffeeScript.** Sneaker takes full advantage of CoffeeScript's `class` idiom to produce an object definition pattern that can be expressive, legible, and self-documenting.
+ **Jasmine-friendly, with mocks.** Sneaker comes with a bundle of handy Jasmine matchers.  More importantly, the `API` class comes with mocking built-in, allowing for simple acceptance tests, or for use in development when an API isn't quite ready yet.
+ **Architecture-neutral.** Sneaker doesn't reduce your job to manipulating the magic inside a black-box application object, reaching towards a rough approximation of your intended experience.  Write exactly what you intend to have happen.
+ **Don't call it a framework.** So many frameworks seem bent on fabricating entirely new architecture vocabularies and reimplementing just about everything.  The intention with Sneaker is to fit within your current approach, whatever that may be, to help you write legible, testable code.  Sneaker's individual bits work well alone, but are better when used together to define an entire user interface.

Ready to get moving?

###Lace up
`sneaker.coffee` included in your project, as you would any other vendored script, is the minimum you need to get moving.

[`jQuery >= 1.8`](http://jquery.com/download/) is a hard dependency.  Obviously, since Sneaker is written to extend jQuery, Sneaker won't work without it.

`sneaker-matchers.coffee` is a collection of Jasmine matchers (if you're into that sort of thing, which you should be).  Some of these matchers utilize [`Lo-Dash >= 1.0.1`](https://github.com/bestiejs/lodash/blob/master/lodash.js); drop that into your spec manifest for best results.

`Sneaker.Box` is an array-like object that implements the gamut of ES5 array methods.  To get the full capabilities of this object in older browsers, [drop in this shim](https://github.com/kriskowal/es5-shim/blob/master/es5-shim.js).  Hitting such methods in older browsers that don't support them, without using shims, will see `Box` return `undefined` from those methods.

###Read up
Lots of useful words have been crammed in the [Wiki](sneaker-js/wiki).

###Version Up
0.8.1 - May 16 2013

###Tested up
+ Firefox >= 4.0.1
+ Internet Explorer >= 6.0
+ Current versions of Opera, Safari, and Chrome

###Credits
Sneaker was extracted from work done on the LivingSocial Merchant Center by Chris Schetter.

Sneaker surely wouldn't be a thing without the consideration and input of Kevin McConnell, Sara Flemming, Eric Brody, Rodrigo Franco, Michael Buffington, Jon Dodson, Tim Linquist, Mark Tabler, Elise Worthy, Jess Eldredge, Michael Zinn, Rein Heinrichs, Doug March, and Jonathan Phillips; and support from Maria Gutierrez, Ryan Owens, and Bruce Williams.

###Contributing
Source code is found under `/source`.  Tests are found under `/tests`.
Release candidates are queued up on the branch named `next` - pull requests for contributions should be pointed there.  Branch `master` represents the current release version.

###Testing
`guard`

Gems `guard-jasmine` and `jasminerice` employed to run tests.
While guard is running, the coffeescript will be compiled to the same file name under `/compiled`, if you'd like to look it over.

###Building
`rake build`

Concatenates the coffeescript source to `sneaker.coffee`.
Compiled javascript written to `sneaker.js`.