#! /usr/bin/env node
const fs = require('fs');

// default list of ntp servers
fs.createReadStream('./timeservers.txt', {
    highWaterMark: 64 * 1024,
  })
  .pipe(process.stdout);
