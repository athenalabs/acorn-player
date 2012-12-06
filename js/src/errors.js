(function() {

var root = this;
var errors = root.errors = (root.errors || {});

// Errors
// ------

var NotImplementedError = function(method) {
  throw new Error(method + ' not implemented. Did you override it?');
};

var NotSupportedError = function(method, extra) {
  throw new Error(method + ' not supported. ' +  (extra || '') );
};

var ParameterError = function(param) {
  throw new Error('Parameter error: ' + param + ' must be specified.');
};

var GetKeyOrSetObjError = function() {
  ParameterError('key to retrieve or object with new key-value pairs to set');
};

var UrlError = function() {
  ParameterError('"url" property or function');
};

var UndefinedShellError = function(shell) {
  throw new Error('Attempt to construct undefined shell ' + shell);
};

var APIError = function(description) {
  throw new Error('Acorn API Error: ' + description);
};

var AssertionFailed = function(description) {
  throw new Error('Assertion failed: ' + description);
};

errors.UrlError = UrlError;
errors.APIError = APIError;
errors.ParameterError = ParameterError;
errors.NotSupportedError = NotSupportedError;
errors.GetKeyOrSetObjError = GetKeyOrSetObjError;
errors.UndefinedShellError = UndefinedShellError;
errors.NotImplementedError = NotImplementedError;
errors.AssertionFailed = AssertionFailed;

}).call(this);
