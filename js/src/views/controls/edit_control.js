(function() {

var player = acorn.player;

// ** player.views.controls.Edit ** onClick : edit
// ---------------------------------------------------------------------
player.views.controls.Edit = player.views.controls.Item.extend({

  tooltip: 'Edit',

  id: 'edit',

  className: 'control right',

  onClick: function() {
    this.controls.player.trigger('show:edit');
  },

});

}).call(this);
