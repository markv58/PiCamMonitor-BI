#!/usr/bin/python

import CGIHTTPServer

def main():
  server_address = ('', 6502)
  handler = CGIHTTPServer.CGIHTTPRequestHandler
  handler.cgi_directories = ['/cgi-bin']
  server = CGIHTTPServer.BaseHTTPServer.HTTPServer(server_address, handler)
  try:
     server.serve_forever()
  except:
     server.socket.close()

if __name__ == '__main__':
  main()
