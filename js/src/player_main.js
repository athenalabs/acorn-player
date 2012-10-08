(function() {

var player = acorn.player;

// ** player.Router ** routes requests
// -----------------------------------
player.Router = Backbone.Router.extend({

  routes: {
    '':                     'nothing',
    'player/new':           'new',
    'player/:acornid':      'acorn',
    ':catchall':            'nothing',
  },

  nothing: function() {
    this.navigate('player/new', {trigger: true});
  },

  new: function() {
    var acornModel = acorn('new');
    this.showAcorn(acornModel);

    this.playerView.render();
    this.playerView.trigger('show:edit');

    this.playerView.editView.$el.find('#link input:first').focus();
  },

  acorn: function(acornid) {
    if (this.playerView && acornModel == this.playerView.model)
      return;

    var acornModel = acorn(acornid);
    this.showAcorn(acornModel);

    var self = this;
    this.playerView.model.fetch({
      success: function() { self.playerView.trigger('change:acorn'); },
      error: function() { self.playerView.error('failed to retrieve'); }
    });

  },

  showAcorn: function(acornModel) {
    this.playerView = new acorn.player.views.PlayerView({
      el: $('#acorn-player'),
      model: acornModel,
    });

    // give the playerView a handle to the router
    this.playerView.router = this;
    this.playerView.on('rename:acorn', _.bind(this.onRenamedAcorn, this));

    $('title').text('acorn:' + acornModel.acornid());

    acorn.player.instance = this.playerView;
  },

  onRenamedAcorn: function(acornid) {
    this.navigate('/player/' + acornid, {trigger: true});
  },

});

}).call(this);
