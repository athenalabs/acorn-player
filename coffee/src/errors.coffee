goog.provide 'acorn.errors'

APIError = acorn.errors.APIError = (description) ->
  throw new Error "Acorn API Error: #{description}"

AssertionFailed = acorn.errors.AssertionFailed = (description) ->
  throw new Error "Assertion failed: #{description}"

MissingParameterError = acorn.errors.MissingParameterError = (prefix, param) ->
  throw new Error "#{prefix}: Required parameter `#{param}` is missing."

NotImplementedError = acorn.errors.NotImplementedError = (method) ->
  throw new Error "#{method} not implemented. Did you override it?"

NotSupportedError = acorn.errors.NotSupportedError = (method, extra) ->
  throw new Error "#{method} not supported. #{extra ? ''}"

TypeError = acorn.errors.TypeError = (variable, expectedType) ->
  throw new Error "Type error: `#{variable}` is not of type #{expectedType}."

ValueError = acorn.errors.ValueError = (variable, error) ->
  throw new Error "Value error: `#{variable}` #{error}."

UnregisteredShellError = acorn.errors.UnregisteredShellError = (shell) ->
  throw new Error "Attempt to construct unregistered shell #{shell}"

ShellRegistryError = acorn.errors.ShellRegistryError = (shell, error) ->
  throw new Error "Error registering shell #{shell}. #{error ? ''}"

ControlNotFoundError = acorn.errors.ControlNotFoundError = (name) ->
  throw new Error "Control not found: #{name}"
