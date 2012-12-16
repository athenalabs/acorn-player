goog.provide 'acorn.shells.LinkShell'

goog.require 'acorn.Model'
goog.require 'acorn.shells.Shell'
goog.require 'acorn.shells.Registry'
goog.require 'acorn.errors'
goog.require 'acorn.util'

Shell = acorn.shells.Shell
LinkShell = acorn.shells.LinkShell =

  # -- module properties --
  # Properties in this section should be overriden by all
  # shell modules based on LinkShell

  id: 'acorn.LinkShell'
  title: 'LinkShell'
  description: 'Base shell to contain any web based URL.'
  icon: 'icon-link'

  # This property lists the set of regular expression patterns
  # that LinkShell matches. It should be extended or overriden
  # in shells that inherit from LinkShell.
  validLinkPatterns: [ acorn.util.LINK_REGEX ]


  # -- module level functions --
  # Functions in this section are useful in dealing with
  # shells based on LinkShell

  # Returns true if `link` matches pattern contained in array
  # `validLinkPatterns`
  # Returns false otherwise
  linkMatches: (link, validLinkPatterns) ->
    (_.find validLinkPatterns, (pattern) -> pattern.test link)?

  # Returns the set of LinkShell modules that match `link`
  # A LinkShell module matches a link whenever it conforms to
  # one or more  the patterns in that modules's top-level
  # `validLinkPatterns` array property.
  matchingShells: (link) ->
    unless link?
      return LinkShell

    # parse link into a location object
    location = acorn.util.parseUrl link

    # filter out shell modules that don't derive from LinkShell
    shells = _.filter acorn.shells, (shell) ->
      acorn.util.derives shell.Model, LinkShell.Model

    # filter out shells that don't match this link
    shells = _.filter shells, (shell) ->
      @linkMatches link, shell.validLinkPatterns

    # if all else fails, use LinkShell
    if shells.length == 0
      shells[0] = LinkShell

    shells

  # From the set of shells returned by matchingShells(),
  # this function returns the most specific one in the
  # inheritence hierarchy.
  bestMatchingShell: (link) ->
    # obtain set of matching shells
    matchingShells = @matchingShells link

    # reduce function to get the most specific shell (in terms of inheritance)
    reduceFn = (bestShell, shell) ->
      if acorn.util.derives bestShell.Model, shell.Model
        return bestShell
      else return shell

    _.reduce matchingShells, reduceFn, LinkShell


# select functions above, attached to acorn namespace
acorn.matchingLinkShells = LinkShell.matchingShells
acorn.bestMatchingLinkShell = LinkShell.bestMatchingShell


# -- module classes --

class LinkShell.Model extends Shell.Model

  validate: (attrs) =>
    unless (attrs? or attrs.link == '')
      unless LinkShell.linkMatches attrs.link, @module.validLinkPatterns
        ValueError 'link', 'doesn\'t match valid link patterns for this shell.'



class LinkShell.ContentView extends Shell.ContentView

  className: @classNameExtend 'link-shell'

  render: =>
    @$el.empty()
    @$el.append acorn.util.iframe @model.get('link')
    @



class LinkShell.RemixView extends Shell.RemixView

  className: @classNameExtend 'link-shell'

  initialize: =>
    super
    @eventhub.on 'delete:shell', => @.model.set 'link', ''
    @eventhub.on 'save:link', @onSaveLink

  template: _.template '''
    <div>
      <img id="thumbnail" />
      <div class="thumbnailside">
        <div id="link-field">
          <input type="text" id="link" placeholder="Enter Link" />
          <button class="btn" id="delete">delete</button>
          <button class="btn" id="duplicate">duplicate</button>
        </div>
      </div>
    </div>
    <button class="btn btn-large" id="add">Add Link</button>
    '''

  events: => _.extend super,
    'focus input#link': => @eventhub.trigger 'edit:link'
    'blur input#link' : => @eventhub.trigger 'save:link'
    'keyup input#link' : => @onKeyupLinkField()

  render: =>
    super
    @$el.html @template()
    @$('input#link').val @model.get 'link'
    @$('#thumbnail').attr 'src', @model.get 'thumbnail'
    @

  onKeyupLinkField: (event) =>
    keys = athena.lib.util.keys
    switch event.keyCode
      when keys.ENTER then @$('input#link').blur()
      when keys.ESC
        @$('input#link').val @model.get 'link'
        @$('input#link').blur()

  onSaveLink: =>
    link= @$('input#link').val()
    unless LinkShell.linkMatches link, @module.validLinkPatterns
      console.log 'LinkShell: non-matching link'
      return

    @model.set 'link', link



acorn.registerShellModule LinkShell