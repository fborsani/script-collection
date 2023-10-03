from http.server import BaseHTTPRequestHandler, HTTPServer
import shutil, os, sys

def start():	
	myServer = HTTPServer((HOST, PORT), MyServer)
	print("Server started. Serving "+FILEPATH+" on: "+HOST+":"+str(PORT))
	myServer.serve_forever()

class MyServer(BaseHTTPRequestHandler):
	def do_GET(self):
		with open(FILEPATH, 'rb') as file: 
			self.send_response(200)
			self.send_header("Content-Type", 'application/octet-stream')
			self.send_header("Content-Disposition", 'attachment; filename="{}"'.format(os.path.basename(FILEPATH)))
			fs = os.fstat(file.fileno())
			self.send_header("Content-Length", str(fs.st_size))
			self.end_headers()
			shutil.copyfileobj(file, self.wfile)

if len(sys.argv) == 4:
	FILEPATH = str(sys.argv[1])
	HOST = str(sys.argv[2])
	PORT = int(sys.argv[3])
	start()
else:
	print("syntax: serveFile.py FILEPATH HOST PORT")
