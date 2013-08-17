#Sneaker.coffee

Sneaker is object-oriented, highly testable jQuery.

+ **Extends jQuery.** jQuery shouldn't be synonymous with spaghetti; Sneaker lends simple structure to the best of jQuery.
+ **Written for CoffeeScript.** Sneaker provides an object definition pattern geared towards legibility and self-documentation.
+ **Jasmine-friendly, with mocks.** Sneaker's `API` object has the notion of mocking responses built-in, to aid in both development and testing; and the library comes with a bundle of handy Jasmine matchers.  
+ **Architecture-neutral.** Your job shouldn't be reduced to manipulating the magic inside a black-box application object, reaching towards a rough approximation of your intended experience.  Write exactly what you intend to have happen.
+ **Don't call it a framework.** Sneaker has no interest in reinventing, reimplementing, or revolutionizing.  Sneaker doesn't try to save developers from themselves.  The intention with Sneaker is to bring greater clarity to your current approach through a small set of independently useful bits; nudging you towards legible, testable code that those who inherit your project will thank you for, instead of burning effigies in your likeness.

Ready to get moving?

###Lace up
1. Include `sneaker.coffee` as you would any other vendored script.

2. [`jQuery 1.8 or later`](http://jquery.com/download/) is required.

3. For testing with Jasmine, include `sneaker-matchers.coffee` into your spec manifest.

4. [`Lo-Dash >= 1.0.1`](https://github.com/bestiejs/lodash/blob/master/lodash.js) is used by some of the matchers.

5. [This ES5 shim](https://github.com/kriskowal/es5-shim/blob/master/es5-shim.js) is recommended if you need to support browsers that aren't fully down with ES5 arrays, so that `Sneaker.Box` is fully functional.

###Read up
Lots of useful words have been crammed in the [Wiki](https://github.com/livingsocial/sneaker/wiki).

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

###Testing
```bash
$ bundle
$ bundle exec guard
```

Gems `guard-jasmine` and `jasminerice` employed to run tests.
While guard is running, the coffeescript will be compiled to the same file name under `/compiled`, if you'd like to look it over.

###Building
```bash
$ bundle exec rake build
```

Concatenates the coffeescript source to `sneaker.coffee`.
Compiled javascript written to `sneaker.js`.