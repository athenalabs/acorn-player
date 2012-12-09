(function() {

// LinkRegExp -- Regular

// var LinkRegExp = RegExp(''
//   + '\b'                      // words
//   + '('                       // Capture 1: entire matched URL
//   +   '(?:'
//   +     'https?://'                   // http or https protocol
//   +     '|'                           // or
//   +     'www\d{0,3}[.]'               // "www.", "www1.", "www2." … "www999."
//   +     '|'                           // or
//   +     '[a-z0-9.\-]+[.][a-z]{2,4}/'  // domain name followed by a slash
//   +   ')'
//   +   '(?:'                       // One or more:
//   +     '[^\s()<>]+'                  // Run of non-space, non-()<>
//   +     '|'                           // or
//   +     '\(([^\s()<>]+|(\([^\s()<>]+\)))*\)' // balanced parens, up to 2 levels
//   +   ')+'
//   +   '(?:'                       // End with:
//   +     '\(([^\s()<>]+|(\([^\s()<>]+\)))*\)'  // balanced parens, up to 2 levels
//   +     '|'                               //   or
//   +     '[^\s`!()\[\]{};:\'".,<>?«»“”‘’]'  // not these punct chars
//   +   ')'
//   + ')',
//   'i'
// );
//

var Shell = acorn.shells.Shell;


var LinkRegExp =
  RegExp('https?://[-A-Za-z0-9+&@#/%?=~_()|!:,.;]*[-A-Za-z0-9+&@#/%=~_()|]',
   'i');


// LinkValidationInterface -- for determining whether links match.
// ---------------------------------------------------------------

var LinkValidationInterface = {

  // **validRegexes** list of valid LinkRegexes
  validRegexes: [
    LinkRegExp
  ],

  // urlMatches: returns whether a given url matches this Shell.
  // determined by the validRegexes above.
  urlMatches: function(url) {
    return _(this.validRegexes).find(function(re) {
      return re.test(url);
    });
  },

  isValidLink: function(link) {
    return !!this.urlMatches(link);
  },

};

acorn.util.isValidLink =
  _.bind(LinkValidationInterface.isValidLink, LinkValidationInterface);


// **acorn.shellForLink** returns a shell to match given link
// ----------------------------------------------------------

acorn.shellForLink = function(link, options) {

  var location = acorn.util.parseUrl(link);

  // filter out shells that don't derive from LinkShell.
  var linkShells = _(acorn.shells).filter(function (shell) {
    return acorn.util.derives(shell, acorn.shells.LinkShell);
  });

  // filter out shells that don't match this link.
  var matchingShells = _(linkShells).filter(function (linkShell) {
    return linkShell.prototype.isValidLink(location);
  });

  // reduce to the most specific shell (in terms of inheritance).
  var bestShell = _(matchingShells).reduce(function(bestShell, shell) {
    return acorn.util.derives(bestShell, shell) ? bestShell : shell;
  }, acorn.shells.LinkShell);

  // if all else fails, use LinkShell.
  bestShell = bestShell || acorn.shells.LinkShell;

  // setup options
  options = _.extend({}, options);
  options.data = {'link': link};
  options.location = location;

  return new bestShell(options);
};



// LinkShellAPI -- the interface _all_ link shells must support.
// -------------------------------------------------------------------

var LinkShellAPI = {

  shellid: 'acorn.LinkShell',

  // The canonical type of this media. One of `acorn.types`.
  type: 'link',

  // **link** is the main data kept by LinkShells
  link: function(link) {
    if (link !== undefined)
      this.data.link = link;
    return this.data.link;
  },

  // **title** returns a simple title of the shell
  title: function() { return this.link(); },

  // **description** returns a simple description of the shell
  description: function() { return ''; },

  // **thumbnailLink** returns a remoteResource object whose data() function
  // caches and returns this LinkShell's thumbnail link.
  thumbnailLink: function thumbnailLink() {
    if (this._tlink && this._tlink.url()) {
      // if the thumbnail exists and is pointing to a valid URL, return it
      return this._tlink;
    };

    var bounds = '600x600';
    var shellLink = this.link(); // link this LinkShell is pointing to

    if (!thumbnailLink.url && shellLink) {
      // thumbnailLink.url can be overriden by derived objects
      thumbnailLink.url = '/url2png/' + bounds + '/' + shellLink;
    };

    if (thumbnailLink.url) {
      this._tlink = common.remoteResource({
        url: thumbnailLink.url,
      });

    } else {
      // stub remoteResource object without a valid URL
      this._tlink = common.remoteResourceInterface();
    };

    return this._tlink;
  },

  // **metaData** returns a remoteResource object whose data() function
  // caches and returns this LinkShell's associated metadata.
  metaData: function() {
    // url property to be set by derived classes of LinkShell
    var url = this.metaDataUrl; // currently undefined

    if (url && !this._metaData) {
      this._metaData = common.remoteResource({
        url: url,
        dataType: 'json',
      });
    };

    return this._metaData;
  },

};

_.extend(LinkShellAPI, LinkValidationInterface);



// acorn.shells.LinkShell -- a shell that links to media and embeds it.
// --------------------------------------------------------------------

var LinkShell = acorn.shells.LinkShell = Shell.extend(LinkShellAPI);


// ContentView -- Simply displays the link text for now.
// -----------------------------------------------------

LinkShell.ContentView = Shell.ContentView.extend({

  initialize: function() {
    Shell.ContentView.prototype.initialize.call(this);

    acorn.util.assert(this.shell.link, 'No link provided to LinkShell.');

    this.location = this.options.location ||
                    acorn.util.parseUrl(this.shell.link());

    acorn.util.assert(this.shell.isValidLink(this.location),
      'Link provided does not match ' + this.shell.type);

  },

  render: function() {
    var link = this.shell.link();
    this.$el.append(acorn.util.iframe(link, 'link-iframe'));
  },

});


// LinkShell.EditView -- a text field for the link.
// --------------------------------------------------

LinkShell.EditView = Shell.EditView.extend({

  events: {
    'focus input#link' : 'onFocusLinkField',
    'blur input#link' : 'onBlurLinkField',
    'keyup input#link' : 'onKeyupLinkField',
    'click button#delete' : 'onClickDelete',
    'click button#duplicate' : 'onClickDuplicate',
    'click button#add': 'onClickAdd',
  },

  template: _.template('\
    <div>\
      <img id="thumbnail" />\
      <div class="thumbnailside">\
        <div id="link-field">\
          <input type="text" id="link" placeholder="Enter Link" />\
          <button class="btn" id="delete">delete</button>\
          <button class="btn" id="duplicate">duplicate</button>\
        </div>\
      </div>\
    </div>\
    <button class="btn btn-large" id="add">Add Link</button>\
  '),

  initialize: function() {
    Shell.EditView.prototype.initialize.call(this);

    this.on('delete:shell', this.onDeleteShell);
    this.on('save:link', this.onSaveLink);
  },

  validateLink: function(link) {
    parsedLink = acorn.util.parseUrl(link).toString();
    if (acorn.util.isValidLink(parsedLink) || link === '')
      return false;

    return "invalid link."
  },

  link: function(link) {
    if (link || link === '') {
      link = link === '' ? '' : acorn.util.parseUrl(link).toString();
      this.shell.link(link);
      var s = acorn.shellForLink(link, {shell: this.shell});

      // if the shellid has changed, we need to swap shells entirely.
      if (s.shellid != this.shell.data.shell)
        this.trigger('swap:shell', s.data, this);

      // else, announce that the shell has changed.
      else
        this.trigger('change:shell', this.shell, this);
    }
    return this.shell.link();
  },

  render: function() {
    Shell.EditView.prototype.render.call(this);

    // set link field value
    this.$('input#link').val(this.link());

    // set thumbnail src
    var thumbnailLink = this.shell.thumbnailLink();
    thumbnailLink.sync({
      success: _.bind(function(thumbnailLink) {
        this.$el.find('#thumbnail').attr('src', thumbnailLink);
      }, this)
    });

    if (this.isSubShellView())
      this.$el.find('button#add').hide();
  },

  onFocusLinkField: function() {
    this.trigger('edit:link');
  },

  onBlurLinkField: function() {
    this.trigger('save:link');
  },

  onKeyupLinkField: function(e) {
    var ENTER = 13, ESC = 27;

    switch(e.keyCode) {
      case ENTER:
        this.onEnterLinkField();
        break;
      case ESC:
        this.onEscapeLinkField();
        break;
    };
  },

  onEnterLinkField: function() {
    this.$('input#link').blur();
  },

  onEscapeLinkField: function() {
    // reset previous value
    this.$('input#link').val(this.link());
    this.$('input#link').blur();
  },

  onSaveLink: function() {
    var value = this.$('input#link').val();

    if (this.validateLink(value))
      console.log('invalid link');

    this.link(value);
  },

  onDeleteShell: function() {
    if (!this.isSubShellView()) {
      this.link('');
    };
  },

  onClickDelete: function() {
    this.trigger('delete:shell', this);
  },

  onClickDuplicate: function() {
    this.trigger('duplicate:shell', this);
  },

  // **onClickAdd** add another link
  onClickAdd: function() {
    // save unsaved edits and beget a multishell
    this.finalizeEdit();
    var multiShell = new acorn.shells.MultiShell();
    multiShell.addShell(this.shell);
    multiShell.addShell(new acorn.shellForLink(''));
    this.trigger('swap:shell', multiShell.data, this);
  },

});


// Register the shell with the acorn object.
acorn.registerShell(LinkShell);

}).call(this);
