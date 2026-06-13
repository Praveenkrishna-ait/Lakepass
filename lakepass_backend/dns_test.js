const dns = require('dns');

const hostnames = [
  'ep-misty-bird-at9n0fdq-pooler.c-9.us-east-1.aws.neon.tech',
  'ep-misty-bird-at9nofdq-pooler.c-9.us-east-1.aws.neon.tech',
  'ep-misty-bird-a19n0fdq-pooler.c-9.us-east-1.aws.neon.tech',
  'ep-misty-bird-at9n0fdq.us-east-1.aws.neon.tech',
  'ep-misty-bird-at9n0fdq.c-9.us-east-1.aws.neon.tech'
];

hostnames.forEach(hostname => {
  dns.lookup(hostname, (err, address, family) => {
    console.log(`${hostname} -> err: ${err ? err.code : 'SUCCESS'} | address: ${address}`);
  });
});
