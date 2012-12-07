(function() {

var player = acorn.player;

// ** player.EditView ** a view to house all editing controls
// ----------------------------------------------------------------
player.EditView = acorn.OverlayView.extend({

  template: _.template('\
    <div class="row" id="toolbar">\
      <h1>acornid:<span id="acornid"></span></h1>\
      <div id="actions">\
        <button id="cancel" type="submit" class="btn">\
          <i class="icon-ban-circle"></i> Cancel\
        </button>\
        <button id="save" type="submit" class="btn btn-success">\
          <i class="icon-ok-circle icon-white"></i> Save\
        </button>\
        <div id="save-click-capture"></div>\
      </div>\
    </div>\
    <div id="form"></div>\
  '),

  id: 'edit',

  events: _.extend({}, acorn.OverlayView.prototype.events, {
    'click button#cancel': 'onCancel',
    'click button#save': 'onSave',
  }),

  initialize: function() {
    acorn.OverlayView.prototype.initialize.apply(this, arguments);

    this.player = this.options.player;
    acorn.util.assert(this.player, 'no player provided to player.EditView.');

    this.setShell(this.player.shell.clone());
  },

  setShell: function(shell) {
    if (this.shellView)
      this.shellView.remove();

    this.editingShell = shell;
    this.shellView = new shell.shellClass.EditView({
      shell: this.editingShell,
      parent: this,
    });

    // listen to the child view's edit state
    this.shellView.on('change:editState', this.onEditStateChange);

    // listen to the editing view's swap:shell event.
    // this will tell us when the shell data changes entire shell and
    // we need to reassign the shell and render the entire subview.
    this.shellView.on('swap:shell', this.onSwapShell);
    this.onEditStateChange();
  },

  render: function() {
    acorn.OverlayView.prototype.render.apply(this, arguments);

    this.content.empty();

    this.content.html(this.template());
    this.content.find('#acornid').text(this.player.model.acornid());

    if (this.shellView) {
      this.shellView.render();
      this.content.find('#form').append(this.shellView.el);
    }

    this.content.find('#save-click-capture').tooltip({
      title: 'Finish editing<br/>before saving!',
      placement: 'bottom'
    });
  },

  onEditStateChange: function() {},

  onSwapShell: function(data) {
    var shell = acorn.shellWithData(data);
    this.setShell(shell);
    this.render();
  },

  onCancel: function() {
    this.player.trigger('close:edit');
  },

  onSave: function() {
    this.shellView.finalizeEdit();
    this.player.trigger('save:acorn');
  },

  // **isDirty** returns whether shell being edited has changes.
  isDirty: function() {
    var editingData = this.editingShell.data;
    var playerData = this.player.shell.data;
    return !_.isEqual(editingData, playerData);
  },

});

}).call(this);
