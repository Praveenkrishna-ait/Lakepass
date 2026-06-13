const { Pool } = require('pg');
require('dotenv').config();
const { Resolver } = require('dns');
const { URL } = require('url');

const resolver = new Resolver();
resolver.setServers(['8.8.8.8', '8.8.4.4']);

function resolveHostname(hostname) {
  return new Promise((resolve) => {
    resolver.resolve4(hostname, (err, addresses) => {
      if (err || !addresses || addresses.length === 0) {
        console.warn('Google DNS failed, using original hostname:', err?.message);
        resolve(hostname); // fallback to original
      } else {
        console.log(`Resolved ${hostname} → ${addresses[0]} via Google DNS`);
        resolve(addresses[0]);
      }
    });
  });
}

// Parse the DB URL and resolve hostname to IP at startup
const dbUrl = new URL(process.env.DATABASE_URL);
const originalHostname = dbUrl.hostname;

let pool;

resolveHostname(originalHostname).then((resolvedHost) => {
  pool = new Pool({
    user: dbUrl.username,
    password: dbUrl.password,
    host: resolvedHost,
    port: dbUrl.port || 5432,
    database: dbUrl.pathname.replace('/', ''),
    ssl: {
      rejectUnauthorized: false,
      servername: originalHostname, // SNI so SSL cert validates
    },
  });
  console.log('Database pool initialized.');
}).catch(err => {
  console.error('Failed to initialize DB pool:', err.message);
});

// Proxy object so existing code (pool.query, etc.) works unchanged
const poolProxy = new Proxy({}, {
  get(_, prop) {
    if (!pool) throw new Error('DB pool not yet initialized. Retry in a moment.');
    return typeof pool[prop] === 'function' ? pool[prop].bind(pool) : pool[prop];
  }
});

module.exports = {
  query: (text, params) => {
    if (!pool) return Promise.reject(new Error('DB not ready yet'));
    return pool.query(text, params);
  },
  pool: poolProxy,
};


