(function() {

var player = acorn.player;

// ** player.EditView ** a view to house all editing controls
// ----------------------------------------------------------------
player.EditView = player.PlayerSubview.extend({

  template: _.template('\
    <div class="clear-cover"></div>\
    <div class="background"></div>\
    <div class="content">\
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
    </div>\
  '),

  id: 'edit',

  events: {
    'click button#cancel': 'onCancel',
    'click button#save': 'onSave',
  },

  initialize: function() {
    player.PlayerSubview.prototype.initialize.call(this);

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
    this.$el.empty();

    this.$el.html(this.template());
    this.$el.find('#acornid').text(this.player.model.acornid());

    if (this.shellView) {
      this.shellView.render();
      this.$el.find('#form').append(this.shellView.$el);
    }

    this.$el.find('#save-click-capture').tooltip({
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
