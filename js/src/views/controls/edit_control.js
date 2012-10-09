(function() {

var player = acorn.player;

// ** player.views.EditControl ** onClick : edit
// ---------------------------------------------------------------------
player.views.EditControl = player.views.ControlItem.extend({

  tooltip: 'Edit',

  id: 'edit',

  className: 'control right',

  onClick: function() {
    this.player.trigger('show:edit');
  },

});

}).call(this);
