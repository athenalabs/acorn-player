goog.provide 'acorn.errors'

APIError = (description) ->
  throw new Error "Acorn API Error: #{description}"

AssertionFailed = (description) ->
  throw new Error "Assertion failed: #{description}"

MissingParameterError = (prefix, parameter) ->
  throw new Error "#{prefix}: Required parameter `#{parameter}` is missing."

NotImplementedError = (method) ->
  throw new Error "#{method} not implemented. Did you override it?"

NotSupportedError = (method, extra) ->
  throw new Error "#{method} not supported. #{extra ? ''}"

TypeError = (variable, expectedType) ->
  throw new Error "Type error: `#{variable}` is not of type #{expectedType}."

UnregisteredShellError = (shell) ->
  throw new Error "Attempt to construct unregistered shell #{shell}"

ShellRegistryError = (shell, error) ->
  throw new Error "Error registering shell #{shell}. #{error ? ''}"

URLError = ->
  ParameterError '"url" property or function'

acorn.errors.APIError = APIError
acorn.errors.AssertionFailed = AssertionFailed
acorn.errors.MissingParameterError = MissingParameterError
acorn.errors.NotImplementedError = NotImplementedError
acorn.errors.NotSupportedError = NotSupportedError
acorn.errors.TypeError = TypeError
acorn.errors.UnregisteredShellError = UnregisteredShellError
acorn.errors.URLError = URLError
