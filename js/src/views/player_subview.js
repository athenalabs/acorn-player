(function () {

var player = acorn.player;

// ** player.views.PlayerSubview ** a sub-component view for PlayerView
// --------------------------------------------------------------------
var PlayerSubview = player.views.PlayerSubview = Backbone.View.extend({

  initialize: function() {
    _.bindAll(this);
    _.defaults(this.options, this.defaults || {});

    this.player = this.options.player;
    assert(this.player, 'no player provided to PlayerSubview.');
  },

});

}).call(this);