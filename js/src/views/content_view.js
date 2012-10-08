(function() {

var player = acorn.player;

// ** player.views.ContentView ** view that renders/embeds shells
// --------------------------------------------------------------
player.views.ContentView = player.views.PlayerSubview.extend({

  id: 'content',

  // Supported trigger events
  // * all PlayerView events (proxying)

  initialize: function() {
    player.views.PlayerSubview.prototype.initialize.call(this);

    // proxy player events over, so shell ContentViews can listen.
    this.player.on('all', this.trigger)
  },

  render: function() {
    if (this.shellView)
      this.shellView.remove();

    this.shellView = new this.player.shell.shellClass.ContentView({
      shell: this.player.shell,
      parent: this,
      autoplay: true,
    });

    this.$el.empty();
    this.shellView.render();
    this.$el.append(this.shellView.el);
  },

});

}).call(this);
