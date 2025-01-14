from http.server import HTTPServer, BaseHTTPRequestHandler
import json

class WebServer(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health':
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b'OK')
            return
        
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        
        response = {
            'message': 'Hello from AWS!',
            'status': 'running',
            'version': '1.0.0'
        }
        
        self.wfile.write(json.dumps(response).encode())

def run(server_class=HTTPServer, handler_class=WebServer, port=8000):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f'Starting server on port {port}...')
    httpd.serve_forever()

if __name__ == '__main__':
    run()