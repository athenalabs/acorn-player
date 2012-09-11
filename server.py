#!/usr/bin/env python

import BaseHTTPServer
import SimpleHTTPServer
from SimpleHTTPServer import SimpleHTTPRequestHandler

class PlayerHandler(SimpleHTTPRequestHandler):

  def do_GET(self):

    # / should return player.html.
    if self.path == '/':
      self.path = '/player.html'

    # player/ requests should return player.html.
    if self.path.startswith('/player/'):
      self.path = '/player.html'

    return SimpleHTTPRequestHandler.do_GET(self)


def test(HandlerClass = PlayerHandler,
         ServerClass = BaseHTTPServer.HTTPServer):
    BaseHTTPServer.test(HandlerClass, ServerClass)

if __name__ == '__main__':
    test()
