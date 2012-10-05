
// acorn.shells.PDFLinkShell
// ----------------------
var PDFLinkShell = acorn.shells.PDFLinkShell = LinkShell.extend({

  shellid: 'acorn.PDFLinkShell',

  // The canonical type of this media. One of `acorn.types`.
  type: 'document',

  // **validRegexes** regex to match links to PDFs
  validRegexes: [
    urlRegExp('.*\.pdf'),
  ],

});

// EditView -- pdf link, and generates thumbnail link.
// ---------------------------------------------------

PDFLinkShell.EditView =  LinkShell.EditView.extend({

  // Overrides LinkShell.generateThumbnailLink()
  generateThumbnailLink: function(callback) {
    callback = callback || function() {};
    callback('/img/icons/pdf.png');
  },

});


// Register the shell with the acorn object.
acorn.registerShell(PDFLinkShell);
