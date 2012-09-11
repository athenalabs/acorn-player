# DESIGNDOC

``acorn-player`` is the embedded-player used by acorn.
[Acorn](http://staging.acorn.athena.ai) is a universal media wrapper.

The purpose of ``acorn-player`` is to provide a simple media
player that supports viewing all sorts of different media types, in a unified
way.

## Overview

Note: overview from a product-centric view.

### Terminology:

* **media**: a viewable, consumable stream of information, usually of a
  particular kind

  (e.g. video, sound, text, games).

* **media primitive**: cannonical kinds of media

  (e.g. video, text, sound).

* **multimedia**: a kind of media that encompasses other kinds of media

  (e.g. games, slideshow).


* **media kind**: a concretely defined type of media (on the web).

  (e.g. text, an audio file, an image file, a YouTube Video, a Vimeo Video)

* **media piece**: an independent, atomic media item

  (e.g. a specific video).

* **remix**: a media piece built on top of other media pieces.

  (e.g. a specific video clip from a specific video).

* **player**: web technology that enables viewing/consumption of media pieces.

* **native-player**: web technology of a particular vendor, to be used to play
  media pieces hosted by the vendor

  (e.g. YouTube Embedded Player, Vimeo Player).

* **acorn**: a remix combining media pieces through the use of computation.

* **``acorn-player``**: a player that plays acorns


* **shell**: an ``acorn-player`` module to play and edit specific media kinds.

  (e.g. ``ImageLinkShell``, ``YouTubeShell``).

* **shell type**: an identifier that uniquely identifies a shell module. They are meant to be vendor-specific.

  (e.g. ``acorn.ImageLinkShell``, ``acorn.YouTubeShell``).




### Description

``acorn-player`` is a web technology that enables playing and remixing
different kinds of media in a unified way.

``acorn-player`` enables:
* playing media pieces of various kinds
* composing remixes
* embedding in webpages

#### Playing Media Pieces

``acorn-player`` aims to be a player that can play all kinds of different media
pieces, of various kinds and from various vendors. It should be able to:

* show videos, music, images, text, documents, etc.
* more specifically, show YouTube and Vimeo videos, .jpg and .png files, .mp3
  files, Flash games, PDF files, etc.
* and show compositions of these, such as playlists, galleries, slideshows,
  spliced videos, etc.

Thus, ``acorn-player`` has a very general approach to interacting with
 media that can be extended to support each specific kind of media.

The current design of the player viewing state features a content viewing area,
and a generic controls bar:

![content-controls-separation](https://img.skitch.com/20120911-kwxurtywnhpnyssm188a21mry9.png)

##### Content Area

The content area is left up to specific shells to render as they wish, for
example:

* VimeoShell - Renders vimeo player through an embedded iframe.

![vimeo-shell](http://static.enrage.me/athena/test.vimeo.shell.png)

* PDFShell - Renders pdf through an embedded iframe.

![pdf-shell](http://static.enrage.me/athena/test.pdf.shell.png)

* LinkShell - Renders website through an embedded iframe.

![link-shell](http://static.enrage.me/athena/test.link.shell.png)


##### Controls Bar

The controls bar is further divided in two sections:

* **acorn-wide section**: controls that affect or leverage all acorns,
regardless of the underlying media kinds (or the shells used to render them).

* **shell-specific section**: controls that affect or leverage the media
playing, and thus depend on the underlying media kinds and the shells used to
render them.


![controls-division](https://img.skitch.com/20120911-cds9g6j2ub3g1t97ea8fxp9wy7.png)


The controls above are:

* acorn-wide controls:
  * **Edit** opens an editor to edit the underlying acorn.
  * **Link** opens the current acorn webpage (if it is saved to a server).
  * **Fullscreen** fullscreens the acorn in the browser.


* shell-specific controls, in this case for a MultiShell:
  * **Previous** switches to the previous subshell.
  * **List** opens a list of all subshells in this MultiShell.
  * **Next** switches to the next subshell.

![controls-division-full](https://img.skitch.com/20120911-c82ujsw994ty81aqy9xnawnye4.png)


#### Composing Remixes


``acorn`` enables remixing one or multiple media pieces (of different kinds)
into a new media piece. ``acorn-player`` allows this remixing via a composition
or editing interface, that is specific to the media kind.

Some examples of remixing, with interfaces:

* clipping a video -- VideoLinkShell

![videolinkshell-editing](https://img.skitch.com/20120911-1t1seh9g4i25r59ij7n887qu82.png)

* playlist of various media -- MultiShell

![multishell-editing](https://img.skitch.com/20120911-chk6qapyd81gn61fh4qs2rr4uu.png)

This capability is implemented by having a generic acorn-wide edit view where
the acorn itself can be edited:

![edit-view](https://img.skitch.com/20120911-akb42ac6iumippjapkkxj6mtf.png)

and a section of the view is devoted to editing the shell itself.

![edit-view](https://img.skitch.com/20120911-1fhmsb3wa8rhtssrjnqutts9dk.png)

The shell itself can decide how and what to render in its area -- similar to how
the content view allows shells to decide what to render. This is so that shells
are free to craft the best editing experience for themselves. For example, MultiShells, having various subshells, just render the edit views of its subshells:

![multi-shell-edit-view](https://img.skitch.com/20120911-gq8bwnxd9ytsbshyhfpx4uqx59.png)


#### Embedding in Webpages

Acorn allows diverse kinds of media to be incorporated into webpages in a
uniform fasion. The ``acorn-player`` is simple to embed, and it handles the
complexities of dealing with different kinds of media internally. As a result,
both users and developers can embed a wide variety of media in exactly the same
way every time. Users can do this through the acorn player interface and
developers can do so programmatically.

**Historical Note**: creating wrappers to embed various kinds of media is a
particular pain point for any developer wishing to build a website that enables
its users to submit arbitrary media. This pain is actually what motivated the
original conception of acorn. @jbenet sought a uniform library that could embed
all kinds of media links uniformly but could not find any. As acorn took shape
to fulfill this need, it became apparent that the computing layer of indirection
acorn introduced afforded exciting power to remix media.

``acorn-player`` aims to be embeddable across the web, much like the YouTube
and Vimeo players. It should load quickly, regardless of underlying media type.
Further, it should behave in a manner expected by current web-denizens. These
requirements motivate the use of an iframe that initially shows a thumbnail
while content loads behind the scenes. The content is swapped into view when the
user engages with the media (click!).

embedded ``acorn-player``:

![embedded-acorn-player](https://img.skitch.com/20120911-ewk57srmfynjiwkhhyfgfxx884.png)


In order to inform the viewer of the media's primitive type, the thumbnail
should be overlaid with an icon that conveys the kind of media.

![annotated-embedded-acorn-player](https://img.skitch.com/20120911-keruw8hcbjbt8gt2tm6xt1pg52.png)

Clicking the player should begin playing the media, transitioning to show
the content area.


## Implementation

### Technologies


HTML5, JS, CSS3

Libraries:

* jQuery (js)
* Underscore.js
* Backbone.js
* Bootstrap (css, js)

Services:
* url2png
//TODO(ali): add note that thumbnails wont work :p

### Architecture
#### Acorn Data Model

An acorn is backed by a dictionary that defines the basic
properties and behavior of the acorn. At the very least, the most basic
representation of an acorn requires an ```acornid``` and a shell specification.

An acorn shell is an implementation of acorn's wrapping functionality for a
single type of media. Said type can be anything from an image or PDF to a
YouTube video. A shell can even wrap a collection (or a playlist) of child
shells, as with MultiShell. Each shell is implemented as an independent module
where the shell object in question ultimately inherits from acorn.shells.Shell
(defined in
[shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/shell.js)).

The simplest shell implementation is the
[EmptyShell](/athenalabs/acorn-player/blob/master/js/src/shells/empty.shell.js)
, which is used to represent and render a shell to which no media has been
added.

##### Construction

For example, the following code snippet illustrates how to create the most
basic of acorns using an ```EmptyShell```:

    var acornModel = acorn.withData({
      "acornid": "local",
      "shell": {
        "shell": "acorn.EmptyShell",
      },
    });

    var playerFrame = document.getElementById('player');
    acorn.playInFrame(acornModel, playerFrame);

The acorn data can be constructed on the fly to represent the desired media.
The shells encode the relevant information necessary for the player and the
shell module to render the media. (Note that ``shell``, the shell type, is the
only required piece of information for shells. Everything else depends on the
specific shell class that the shell type identifies.)

The only assumptions made by the code above are that ```acorn.js``` is included
and that there exists an iframe with id "player" in the DOM. To view the full
source of the above example, see
[example.emptyshell.html](/athenalabs/acorn-player/blob/docfix/examples/example.emptyshell.html) in the examples directory.

The code above instantiates an ```acorn.Model``` object from a javascript
dictionary. The definition of ```acorn.Model``` in
[acorn.js](/athenalabs/acorn-player/blob/master/js/src/acorn.js) implements the
base acorn model and top level API. ```acorn.Model``` includes basic operations
common to all acorns including ways to construct acorns from URLs, media, or
preexisting acorn data objects. It also provides useful accessors to the
acorn data fields like the ```acornid```, along with utility methods for the
acorn's JSON serialization and deserialization.

#####  Other Shell Types

A more complex (and functional) example is the following:

    var acornModel = acorn.withData({
      "acornid": "local",
      "shell": {
        "shell": "acorn.MultiShell",
        "shells": [
          {
            "shell": "acorn.ImageLinkShell",
            "thumbnailLink":
              "https://img.skitch.com/20120817-x97rpbjc2rd5yt1gh9j8udfbsu.png",
            "link":
              "https://img.skitch.com/20120817-x97rpbjc2rd5yt1gh9j8udfbsu.png"
          },
          {
            "shell": "acorn.PDFShell",
            "thumbnailLink":
              "https://img.skitch.com/20120817-tuaw1jbgrstyeugsfb4bgwu6wi.png",
            "link": "http://static.enrage.me/qjam-report.pdf"
          },
          {
            "shell": "acorn.YouTubeShell",
            "link": "http://www.youtube.com/watch?v=CbIZU8cQWXc",
            "time_start": 0,
            "time_end": 83,
            "loop": false,
          },
        ],
      },
    });

    var playerFrame = document.getElementById('player');
    acorn.playInFrame(acornModel, playerFrame);

The above illustrates the construction of an acorn of type
[MultiShell](/athenalabs/acorn-player/blob/master/js/src/shells/multi.shell.js).
MultiShell is the one shell to contain them all. Or rather, it is a shell that
can contain one or more shells of different types. The acorn in the above
example contains three different shells: image, PDF and YouTube. Note that the
MultiShell shell specification must include a ```shells``` array that encloses
all sub-shells contained by the acorn.


##### Breakdown of acorn.Model


``acorn.Model`` is a Backbone-style model (the
class does not inherit from Backbone.Model, but emulates several
characteristics). Among other things, it provides:

class vars:

* **acorn.Model.withData**: initialize an acorn.Model with given acorn data.

        var acornModel = acorn.Model.withData({
          "acornid": "local",
          "shell": {
            "shell": "acorn.YouTubeShell",
            "link": "http://www.youtube.com/watch?v=CbIZU8cQWXc",
          },
        });

* **acorn.Model.withLink**: initialize an acorn.Model with given link, and find
  the appropriate kind of LinkShell (e.g. VideoLinkShell, ImageLinkShell, etc.).

        var link = "http://www.youtube.com/watch?v=CbIZU8cQWXc";
        var acornModel = acorn.Model.withLink(link);
        acornModel.data().shell.link;
        // returns:
        // "http://www.youtube.com/watch?v=CbIZU8cQWXc"


prototype vars:

* **acorn.Model().acornid**: getsetter for the acornid.

        var acornModel = acorn.Model.withData({
          "acornid": "local",
          "shell": {
            "shell": "acorn.EmptyShell",
          },
        });
        acornModel.acornid();
        // returns:
        // "local"

* **acorn.Model().data**: getter for (a copy of) the acorn data.

        var acornModel = acorn.Model.withData({
          "acornid": "local",
          "shell": {
            "shell": "acorn.YouTubeShell",
            "link": "http://www.youtube.com/watch?v=CbIZU8cQWXc",
          },
        });
        acornModel.data();
        // returns:
        // {
        //   "acornid": "local",
        //   "shell": {
        //     "shell": "acorn.YouTubeShell",
        //     "link": "http://www.youtube.com/watch?v=CbIZU8cQWXc",
        //   },
        // }


* **acorn.Model().fetch**: retrieves acorn from the server.

        var acornModel = acorn('nyfskeqlyx');
        acornModel.fetch({
          success: function() {
            // acornModel finished loading.
          },
        });

* **acorn.Model().save**: stores acorns to the server.

        var acornModel = acorn.Model.withData({
          "acornid": "local",
          "shell": {
            "shell": "acorn.YouTubeShell",
            "link": "http://www.youtube.com/watch?v=CbIZU8cQWXc",
          },
        });
        acornModel.save({
          success: function() {
            // acornModel finished saving.
          },
        });


* **acorn.Model().toJSON**: getter for JSON encoded acorn data.

        var acornModel = acorn.Model.withData({
          "acornid": "local",
          "shell": {
            "shell": "acorn.YouTubeShell",
            "link": "http://www.youtube.com/watch?v=CbIZU8cQWXc",
          },
        });
        acornModel.toJSON();
        // returns:
        // '{"shell":{"shell":"acorn.YouTubeShell","link":
        // "http://www.youtube.com/watch?v=CbIZU8cQWXc"},"acornid":"local"}'


* **acorn.Model().fromJSON**: setter using new JSON encoded acorn data.


        var acornModel = acorn.Model.withData({
          "acornid": "local",
          "shell": {
            "shell": "acorn.EmptyShell",
          },
        });
        acornModel.fromJSON({"shell":{"shell":"acorn.YouTubeShell","link":
        "http://www.youtube.com/watch?v=CbIZU8cQWXc"},"acornid":"local"});
        acornModel.data().shell.link
        // "http://www.youtube.com/watch?v=CbIZU8cQWXc"




#### Acorn Player

The ``acorn.player`` object encapsulates all the views (each deriving from Backbone.View) that are needed to create the user experience and behavior outlined in the [Overview](#Overview) section above. It is a combination of HTML, CSS3, and Javascript designed to be embedded through an iframe. Loading ``player.html`` through an iframe embeds the player. ``player.html`` includes the relevant css and javascript files. The model that backs those views is provided by [acorn.js](/athenalabs/acorn-player/blob/master/js/src/acorn.js) (see [Acorn Data Model](#acorn-data-model)).


##### Shells

``acorn-player`` uses Shells, modules that implement a particular media type, and specify:

* how a particular media piece is represented in data (see [Acorn Data Model](#acorn-data-model)),
* how it is rendered, through a Shell.ContentView,
* how it is controlled, through controls it requires, and
* how it is edited, through a Shell.EditView.


See [docs/writing-shells.md](writing-shells.md).

##### View Hierarchy

The Views are broken down as follows:

* **PlayerView** -- the main Player object.
   * **ThumbnailView** -- renders thumbnail and type icon
   * **ContentView** --  contains the Shell.ContentView
      * **Shell.ContentView** -- renders the media piece accordingly
   * **EditView** -- contains the Shell.EditView (and saves)
      * **Shell.EditView** -- renders the media piece editing view.
   * **ControlsView** -- contains the control views.
      * **ControlViews** -- the controls in use currently.

###### PlayerView - the main acorn player view.
The PlayerView object provides the following behaviors:
* initialization of the acorn's data model and Backbone view hierarchy
* adequate event firing whenever the user interacts with the acorn at the
player level (e.g. the acorn is renamed, changed, or saved).
* player rendering logic; note that the content of the acorn is rendered by
the implementation of the acorn shell for said content type.

###### ContentView - the parent view for each shells' main content view.
Each shell's ContentView derives from this top-level ContentView and
implements the rendering logic for the shell's own content-type.

###### EditView - the parent view for all shells' edit views.
Each shell's EditView derives from this top-level EditView and implements
the rendering logic for the shell's own edit mode.

###### ControlsView - the view containing media control buttons.
The ControlsView provides the control buttons that all acorns share (namely,
FullscreenControl, AcornControl, and EditControl). Shells can extend that
list of controls with their own, special purpose buttons.


### Codebase

#### File Hierarchy:

    js/src/
    ├── acorn.js
    ├── acorn.player.js
    └── shells
        ├── shell.js
        ├── empty.shell.js
        ├── link.shell.js
        ├── imagelink.shell.js
        ├── videolink.shell.js
        ├── youtube.shell.js
        ├── vimeo.shell.js
        ├── pdf.shell.js
        └── multi.shell.js


#### Code Hierarchy


classes (does not include utility functions):

* **acorn.js**
   * **acorn.Model** - represents an acorn, holds acorn data


* **acorn.player.js**
   * **PlayerView** - acorn player main view
   * **PlayerSubview** - acorn player subview superclass
      * **ThumbnailView** - acorn thumbnail view
      * **ContentView** - player view that renders shells
      * **ControlsView** - player view with media controls
      * **EditView** - player view to house editing views
   * **Control** - superclass for all controls
      * **FullscreenControl** - onClick: fullscreen
      * **AcornControl** - onClick: open acorn page
      * **EditControl** - onClick: open edit view
      * **LeftControl** - onClick: left or previous
      * **RightControl** - onClick: right or next
      * **ListControl** - onClick: list items
   * **Router** - routes requests (Backbone)


* **shells**

   * **shell.js**
      * **ShellAPI** - interface all Shells must support
      * **Shell** - module that renders and edits media types
         * **ShellView** - view to be used by shells
         * **ContentView** - view to render shell media piece
         * **SummaryView** - view to summarize shell media piece
         * **EditView** - view to edit shell media piece


   * **empty.shell.js**
      * **EmptyShell** - strawman empty shell (inherits from Shell)
         * **ContentView** - (inherits from Shell.ContentView)


   * **link.shell.js**
      * **LinkShellAPI** - interface all links must support
      * **LinkShell** - shell that embeds media via link (Shell)
         * **ContentView** - inherits from Shell.ContentView
         * **EditView** - inherits from Shell.EditView


   * **imagelink.shell.js**
      * **ImageLinkShell** - embeds images (inherits from LinkShell)
         * **ContentView** - (inherits from LinkShell.ContentView)


   * **videolink.shell.js**
      * **Timer** - object to execute periodic callbacks
      * **VideoPlaybackInterface** - interface video shells implement
      * **VideoLinkShell** - (inherits from LinkShell)
         * **ContentView** - (inherits from LinkShell.ContentView)
         * **EditView** - (inherits from LinkShell.EditView)


   * **youtube.shell.js**
      * **YouTubeShell** - renders youtube videos (VideoLinkShell)
         * **ContentView** - (inherits from VideoLinkShell.ContentView)
         * **EditView** - (inherits from VideoLinkShell.EditView)


   * **vimeo.shell.js**
      * **VimeoShell** - renders vimeo videos (VideoLinkShell)
         * **ContentView** - (inherits from VideoLinkShell.ContentView)
         * **EditView** - (inherits from VideoLinkShell.EditView)


   * **pdf.shell.js**
      * **PDFShell** - renders pdf documents (LinkShell)
         * **EditView** - (inherits from LinkShell.EditView)


   * **multi.shell.js**
      * **MultiShell** - group of subshells (inherits from Shell)
         * **ContentView** - (inherits from Shell.ContentView)
         * **PlaylistView** - (inherits from Shell.ShellView)
         * **EditView** - (inherits from Shell.EditView)





##### acorn.js

[acorn.js](/athenalabs/acorn-player/blob/master/js/src/acorn.js) defines and
implements the base acorn model and top level API. See [Acorn Data Model](#acorn-data-model) above.

Outside of the acorn data model,
[acorn.js](/athenalabs/acorn-player/blob/master/js/src/acorn.js) includes a
slew of utility functions (under acorn.util.*) that facilitate programatic
interaction with acorns.

##### acorn.player.js
[acorn.player.js](/athenalabs/acorn-player/blob/master/js/src/acorn.player.js)
defines the acorn.player object. See [Acorn Player](#acorn-player) above.

##### shell.js
[shells.js](/athenalabs/acorn-player/blob/master/js/src/shells/shell.js) is
the abstract, top-level shell object from which all other shells inherit. It
defines the base shell API as well as the base functionality for all shell
views.

##### empty.shell.js
[empty.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/empty.shell.js) is the simplest example of a shell implementation. It
simply implements the rendering of a shell that has no content. At the moment,
the shell simply displays a message along the lines of "This acorn is
currently empty. Visit acorn.athena.ai for more acorns."

##### link.shell.js
[link.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/link.shell.js)
is a shell that wraps the content of an arbitrary link whose content-type is
not specifically supported by acorn. The link destination will simply be
embedded as an iframe by the shell. It inherits from
[shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/shell.js).

##### imagelink.shell.js
[imagelink.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/imagelink.shell.js)
is a shell implementation that wraps any image type (formats currently
supported: *.{jpg,gif,png,svg}) by embedding it into an HTML image tag in the
render function of the shell's ContentView.

##### videolink.shell.js
[videolink.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/videolink.shell.js)
is the abstract shell from which all video shells (like the YouTube and Vimeo
shells) derive.

##### youtube.shell.js
[youtube.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/youtube.shell.js)
is a shell that wraps a YouTube video. It inherits from
[videolink.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/videolink.shell.js).

##### vimeo.shell.js
[vimeo.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/vimeo.shell.js)
is a shell that wraps a Vimeo video. It inherits from
[videolink.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/videolink.shell.js).

##### pdf.shell.js
[pdf.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/pdf.shell.js)
is a shell that wraps a PDF document by loading it in an iframe. It inherits
from
[link.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/link.shell.js).

##### multi.shell.js
[multi.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/multi.shell.js)
is a shell implementation that wraps multiple child shells of any type. A
MultiShell can be thought of as a playlist. It inherits from
[shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/shell.js).
