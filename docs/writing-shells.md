# Writing Shells

So, you've checked out ``acorn``, and you want to create a new shell to remix
amazing new kinds of media! This is the place to go.


You may want to familiarize yourself with how Backbone Views work.


Let's start by looking at an annotated (with ``//@@``) version of ``ImageLinkShell``, a shell
that renders image files linked on the web.


```javascript

// ImageLinkShell --  A shell that links to images and embeds them.
// ----------------------------------------------------------------


//@@ ImageLinkShell definition.
//@@ It derives from LinkShell, the geneeric shell for link-based media.

//@@ calling .extend is the Backbone view inheritance pattern.
var ImageLinkShell = acorn.shells.ImageLinkShell = LinkShell.extend({

  //@@ shellid specifies the shell type, which will be recorded into the
  //@@ 'shell.shell' value in acorn data.
  shellid: 'acorn.ImageLinkShell',

  //@@ the type here indicates the primitive (or canonical) media kind.
  //@@ this is used to indicate (with icons) to users what to expect.

  // The canonical type of this media. One of `acorn.types`.
  type: 'image',

  //@@ validRegexes specify regular expressions for links to match this shell.
  //@@ here, image files are defined to end in an image file extension.
  //@@ of course, some images won't have URLs like that, but certain kinds
  //@@ of media do follow this pattern closely (see YouTubeShell).

  // **validRegexes** list of valid LinkRegexes for images
  // .jpg, .png, .gif, etc.
  validRegexes: [
    UrlRegExp('.*\.(jpg|jpeg|gif|png|svg)'),
  ],

});


// Shell.ContentView -- renders the image within the bounds of the player.
// -----------------------------------------------------------------------

//@@ ImageLinkShell.ContentView definition.
//@@ The ContentView is what determines how this shell will render.
//@@
//@@ It derives from LinkShell.ContentView, the LinkShell specific ContentView.
//@@ It is usually the case that shells that derive from others have ShellViews
//@@ that derive from their parent's ShellViews (like here!).

ImageLinkShell.ContentView =  LinkShell.ContentView.extend({

  //@@ this particular shell uses a template.
  template: _.template('\
    <div class="wrapper"></div>\
  '),

  //@@ the render function, like in any other Backbone View.
  render: function() {

    //@@ retrieve the link. shell.link is a function in LinkShell.
    var link = this.shell.link();

    //@@ create an img html element, and assign the link.
    var img = $('<img>').attr('src', link);

    //@@ render the template.
    this.$el.html(this.template);

    //@@ append the img tag to the rendered template, in the right spot.
    this.$el.find('.wrapper').append(img);

  },

});


//@@ This Shell does not need to specify an EditView. It simply uses its
//@@ parent's, LinkShell.EditView. It provides exactly the functionality
//@@ we want.

//@@ Registering the shell is important. It's what allows the acorn-player
//@@ to construct the right Shell objects for the right shell identifiers.

// Register the shell with the acorn object.
acorn.registerShell(ImageLinkShell);

//@@ That's it! It was that easy to create an acorn view.

```
