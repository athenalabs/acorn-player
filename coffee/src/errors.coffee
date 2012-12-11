goog.provide 'acorn.errors'

NotImplementedError = (method) ->
  throw new Error "#{method} not implemented. Did you override it?"

NotSupportedError = (method, extra) ->
  throw new Error "#{method} not supported. #{extra ? ''}"

ParameterError = (param) ->
  throw new Error "Parameter error: #{param} must be specified."

UrlError = ->
  ParameterError '"url" property or function'

UndefinedShellError = (shell) ->
  throw new Error "Attempt to construct undefined shell #{shell}"

APIError = (description) ->
  throw new Error "Acorn API Error: #{description}"

AssertionFailed = (description) ->
  throw new Error "Assertion failed: #{description}"

MissingParameterError = (prefix, parameter) ->
  throw new Error "#{prefix}: Required parameter `#{parameter}` is missing."

acorn.errors.UrlError = UrlError
acorn.errors.APIError = APIError
acorn.errors.ParameterError = ParameterError
acorn.errors.NotSupportedError = NotSupportedError
acorn.errors.UndefinedShellError = UndefinedShellError
acorn.errors.NotImplementedError = NotImplementedError
acorn.errors.AssertionFailed = AssertionFailed
acorn.errors.MissingParameterError = MissingParameterError