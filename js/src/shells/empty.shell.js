(function() {

var LinkShell = acorn.shells.LinkShell;

// EmptyShell --  A shell that handles an empty link.
// ----------------------------------------------------------------

var EmptyShell = acorn.shells.EmptyShell = LinkShell.extend({

  shellid: 'acorn.EmptyShell',

  // The canonical type of this media. One of `acorn.types`.
  type: 'link', // TODO: type: 'empty'? something else?

  // valid if link is empty
  isValidLink: function(link) {
    var emptyUrl = acorn.util.parseUrl('');
    var isEmpty = link.toString() === emptyUrl.toString();
    return isEmpty;
  },

});


// Shell.ContentView -- informs viewers that this acorn is currently empty
// -----------------------------------------------------------------------

EmptyShell.ContentView = LinkShell.ContentView.extend({

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

}).call(this);