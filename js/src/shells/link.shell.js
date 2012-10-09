
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

  var location = parseUrl(link);

  // filter out shells that don't derive from LinkShell.
  var linkShells = _(acorn.shells).filter(function (shell) {
    return derives(shell, acorn.shells.LinkShell);
  });

  // filter out shells that don't match this link.
  var matchingShells = _(linkShells).filter(function (linkShell) {
    return linkShell.prototype.isValidLink(location);
  });

  // reduce to the most specific shell (in terms of inheritance).
  var bestShell = _(matchingShells).reduce(function(bestShell, shell) {
    return derives(bestShell, shell) ? bestShell : shell;
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

  // **thumbnailLink** returns the link to the thumbnail image
  thumbnailLink: function(link) {
    if (link !== undefined)
      this.data.thumbnailLink = link;
    return this.data.thumbnailLink;
  },

  metaDataLink: function() { return ''; },

  // Retrieve extra information. Nothing by default.
  retrieveMetaData: function(callback) {
    callback = callback || function() {};

    var metaDataLink = this.metaDataLink();
    if (!metaDataLink || this.metaData) {
      return callback();
    }

    var self = this;
    $.getJSON(metaDataLink, function(data) {
      self.metaData = data;
      callback();
    });
  },

};

_.extend(LinkShellAPI, LinkValidationInterface);



// acorn.shells.LinkShell -- a shell that links to media and embeds it.
// --------------------------------------------------------------------

var LinkShell = acorn.shells.LinkShell = Shell.extend(LinkShellAPI);


// ContentView -- Simply displays the link text for now.
// TODO: thumbnail the website? embed the webpage in iframe?
// ---------------------------------------------------------

LinkShell.ContentView = Shell.ContentView.extend({

  initialize: function() {
    Shell.ContentView.prototype.initialize.call(this);

    assert(this.shell.link, 'No link provided to LinkShell.');

    this.location = this.options.location || parseUrl(this.shell.link());

    assert(this.shell.isValidLink(this.location),
      'Link provided does not match ' + this.shell.type);

  },

  render: function() {
    var link = this.shell.link();
    this.$el.append(iframe(link, 'link-iframe'));
  },

});



// LinkShell.EditView -- a text field for the link.
// --------------------------------------------------

LinkShell.EditView = Shell.EditView.extend({

  events: {
    'click button#add': 'onClickAdd',
  },

  template: _.template('\
    <div>\
      <img id="thumbnail" />\
      <div class="thumbnailside">\
        <div id="link"></div>\
      </div>\
    </div>\
    <button class="btn btn-large" id="add">Add Link</button>\
  '),

  initialize: function() {
    Shell.EditView.prototype.initialize.call(this);

    this.linkView = new Backbone.components.EditableTextCmp.View({
      textFn: this.link,
      placeholder: 'Enter Link',
      validate: _.bind(this.validateLink, this),
      addToggle: true,
      deleteFn: _.bind(this.triggerDelete, this),
    });

    this.on('delete:shell', this.onDeleteShell);

  },

  validateLink: function(link) {
    parsedLink = parseUrl(link).toString();
    if (acorn.util.isValidLink(parsedLink) || link === '')
      return false;

    return "invalid link."
  },

  link: function(link) {
    if (link || link === '') {
      link = link === '' ? '' : parseUrl(link).toString();
      this.shell.link(link);
      var s = acorn.shellForLink(link, {shell: this.shell});

      // if the shellid has changed, we need to swap shells entirely.
      if (s.shellid != this.shell.data.shell)
        this.trigger('swap:shell', s.data);

      // else, announce that the shell has changed.
      else
        this.trigger('change:shell', this.shell);
    }
    return this.shell.link();
  },

  render: function() {
    Shell.EditView.prototype.render.call(this);

    // set thumbnail src
    var tlink = this.shell.thumbnailLink();
    this.$el.find('#thumbnail').attr('src', tlink);

    this.linkView.setElement(this.$el.find('#link'));
    this.linkView.render();

    if (!this.link())
      this.linkView.edit();

    if (this.isSubShellView())
      this.$el.find('button#add').hide();
  },

  triggerDelete: function() {
    this.trigger('delete:shell');
  },

  onDeleteShell: function() {
    if (!this.isSubShellView()) {
      this.link('');
    };
  },

  generateThumbnailLink: function(callback) {
    callback = callback || function() {};

    var self = this;
    var bounds = '600x600';
    var req_url = '/url2png/' + bounds + '/' + this.shell.link();
    $.ajax(req_url, {
      success: function(data) {
        callback(data);
      },
      error: function() {
        acorn.alert('Error: failed to generate thumbnail for link.',
                    'alert-error');
      }
    });
  },

  // **finalizeEdit** finish all edits.
  finalizeEdit: function() {
    if (this.linkView.isEditing)
      this.linkView.save();
  },

  // **onClickAdd** add another link
  onClickAdd: function() {
    // save unsaved edits and beget a multishell
    this.finalizeEdit();
    var multiShell = new acorn.shells.MultiShell();
    multiShell.addShell(this.shell);
    multiShell.addShell(new acorn.shellForLink(''));
    this.trigger('swap:shell', multiShell.data);
  },


});


// Register the shell with the acorn object.
acorn.registerShell(LinkShell);
