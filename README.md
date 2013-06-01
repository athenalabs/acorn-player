# acorn-player

## about


`acorn-player` is a media player that plays
[acorns](http://acorn.athena.ai/about), web media remixes expressed in JSON.
`acorn-player` is used by [Acorn](http://acorn.athena.ai), a
web-service that hosts and displays acorns.



![](http://static.benet.ai/skitch/acorn_%7C_Media_Remixer-20130427-055341.png)

Acorn is great for all sorts of media-related things, like:
* remixing
* clipping
* looping
* playlists
* galleries
* versioning (soon)
* annotating (soon)
* scoping comments (soon)

Check out the project's github page:
http://github.com/athenalabs/acorn-player


### authors

``acorn-player`` was written by [Athena](http://github.com/athenalabs) members:

* [Juan Batiz-Benet](http://github.com/jbenet)
* [Ali Yahya](http://github.com/ali01)
* [Daniel Windham](http://github.com/tenedor)


### contact

Please report issues and provide feedback on the github issues page:
http://github.com/athenalabs/acorn-player/issues

Pull-requests welcome!

## Development

To develop ``acorn-player``, you need to:

Download the source:

    git clone git@github.com:athenalabs/acorn-player.git

Initialize the Closure submodule:

    git submodule update
    git submodule init

Create the necessary symlinks:

    ln -s Gruntfile.coffee Grunt.js
    ln -s <path to compiler.jar> lib/closure/

Build it:

    npm install
    node_modules/grunt-exec/bin/grunt-exec compile

Run a server with the following command:

    cd acorn-player
    python -m  SimpleHTTPServer

See it at [http://localhost:8000/static/player.html](http://localhost:8000/static/player.html)

Note: Node v0.10.4 gives errors when used with our version of Grunt. The
highest supported version of Node is 0.8.16. Instructions on installing older
versions of Node via ``brew`` are available
[here](http://stackoverflow.com/a/9832084).

## Usage


`acorn-player` can be added to any webpage to play acorns, whether that acorn
is loaded from the Acorn service (using an `acornid`), or from acorn data
directly (using the JSON representation).

Beyond playing acorns, `acorn-player` is a great tool to embed all sorts of
media on webpages. It features support for diverse kinds: video, text,
pdfs, images, etc. It also has the full power of all acorns, allowing remixing
and combining the media. In fact, this use gave birth to all of `acorn`: we
wanted a library that could translate any link into the proper embeded media.

To use ``acorn-player``, you need to

* include `acorn.player.min.js` and `acorn.player.css`
* create an `acorn` for the media you want to play (via acorn service or just the raw JSON data)
* tell the `acorn-player` to play the `acorn` (via acornid or data).


### Code examples


#### constructing, loading, and saving acorn models

```javascript
// construct new acorn with any link
var acornModel = acorn('http://www.youtube.com/watch?v=CbIZU8cQWXc');

// construct new acorn via data (equivalent to above)
acornModel = acorn({
  "acornid": "new",
  "shell": {
    "shell": "acorn.YouTubeShell",
    "link": "http://www.youtube.com/watch?v=CbIZU8cQWXc",
  },
});

// save acorn to the acorn service
acornModel.save();

// load acorn stored in the acorn service
acornModel = acorn('nyfskeqlyx');
acornModel.fetch({
  success: function() {
    // acornModel finished loading.
  }
});
```

#### construct + play player

```javascript
// with given acorn model
var player = new acorn.player.Player({ model: acornModel });

// with given acorn model
player = new acorn.player.Player({ data: 'nyfskeqlyx' });
player.model.fetch();

// with given acorn model
link = 'http://www.youtube.com/watch?v=CbIZU8cQWXc';
player = new acorn.player.Player({ data: link });

// append player to selector
player.appendTo('body');
```


## Shells

`acorn-player` uses a set of modules dubbed **shells** to support:
* typed of media
* remixing and editing
* playlists and other groupings

Shells are self-contained modules that tell `acorn-player` how to render a
particular type of `acorn`, and how to edit the data with in that `acorn`.

See [docs/shells.md](https://github.com/athenalabs/acorn-player/blob/master/docs/shells.md).
