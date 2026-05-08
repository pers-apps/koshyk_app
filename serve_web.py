#!/usr/bin/env python3
"""Simple HTTP server with COOP/COEP headers required for SharedArrayBuffer (SQLite WASM)."""
import http.server
import os

BUILD_DIR = os.path.join(os.path.dirname(__file__), 'build', 'web')

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BUILD_DIR, **kwargs)

    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        self.send_header('Cache-Control', 'no-cache')
        super().end_headers()

    def log_message(self, format, *args):
        pass  # silence logs

if __name__ == '__main__':
    port = 8090
    server = http.server.HTTPServer(('0.0.0.0', port), Handler)
    print(f'Serving on port {port}')
    server.serve_forever()
