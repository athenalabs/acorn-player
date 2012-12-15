goog.provide 'acorn.specs.shells.LinkShell'

goog.require 'acorn.shells.LinkShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.LinkShell', ->
  LinkShell = acorn.shells.LinkShell

  it 'should be part of acorn.shells', ->
    expect(LinkShell).toBeDefined()

  acorn.util.test.describeShellModule LinkShell
