#!/usr/bin/python3
# Adapted from https://www.piware.de/2011/01/creating-an-https-server-in-python/
import socket
from http.server import HTTPServer, SimpleHTTPRequestHandler
import ssl

httpd = HTTPServer((socket.gethostname(), 8443), SimpleHTTPRequestHandler)
httpd.socket = ssl.wrap_socket(httpd.socket, certfile='/tmp/cert-and-key.pem', server_side=True)
httpd.serve_forever()
