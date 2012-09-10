import BaseHTTPServer
import SimpleHTTPServer
from SimpleHTTPServer import SimpleHTTPRequestHandler

class PlayerHandler(SimpleHTTPRequestHandler):

  def do_GET(self):

    # / should return player.html.
    if self.path == '/':
      self.path = '/player.html'

    # player/ requests should return player.html.
    if self.path.split('/')[1] == 'player':
      self.path = '/player.html'

    return SimpleHTTPRequestHandler.do_GET(self)


def test(port = 8000,
         HandlerClass = PlayerHandler,
         ServerClass = BaseHTTPServer.HTTPServer):
  BaseHTTPServer.test(HandlerClass, ServerClass)

if __name__ == '__main__':
  import sys
  if '-h' in sys.argv or '--help' in sys.argv:
    print 'acorn-player server.'
    print 'usage: python', sys.argv[0], '[port]'
    exit()

  test()
