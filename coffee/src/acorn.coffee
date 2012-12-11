#  acorn.js 0.0.0
#  (c) 2012 Juan Batiz-Benet, Ali Yahya, Daniel Windham
#  Acorn is freely distributable under the MIT license.
#  Inspired by github:gist.
#  Portions of code from Underscore.js and Backbone.js
#  For all details and documentation:
#  http://github.com/athenalabs/acorn-player

goog.provide 'acorn'

goog.require 'acorn.Model'

acorn_ = (data) ->
  acorn.Model.withData data

# patch the global `acorn` object as this function
_.extend acorn_, acorn
acorn = acorn_
