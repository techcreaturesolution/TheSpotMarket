const env = require('./config/env');
const app = require('./app');

const server = app.listen(env.PORT, () => {
  console.log(`Backend server running at http://localhost:${env.PORT}`);
});

// Graceful shutdown handling
process.on('SIGTERM', () => {
  console.log('[SERVER] SIGTERM received. Closing HTTP server gracefully...');
  server.close(() => {
    console.log('[SERVER] HTTP server closed.');
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  console.log('[SERVER] SIGINT received. Shutting down...');
  server.close(() => {
    console.log('[SERVER] HTTP server closed.');
    process.exit(0);
  });
});

module.exports = server;
