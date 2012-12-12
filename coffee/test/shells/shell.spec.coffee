goog.provide 'acorn.specs.shells.Shell'

goog.require 'acorn.shells.Shell'


describe 'acorn.shells.Shell', ->
  Shell = acorn.shells.Shell

  it 'should be part of acorn.specs', ->
    expect(acorn.shells.Shell).toBeDefined()

  it 'should derive from Backbone.Model', ->
    expect(athena.lib.util.derives Shell.Model, Backbone.Model).toBe true

  it 'should contain required properties', ->
    required_properties = [ 'id', 'title', 'description' ]
    _.each required_properties, (property) ->
      expect(Shell[property]).toBeDefined()
      expect(_.isString Shell[property]).toBe true

  it 'should contain required Model and View classes', ->
    required_classes = [ 'Model', 'ContentView', 'SummaryView', 'RemixView' ]
    _.each required_classes, (property) ->
      expect(Shell[property]).toBeDefined()
      expect(_.isFunction Shell[property]).toBe true