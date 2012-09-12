// EmptyShell --  A shell that handles an empty acorn.
// ---------------------------------------------------
//
// * TODO: remove EmptyShell from LinkShell inheritance chain. For this to
//   happen, EditViews need to be refactored to accept non-LinkShells.

var EmptyShell = acorn.shells.EmptyShell = LinkShell.extend({

  shellid: 'acorn.EmptyShell',

  // The canonical type of this media. One of `acorn.types`.
  type: 'empty',

  // valid if link is empty
  isValidLink: function(link) {
    var emptyUrl = parseUrl('');
    var isEmpty = link.toString() === emptyUrl.toString();
    return isEmpty;
  },

});


// Shell.ContentView -- informs viewers that this acorn is currently empty
// -----------------------------------------------------------------------

EmptyShell.ContentView =  Shell.ContentView.extend({

  emptyMessage: function () {
    var messageText = 'this acorn is currently empty';
    var subText = 'visit <a href="acorn.athena.ai">acorn.athena.ai</a> for ' +
      'more acorns';
    var top = '</br></br></br></br></br></br></br></br>';
    var left = '&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp';
    var html = top+
               '<h1>'+left+left+left+messageText+'</h1>'+
               '<h2>'+left+left+left+left+left+subText+'</h2>';
    return html;
  },

  render: function() {
    this.$el.html(this.emptyMessage());
  },

});


// Register the shell with the acorn object.
acorn.registerShell(EmptyShell);
