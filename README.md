# acorn-player

## about


``acorn-player`` is the embedded-player in use by acorn.
[Acorn](http://staging.acorn.athena.ai) is a universal media wrapper.

![player-image](https://img.skitch.com/20120908-fcad4pqca1chdrrgr446q1euj7.png)

It's great for all sorts of media-related things, like:
* sharing
* remixing
* clipping
* looping
* playlists
* galleries (soon)
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

#### contributors
* [Tomcat](http://github.com/TomcatEsq)
* [TomKitten](http://github.com/TomKitten)


### contact

Please report issues and provide feedback on the github issues page:
http://github.com/athenalabs/acorn-player/issues

Pull-requests welcome!

## Development

To develop ``acorn-player`, you need to:

### download source

    git clone git@github.com:athenalabs/acorn-player.git

### run server

Run the following command:

    cd acorn-player
    python server.py 8000

See it at http://localhost:8000/

### design doc

Read the [designdoc](doc/designdoc.md).

## Usage

``acorn-player`` is a great tool to embed all sorts of media on webpages.
It features support for diverse kinds of media: video, text, pdfs, images,
etc. Beyond that, it allows remixing and playlisting these media.

Currently, ``acorn-player`` only supports **linked media**, media hosted on
other websites, accessible via link (e.g. a youtube video).

To use ``acorn-player``, you need to

* include ``acorn-player`` in an iframe.
* create an ``acorn`` for the media you want to play.
* tell the ``acorn-player`` to play the ``acorn``.

### Include ``acorn-player`` in ``iframe``

``acorn-player`` should be included into your html page in an ``iframe``. You
can either:


* construct the iframe yourself:

        <iframe id="player"
        frameborder="0" border="0" allowtransparency="true"
        allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true"
        src="http://localhost:8000/player/"></iframe>


* construct the iframe using ``acorn.util.iframe``:

        var iframe = acorn.util.iframe('http://localhost:8000/player/');
        $('body').append(iframe);



### Create Acorn

An ``acorn`` is just an object with some meta-data that tells the
``acorn-player`` what media to show, and how to do it. Acorns are either:

* stored in a server
(like [acorn.athena.ai](http://staging.acorn.athena.ai))

        var acornModel = acorn('nyfskeqlyx');
        acornModel.fetch({
          success: function() {
            // acornModel finished loading.
          }
        });

* stored directly in your code
(see [examples/example.youtubeshell.html](examples/example.youtubeshell.html))

        var acornModel = acorn.withData({
          "acornid": "local",
          "shell": {
            "shell": "acorn.YouTubeShell",
            "link": "http://www.youtube.com/watch?v=CbIZU8cQWXc",
          },
        });


### Play ``acorn`` in ``acorn-player``

The remaining thing to so is to play the ``acorn`` in the ``acorn-player``
loaded in the ``iframe``:

    acorn.playInFrame(acornModel, iframe);


### Full Example:

Assuming you're running the server, here is a full example in javascript:

    var iframe = acorn.util.iframe('http://localhost:8000/player/');
    $('body').append(iframe);

    var acornModel = acorn.withData({
      "acornid": "local",
      "shell": {
        "shell": "acorn.YouTubeShell",
        "link": "http://www.youtube.com/watch?v=CbIZU8cQWXc",
      },
    });

    acorn.playInFrame(acornModel, iframe);



### Shells

``acorn-player`` uses a set of modules dubbed **shells** to support:
* media of various types
* playlists of various types
* remixing in various ways

Shells are self-contained modules that tell ``acorn-player`` how to render a
particular ``acorn``, and how to edit the data with the ``acorn``.

See [doc/shells.md](doc/shells.md).
