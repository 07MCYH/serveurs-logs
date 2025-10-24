const http = require('http');
const port = 3000;
const server = http.createServer((req, res) => {
  res.writeHead(200, {'Content-Type': 'text/plain'});
  res.end('Serveur Node.js en ligne ✅\n');
});
server.listen(port, () => console.log(`Server listening on ${port}`));

