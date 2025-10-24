from http.server import HTTPServer, SimpleHTTPRequestHandler

port = 8000
serveur = HTTPServer(('0.0.0.0', port), SimpleHTTPRequestHandler)
print(f"Serveur Python en ligne ✅ sur le port {port}")
serveur.serve_forever()
