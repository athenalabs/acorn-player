if typeof acorn is 'undefined'
  acorn = {}

goog.provide 'acorn.config'

_.extend acorn.config,
  domain: 'staging.acorn.athena.ai'
  version: '0.0.0'
  api:
    version: '0.0.1'

acorn.config.url = {}
acorn.config.url.base = "http://#{acorn.config.domain}"
acorn.config.url.img = "#{acorn.config.url.base}/img"
acorn.config.url.api =
    "#{acorn.config.url.base}/api/v#{acorn.config.api.version}"

acorn.config.img = {}
acorn.config.img.acorn = '/static/img/acorn.png'
acorn.config.img.acornIcon = '/static/img/acorn.icon.png'

acorn.config.css = [
  '/static/css/acorn-player.css',
]
