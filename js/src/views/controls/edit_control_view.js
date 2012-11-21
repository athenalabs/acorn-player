(function() {

var player = acorn.player;

// ** player.EditControlView ** onClick : edit
// -------------------------------------------
player.EditControlView = player.ControlItemView.extend({

  tooltip: 'Edit',

  id: 'edit',

  className: 'control right',

  onClick: function() {
    this.controls.player.trigger('show:edit');
  },

});

}).call(this);