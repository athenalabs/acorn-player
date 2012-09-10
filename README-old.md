# acorn-player


## about

``acorn-player`` is the embedded-player in use by acorn.

``[acorn](http://staging.acorn.athena.ai)`` is a universal media wrapper.

![player-image](https://img.skitch.com/20120908-fcad4pqca1chdrrgr446q1euj7.png)

It's great for:
* sharing media
* remixing media
* clipping videos
* playlists
* galleries (soon)
* versioning media (soon)
* scoping comments (soon)
* annotating media (soon)


### the x for y

`acorn` is like [gist](http://gist.github.com) for _everything_.

### authors

Acorn was written by [Athena](http://github.com/athenalabs) members:
* [Juan Batiz-Benet](http://github.com/jbenet)
* [Ali Yahya](http://github.com/ali01)
* [Daniel Windham](http://github.com/tenedor)

Special Thanks to
[Tomcat](http://github.com/TomcatEsq) and
[TomKitten](http://github.com/TomKitten).

### contributors

### repository

Check out the project's github page:
http://github.com/athenalabs/acorn-player

Pull-requests welcome!

### issues

Please report issues on the github issues page:
http://github.com/athenalabs/acorn-player/issues


## Development Setup


### Download the source:

    git clone git@github.com:athenalabs/acorn-player.git

### Run the server:

Run the following command:

    cd acorn-player
    python server.py


See it:

    http://localhost:8000/


## Usage

Go to http://staging.acorn.athena.ai for acorn.

### posting media

You can post media through the acorn website,
[acorn.athena.ai](http://acorn.athena.ai),
or through any website that embeds the new acorn player.

To embed the new acorn player, use:

    <iframe id="acorn-player-frame"
    src="http://staging.acorn.athena.ai/player/new"
    frameborder="0" border="0" width="600" height="400" scrolling="no"
    allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true"
    ></iframe>

### viewing media

Once posted, the media gets a unique url. You can visit the url directly in
any web-browser:

    http://staging.acorn.athena.ai/{acorn id}

or you can embed the media (see below).


### embedding media

Use:

    <iframe id="acorn-player-frame"
    src="http://staging.acorn.athena.ai/player/{acorn id}"
    frameborder="0" border="0" width="600" height="400" scrolling="no"
    allowfullscreen="true" webkitallowfullscreen="true" mozallowfullscreen="true"
    ></iframe>

wherever you want the media to appear.


