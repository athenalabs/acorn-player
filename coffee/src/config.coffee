if typeof acorn is 'undefined'
  acorn = {}

goog.provide 'acorn.config'

_.extend acorn.config,
  version: '0.0.0'
  url:
    base: 'https://acorn.athena.ai'
  api:
    version: '0.0.2'


acorn.config.setUrlBase = (base) ->
  acorn.config.url.base = base
  acorn.config.url.img = "#{base}/img"
  acorn.config.url.api = "#{base}/api/v#{acorn.config.api.version}"

acorn.config.setUrlBase acorn.config.url.base


acorn.config.img = {}
acorn.config.img.acorn = "#{acorn.config.url.img}/acorn.png"
acorn.config.img.acornIcon = "#{acorn.config.url.img}/acorn.icon.png"


acorn.config.css = [
  '/build/css/acorn-player.css',
  '/lib/fontawesome/css/font-awesome.css',
]


# TODO: move these config properties to a test specific config file once
# the build system adequately processes imports
acorn.config.test = {}
acorn.config.test.timeout = 10000  # time in miliseconds

