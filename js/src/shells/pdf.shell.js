
// acorn.shells.PDFLinkShell
// ----------------------
var PDFLinkShell = acorn.shells.PDFLinkShell = LinkShell.extend({

  shellid: 'acorn.PDFLinkShell',

  // The canonical type of this media. One of `acorn.types`.
  type: 'document',

  // **thumbnailLink** returns a remoteResource object whose data() function
  // caches and returns this PDFShell's thumbnail link.
  thumbnailLink: function() {
    // PDFShell thumbnail links are static for now.
    // The return-type of thumbnailLink functions is typically a remoteResource
    // object. This function returns an object that behaves as if it were of
    // type remoteResource, but that simply returns the static URL instead of
    // making an AJAX request to obtain it.
    var remoteResource = common.remoteResourceInterface();
    _.extend(remoteResource, {
      data: function() {
        return acorn.util.imgurl('icons/pdf.png');
      },
    });

    return remoteResource;
  },

  // **validRegexes** regex to match links to PDFs
  validRegexes: [
    urlRegExp('.*\.pdf'),
  ],

});

// Register the shell with the acorn object.
acorn.registerShell(PDFLinkShell);
