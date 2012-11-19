(function() {

var player = acorn.player;

// ** player.ThumbnailView ** a view showing the acorn thumbnail
// -------------------------------------------------------------
player.ThumbnailView = player.PlayerSubview.extend({

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

    this.$el.html(this.template());
    this.$el.find('#type').attr('src', typeurl);
    this.$el.find('#logo').attr('src', acornurl);

    var thumbnailLink = this.player.shell.thumbnailLink();
    thumbnailLink.sync({
      success: _.bind(function(thumbnailLink) {
        this.$el.find('#image').attr('src', thumbnailLink);
      }, this),
    });
  },

});

}).call(this);
