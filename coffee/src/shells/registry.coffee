goog.provide 'acorn.shells.Registry'

goog.require 'acorn'
goog.require 'acorn.errors'


class acorn.shells.Registry


  @modules: {}


  @moduleWithId: (shellid) =>
    unless @modules[shellid]
      acorn.errors.UnregisteredShellError shellid

    @modules[shellid]


  @registerModule: (shellModule) =>

    # validate that shellModule contains required String properties
    requiredProperties = [ 'id', 'title', 'icon' ]
    _.each requiredProperties, (property) ->
      unless shellModule[property]?
        MissingParameterError "shell registration", property

      unless _.isString shellModule[property]
        TypeError property, 'str'

    # validate that shellModule contains a Model object
    unless shellModule.Model?
      MissingParameterError "shell registration", "Model"

    # populate shellModule with default properties from Shell
    _.each acorn.shells.Shell, (value, key) ->
      unless shellModule[key]?
        if _.isFunction value
          class shellModule[key] extends value
        else
          shellModule[key] = _.clone value

    # validate shellModule's Model and View properties
    classProperties = [ 'Model', 'MediaView', 'RemixView']
    _.each classProperties, (property) ->
      unless _.isFunction shellModule[property]
        TypeError property, 'class'

    # set the `shell` property of each class within shellModule to point
    # back to the shellModule namespace
    _.each classProperties, (property) ->
      shellModule[property].module = shellModule
      shellModule[property]::module = shellModule

    # ensure this module isn't already registered
    if @modules[shellModule.id]?
      ShellRegistryError shellModule.id, 'Shell.id already registered.'

    # register shell
    @modules[shellModule.id] = shellModule


  @collectionModules: =>
    _.filter @modules, (module) =>
      athena.lib.util.isOrDerives module.Model, CollectionShell.Model


acorn.registerShellModule = acorn.shells.Registry.registerModule
acorn.shellModuleWithId = acorn.shells.Registry.moduleWithId
