goog.provide 'acorn.specs.shells.CollectionShell'

goog.require 'acorn.shells.CollectionShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.CollectionShell', ->
  derives = athena.lib.util.derives
  Shell = acorn.shells.Shell
  CollectionShell = acorn.shells.CollectionShell

  it 'should be part of acorn.shells', ->
    expect(CollectionShell).toBeDefined()

  acorn.util.test.describeShellModule CollectionShell
