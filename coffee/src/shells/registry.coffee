goog.provide 'acorn.shells.Registry'

goog.require 'acorn'

class acorn.shells.Registry

  @modules: {}

  @registerModule: (shellModule) =>

    # validate that shellModule contains required String properties
    requiredProperties = [ 'id', 'title', 'description' ]
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
        class shellModule[key] extends value

    # validate shellModule's Model and View properties
    classProperties = [ 'Model', 'ContentView', 'RemixView']
    _.each classProperties, (property) ->
      unless _.isFunction shellModule[property]
        TypeError property, 'class'

    # set the `shell` property of each class within shellModule to point
    # back to the shellModule namespace
    _.each classProperties, (property) ->
      shellModule[property].shell = shellModule

    # ensure this module isn't already registered
    if @modules[shellModule.id]?
      ShellRegistryError shellModule.id, 'Shell.id already registered.'

    # register shell
    @modules[shellModule.id] = shellModule

acorn.registerShellModule = acorn.shells.Registry.registerModule
