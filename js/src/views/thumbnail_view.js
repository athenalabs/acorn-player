(function() {

var player = acorn.player;

// ** player.views.ThumbnailView ** a view showing the acorn thumbnail
// -------------------------------------------------------------------
player.views.ThumbnailView = player.views.PlayerSubview.extend({

  template: _.template('\
    <img id="image" src="/img/blank.png" />\
    <img id="type" src="" class="thumbnail-icon" />\
    <img id="logo" src="" class="thumbnail-icon" />\
  '),

  id: 'thumbnail',

  render: function() {
    this.$el.empty();

    var shelltype = this.player.shell.type;
    var typeurl = acorn.util.imgurl('icons', shelltype + '.png');
    var acornurl = acorn.util.imgurl('acorn.png');
    var thumburl = this.player.shell.thumbnailLink();

    this.$el.html(this.template());
    this.$el.find('#type').attr('src', typeurl);
    this.$el.find('#logo').attr('src', acornurl);
    this.$el.find('#image').attr('src', thumburl);
  },

});

}).call(this);
