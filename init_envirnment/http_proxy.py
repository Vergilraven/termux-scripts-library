#!/usr/bin/env python3
import http.server
import socketserver
import os
import sys
import argparse
from functools import partial


class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # 添加CORS头以便于前端开发
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', '*')
        super().end_headers()

def main():
    parser = argparse.ArgumentParser(description='Start a simple HTTP server')
    parser.add_argument('-p', '--port', type=int, default=8000,
                        help='Port to listen on (default: 8000)')
    parser.add_argument('-d', '--directory', default='.',
                        help='Directory to serve (default: current directory)')
    parser.add_argument('--cors', action='store_true',
                        help='Enable CORS headers')

    args = parser.parse_args()

    # 切换到指定目录
    try:
        os.chdir(args.directory)
    except FileNotFoundError:
        print(f"Error: Directory '{args.directory}' not found.")
        sys.exit(1)
    except PermissionError:
        print(f"Error: Permission denied to access directory '{args.directory}'.")
        sys.exit(1)

    # 选择处理器
    if args.cors:
        handler = CustomHTTPRequestHandler
    else:
        handler = http.server.SimpleHTTPRequestHandler

    # 创建服务器
    try:
        with socketserver.TCPServer(("", args.port), handler) as httpd:
            print(f"Serving directory: {os.getcwd()}")
            print(f"Server running at http://localhost:{args.port}/")
            print("Press Ctrl+C to stop the server")

            # 启动服务器
            httpd.serve_forever()
    except PermissionError:
        print(f"Error: Permission denied to bind to port {args.port}. Try a port >= 1024.")
        sys.exit(1)
    except OSError as e:
        if e.errno == 48:  # Address already in use
            print(f"Error: Port {args.port} is already in use.")
        else:
            print(f"Error: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nServer stopped.")

if __name__ == "__main__":
    main()
