# Shells

An acorn shell is an implementation of acorn's wrapping functionality for a single type of media. Said type can can be anything from an image or PDF to a YouTube video. A shell can even wrap a collection (or a playlist) of child shells, as with MultiShell.

Each shell is implemented as an independent module where the shell object in question ultimately inherits from acorn.shells.Shell (defined in [shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/shell.js)). The inheritance hierarchy of the shells currently supported is the following:

[acorn.shells.*](/athenalabs/acorn-player/tree/master/js/src/shells):
* Shell
  * EmptyShell
  * LinkShell
    * ImageLinkShell
    * VideoLinkShell
      * YouTubeShell
      * VimeoShell
    * PDFShell
  * MultiShell



## Shell
Shell (defined in [shells.js](/athenalabs/acorn-player/blob/master/js/src/shells/shell.js)) is the abstract, top-level shell object from which all other shells inherit. It defines the base shell API as well as the base functionality for all shell views.



## EmptyShell
EmptyShell (defined in [empty.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/empty.shell.js)) is a shell that contains no media. An acorn's type is EmptyShell initially before any media has been added, or can become EmptyShell if all of its media is removed.

### Source
#### Data Model Example
    var acornModel = acorn.withData({
      "acornid": "local",
      "shell": {
        "shell": "acorn.EmptyShell",
      },
    });

#### Full  Example
[acorn-player/examples/example.emptyshell.html](/athenalabs/acorn-player/blob/master/examples/example.emptyshell.html)



## LinkShell
LinkShell (defined in [link.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/link.shell.js)) is a shell that wraps the content of an arbitrary link whose content-type is not specifically supported by acorn. The link destination will simply be embedded as an iframe by the shell.

### Content
![link-shell](http://static.enrage.me/athena/test.link.shell.png)

### Source
#### Data Model Example
    var acornModel = acorn.withData({
      "acornid": "local",
      "shell": {
        "shell": "acorn.LinkShell",
        "link": "http://wikipedia.org",
      },
    });

#### Full  Example
[acorn-player/examples/example.linkshell.html](/athenalabs/acorn-player/blob/master/examples/example.linkshell.html)



## ImageLinkShell
ImageLinkShell (defined in [imagelink.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/imagelink.shell.js)) is a shell that wraps any image type (formats currently supported: .{jpg,gif,png,svg}).

### Content
![image-shell](http://static.enrage.me/athena/test.image.shell.png)

### Source
#### Data Model Example
    var acornModel = acorn.withData({
      "acornid": "local",
      "shell": {
        "shell": "acorn.ImageLinkShell",
        "link": "https://img.skitch.com/20120908-fhtwhbya7c1grtssq73aisymwr.png",
        "thumbnailLink":
          "https://img.skitch.com/20120908-fhtwhbya7c1grtssq73aisymwr.png",
      },
    });

#### Full  Example
[acorn-player/examples/example.imagelinkshell.html](/athenalabs/acorn-player/blob/master/examples/example.imagelinkshell.html)



## PDFShell
PDFShell (defined in [pdf.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/pdf.shell.js)) is a shell that wraps a PDF document.

### Content
![image-shell](http://static.enrage.me/athena/test.pdf.shell.png)

### Source
#### Data Model Example
    var acornModel = acorn.withData({
      "acornid": "local",
      "shell": {
        "shell": "acorn.PDFLinkShell",
        "link": "http://static.juanbb.com/datastore.pdf",
        "thumbnailLink":
          "https://img.skitch.com/20120908-m37865ekjmxb9pxgfwj5jxq34b.png",
      },
    });

#### Full  Example
[acorn-player/examples/example.pdfshell.html](/athenalabs/acorn-player/blob/master/examples/example.pdfshell.html)



## VideoLinkShell
VideoLinkShell (defined in [videolink.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/videolink.shell.js)) is the abstract shell from which all video shells (like the YouTube and Vimeo shells) derive.



## YouTubeShell
YouTubeShell (defined in [youtube.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/youtube.shell.js)) is a shell that wraps a YouTube video.

### Content
![player-image](https://img.skitch.com/20120908-fcad4pqca1chdrrgr446q1euj7.png)

### Edit
![youtube-shell-edit](http://static.enrage.me/athena/test.youtube.shell.edit.png)

### Source
#### Data Model Example
    var acornModel = acorn.withData({
      "acornid": "local",
      "shell": {
        "shell": "acorn.YouTubeShell",
        "link": "http://www.youtube.com/watch?v=CbIZU8cQWXc",
        "time_start": 0,
        "time_end": 83,
        "loop": true,
      },
    });

#### Full  Example
[acorn-player/examples/example.youtubeshell.html](/athenalabs/acorn-player/tree/master/examples/example.youtubeshell.html)



## VimeoShell
VimeoShell (defined in [vimeo.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/vimeo.shell.js)) is a shell that wraps a Vimeo video.

### Content
![vimeo-shell](http://static.enrage.me/athena/test.vimeo.shell.png)

### Source
#### Data Model Example
    var acornModel = acorn.withData({
      "acornid": "local",
      "shell": {
        "shell": "acorn.VimeoShell",
        "link": "http://vimeo.com/17871870",
      },
    });

#### Full  Example
[acorn-player/examples/example.vimeoshell.html](/athenalabs/acorn-player/tree/master/examples/example.vimeoshell.html)



## MultiShell
MultiShell (defined in [multi.shell.js](/athenalabs/acorn-player/blob/master/js/src/shells/multi.shell.js)) is a shell that wraps multiple child shells of any type. A MultiShell can be thought of as a playlist.

### Content
![multi-shell](http://static.enrage.me/athena/test.multi.shell.png)

### Edit
![multi-shell-edit](http://static.enrage.me/athena/test.multi.shell.edit.png)

### Source
#### Data Model Example
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
            "shell": "acorn.ImageLinkShell",
            "thumbnailLink":
              "https://img.skitch.com/20120817-tuaw1jbgrstyeugsfb4bgwu6wi.png",
            "link":
              "https://img.skitch.com/20120817-tuaw1jbgrstyeugsfb4bgwu6wi.png"
          },
          {
            "shell": "acorn.ImageLinkShell",
            "thumbnailLink":
              "https://img.skitch.com/20120817-iimtd5kguy59rg3spw6c2gw6n.png",
            "link":
              "https://img.skitch.com/20120817-iimtd5kguy59rg3spw6c2gw6n.png"
          },
          {
            "shell": "acorn.ImageLinkShell",
            "thumbnailLink":
              "https://img.skitch.com/20120817-82gh54631tqaptmh449mgn6kct.png",
            "link":
              "https://img.skitch.com/20120817-82gh54631tqaptmh449mgn6kct.png"
          },
          {
            "shell": "acorn.ImageLinkShell",
            "thumbnailLink":
              "https://img.skitch.com/20120817-fta7cpsxsujdftuik6h29848pq.png",
            "link":
              "https://img.skitch.com/20120817-fta7cpsxsujdftuik6h29848pq.png"
          },
          {
            "shell": "acorn.ImageLinkShell",
            "thumbnailLink":
              "https://img.skitch.com/20120817-tgum22tuyeb1293mypyxkt7gsf.png",
            "link":
              "https://img.skitch.com/20120817-tgum22tuyeb1293mypyxkt7gsf.png"
          },
          {
            "shell": "acorn.ImageLinkShell",
            "thumbnailLink":
              "https://img.skitch.com/20120817-bes8y7ntahfi65si9u9pmakrms.png",
            "link":
              "https://img.skitch.com/20120817-bes8y7ntahfi65si9u9pmakrms.png"
          },
          {
            "shell": "acorn.ImageLinkShell",
            "thumbnailLink":
              "https://img.skitch.com/20120817-pq8yxbmq2ry93sswsjhrra8wrk.png",
            "link":
              "https://img.skitch.com/20120817-pq8yxbmq2ry93sswsjhrra8wrk.png"
          },
        ],
      },
    });

#### Full  Example
[acorn-player/examples/example.multishell.html](/athenalabs/acorn-player/blob/master/examples/example.multishell.html)
