#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Route a compiled xtool to authored loopback metadata. No account or real ADI."""
import http.server,threading,subprocess,os,json,sys
from pathlib import Path
binary=str(Path(sys.argv[1]).resolve(strict=True))
requests=[]
class Handler(http.server.BaseHTTPRequestHandler):
 def do_GET(self):
  requests.append(self.path)
  if self.path!='/v3/client_info':self.send_error(404);return
  payload=json.dumps({'client_info':'authored-routing-fixture','user_agent':'authored-routing-fixture'}).encode()
  self.send_response(200);self.send_header('Content-Type','application/json');self.send_header('Content-Length',str(len(payload)));self.end_headers();self.wfile.write(payload)
 def log_message(self,*args):pass
with http.server.HTTPServer(('127.0.0.1',0),Handler) as server:
 thread=threading.Thread(target=server.serve_forever,daemon=True);thread.start()
 env=os.environ.copy();env['XTL_ANISETTE_URL']=f'http://127.0.0.1:{server.server_port}'
 result=subprocess.run([binary,'sparky-policy','--probe'],env=env,capture_output=True,text=True,timeout=20)
 print(result.stdout,end='');print(result.stderr,end='')
 assert result.returncode==0 and requests==['/v3/client_info'] and result.stdout.startswith('sparky-shared-pairing-1\n')
 assert env['XTL_ANISETTE_URL'] in result.stdout
 server.shutdown();thread.join()
 env['XTL_ANISETTE_URL']='http://not-loopback.invalid'
 result=subprocess.run([binary,'sparky-policy'],env=env,capture_output=True,text=True,timeout=20)
 assert result.returncode!=0
print('PASS: compiled xtool selects the configured loopback endpoint, fetches only metadata, rejects non-loopback cleartext; authored fixture, NOT real anisette')
