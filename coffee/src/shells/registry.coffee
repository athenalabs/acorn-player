goog.provide 'acorn.shells.Registry'

goog.require 'acorn'

class acorn.shells.Registry

  @modules: {}

  @registerModule: (shellModule) =>

    # validate that shellModule contains required String properties
    required_properties = [ 'id', 'title', 'description' ]
    _.each required_properties, (property) ->
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
        shellModule[key] = _.clone value

    # validate shellModule's Model and View properties
    class_properties = [ 'Model', 'ContentView', 'SummaryView', 'EditView']
    _.each class_properties, (property) ->
      unless _.isFunction shellModule[property]
        TypeError property, 'class'

    # set the `shell` property of each class within shellModule to point
    # back to the shellModule namespace
    _.each class_properties, (property) ->
      shellModule[property].shell = shellModule

    # register shell
    @modules[shellModule.id] = shellModule

acorn.registerShellModule = acorn.shells.Registry.registerModule
