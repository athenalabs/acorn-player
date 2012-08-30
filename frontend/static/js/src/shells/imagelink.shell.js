// ImageLinkShell --  A shell that links to imaged and embeds them.
// ----------------------------------------------------------------

var ImageLinkShell = acorn.shells.ImageLinkShell = LinkShell.extend({

  shellid: 'acorn.ImageLinkShell',

  // The cannonical type of this media. One of `acorn.types`.
  type: 'image',

  // **validRegexes** list of valid LinkRegexes for images
  // .jpg, .png, .gif, etc.
  validRegexes: [
    UrlRegExp('.*\.(jpg|jpeg|gif|png|svg)'),
  ],

});


// Shell.ContentView -- renders the image within the bounds of the player.
// -----------------------------------------------------------------------

ImageLinkShell.ContentView =  LinkShell.ContentView.extend({

  render: function() {
    var link = this.shell.link();
    var img = $('<img>').attr('src', link);
    this.$el.html(img);

    // TODO: make image fit within bounds of player
  },

});


// Register the shell with the acorn object.
acorn.registerShell(ImageLinkShell);
