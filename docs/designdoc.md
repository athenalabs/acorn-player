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

* **player**: web technology that enables viewing/consuming of media pieces.

* **native-player**: web technology of a particular vendor, to be used to play
  media pieces hosted by the vendor

  (e.g. YouTube Embedded Player, Vimeo Player).

* **acorn**: a remix combining media pieces through the use of computation.

* **``acorn-player``**: a player that plays acorns


* **shell**: an ``acorn-player`` module to play and edit specific media kinds.

  (e.g. ``ImageLinkShell``, ``YouTubeShell``).



### Description

``acorn-player`` is a web technology that enables playing and remixing
different kinds of media in a unified way.

``acorn-player`` enables:
* playing media pieces of various kinds
* composing remixes
* embedding in webpages

#### Playing Media Pieces

``acorn-player`` aims to be a player that can play all kinds of different media
pieces, of various kinds and from various vendors. For example, it should be
able to:

* show videos, music, images, text, documents, etc.
* more specifically, show YouTube Videos, Vimeo Videos, image files, sound
  files, Flash games, PDF files, etc.
* and show compositions of these, such as playlists, galleries, slideshows,
  spliced videos, etc.

Thus, ``acorn-player`` should have a very general approach to interacting with
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


``acorn`` aims to enable remixing one or multiple media pieces (of different
kinds) into a new media piece. ``acorn-player`` allows this remixing via
a composition or editing interface, that is specific to the media kind.

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

``acorn-player`` aims to allow diverse kinds of media to be embeddable into
webpages, in a uniform fasion. Being embeddable itself, then, allows users and
developers both to compose acorns out of the media they wish to embed. Users
may use the player interface and developers could do it programmatically, yet
the end is the same: easily embedding various sorts of media in the same way.

**Historical Note**: developing wrappers to embed various kinds of media is a
particular painpoint for any developer wishing to build a website that enables
its users to submit arbitrary media. This pain is actually what motivated the
original conception of acorn. @jbenet sought for a uniform library that could
handle embedding all kinds of media links uniformly. Subsequently, the
remixing power afforded by introducing this computing layer of indirection
became apparent.

``acorn-player`` ought to be embeddable across the web, much like the YouTube
and Vimeo players. It should load quickly, regardless of underlying media type.
Further, it should behave in a manner expected by current web-denizens. These
requirements motivate the use of an iframe, first showing a thumbnail, with the
actual content loaded behind the scenes and swapped into view once the user
engages with the media (click!).

embedded ``acorn-player``:

![embedded-acorn-player](https://img.skitch.com/20120911-ewk57srmfynjiwkhhyfgfxx884.png)


In order to provide information regarding the primitive type of the media to
the viewer, the thumbnail should be overlaid with an icon that conveys the kind
of media.

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

### Codebase

#### File Hierarchy:

    js/src/
    ├── acorn.js
    ├── acorn.player.js
    └── shells
        ├── empty.shell.js
        ├── imagelink.shell.js
        ├── link.shell.js
        ├── multi.shell.js
        ├── pdf.shell.js
        ├── shell.js
        ├── videolink.shell.js
        ├── vimeo.shell.js
        └── youtube.shell.js


#### Code Hierarchy

##### acorn.js
[acorn.js](/athenalabs/acorn-player/blob/master/js/src/acorn.js) defines and
implements the base acorn model and top level API. First and foremost, the
acorn model includes basic operations common to all acorns including (but not
limited to) ways to construct acorns from URLs to media or preexisting acorn
data objects. Second, it provides useful accessors to the acorn data to fields
like the acornid. Third, it provides utility methods for the JSON
serialization and deserialization of acorns. Fourth, it includes preliminary
support for integration of acorn with a backend of your choice.

Outside of the acorn data model, [acorn.js](/athenalabs/acorn-player/blob/master/js/src/acorn.js) includes a
slew of utility functions (under acorn.util.*) that facilitate programatic
interaction with acorns.


##### acorn.player.js
[acorn.player.js](/athenalabs/acorn-player/blob/master/js/src/acorn.player.js)
defines the acorn.player object. The acorn.player object encapsulates all
the views (deriving from Backbone.View) that are needed to create the user 
experience and behavior outlined in the overview section above. The model behind those views is provided by [acorn.js](/athenalabs/acorn-player/blob/master/js/src/acorn.js).

At a high level, acorn.player comprises four primary views (among several other subsidiary views):

* PlayerView - the main acorn player view.
  The PlayerView object provides abstracts away the following behaviors:
  * initialization of the acorn's data model and Backbone view hierarchy
  * adequate event firing whenever the user interacts with the acorn at the
    player level (e.g. the acorn is renamed, changed, or saved).
  * player rendering logic; note that the content of the acorn is rendered by
    the implementation of the acorn shell for said content type.
* ControlsView - the view containing media control buttons. The ControlsView 
  provides the control buttons that all acorns share (namely, 
  FullscreenControl, AcornControl, and EditControl). Shells can extend that 
  list of controls with their own, special purpose buttons.
* ContentView - the parent view for each shells' main content view. Each
  shell's ContentView derives from this top-level ContentView and implements
  the rendering logic for the shell's own content-type.
* EditView - the parent view for all shells' edit views. Each
  shell's EditView derives from this top-level EditView and implements
  the rendering logic for the shell's own edit mode.


##### empty.shell.js
##### imagelink.shell.js
##### link.shell.js
##### multi.shell.js
##### pdf.shell.js
##### shell.js
##### videolink.shell.js
##### vimeo.shell.js
##### youtube.shell.js

