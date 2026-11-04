#!/usr/bin/env python3
"""Local static server for the Godot web export (correct WASM MIME type)."""
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "exports", "web"))
PORT = int(os.environ.get("PORT", "8080"))


class Handler(SimpleHTTPRequestHandler):
    extensions_map = {
        **SimpleHTTPRequestHandler.extensions_map,
        ".wasm": "application/wasm",
        ".pck": "application/octet-stream",
        ".js": "application/javascript",
    }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cache-Control", "no-cache")
        super().end_headers()


if __name__ == "__main__":
    if not os.path.isdir(ROOT) or not os.path.isfile(os.path.join(ROOT, "index.html")):
        raise SystemExit(
            f"Missing web build at {ROOT}. Export first:\n"
            '  godot --headless --path life-mode --export-debug "Web" exports/web/index.html'
        )
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    print(f"Serving LIFE//MODE web build on http://127.0.0.1:{PORT}/", flush=True)
    server.serve_forever()
