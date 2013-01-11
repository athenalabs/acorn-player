goog.provide 'acorn.specs.shells.PDFLinkShell'

goog.require 'acorn.shells.PDFLinkShell'
goog.require 'acorn.util.test'

describe 'acorn.shells.PDFLinkShell', ->
  PDFLinkShell = acorn.shells.PDFLinkShell

  it 'should be part of acorn.shells', ->
    expect(PDFLinkShell).toBeDefined()

  acorn.util.test.describeShellModule PDFLinkShell
