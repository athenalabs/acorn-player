//     player.js 0.0.0
//     (c) 2012 Juan Batiz-Benet, Ali Yahya, Daniel Windham
//     Acorn is freely distributable under the MIT license.
//     Inspired by github:gist.
//     For all details and documentation:
//     http://github.com/athenalabs/acorn-player

(function() {

// Setup
// -----

// Establish the root object, `window` in browser, or `global` on server.
var root = this;

// For acorn's purposes, jQuery, Zepto, or Ender owns the `$` variable.
var $ = root.jQuery || root.Zepto || root.ender;

// Local handles for global variables.
var _ = root._;
var Backbone = root.Backbone;
var acorn = root.acorn;

// Ensure all our requirements are met:

// Error out if acorn isn't present.
if (acorn == undefined)
  throw new Error('player.js requires acorn.js');

// Error out if acorn.shells isn't present.
if (acorn.shells == undefined)
  throw new Error('player.js requires acorn.shells');

// Error out if underscore isn't present.
if (_ == undefined)
  throw new Error('player.js requires Underscore.js');

// Error out if backbone isn't present.
if (Backbone == undefined)
  throw new Error('player.js requires Backbone.js');


// local handles
var extend = acorn.util.extend;
var assert = acorn.util.assert;


// ** acorn.player ** the acorn.player library
// -------------------------------------------

// Flag that player.js is present.
var player = acorn.player = {};

// Current version.
player.VERSION = '0.0.0';

// Our Current web instance.
player.instance = undefined;

player.views = {};
player.views.controls = {};

// ** player.play ** tell the player instance to play given acorn
// --------------------------------------------------------------
player.play = function(acornModel) {

  if (!player.instance)
    throw new Error('no acorn player instance available.');

  if (!acornModel)
    throw new Error('no acorn given');

  // set the new acorn model
  player.instance.model = acornModel;

  // trigger acorn change.
  player.instance.trigger('change:acorn');

};

}).call(this);
