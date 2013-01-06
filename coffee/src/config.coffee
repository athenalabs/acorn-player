if typeof acorn is 'undefined'
  acorn = {}

goog.provide 'acorn.config'

_.extend acorn.config,
  domain: 'staging.acorn.athena.ai'
  version: '0.0.0'
  api:
    version: '0.0.2'


acorn.config.url = {}

acorn.config.setDomain = (domain) ->
  acorn.config.domain = domain.replace(/https?:\/\//, '')
  acorn.config.url.base = "//#{acorn.config.domain}"
  acorn.config.url.img = "#{acorn.config.url.base}/img"
  acorn.config.url.api =
      "#{acorn.config.url.base}/api/v#{acorn.config.api.version}"

acorn.config.setDomain(acorn.config.domain)


acorn.config.img = {}
acorn.config.img.acorn = "#{acorn.config.url.img}/acorn.png"
acorn.config.img.acornIcon = "#{acorn.config.url.img}/acorn.icon.png"


acorn.config.css = [
  '/css/acorn-player.css',
  '/lib/fontawesome/css/font-awesome.css',
  '/lib/jquery/jquery-ui.custom.min.css',
]


# TODO: move these config properties to a test specific config file once
# the build system adequately processes imports
acorn.config.test = {}
acorn.config.test.timeout = 10000  # time in miliseconds

