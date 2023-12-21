#!/bin/bash

# https://github.com/actions/runner-images/blob/main/images/ubuntu/scripts/build/install-phantomjs.sh
# Install required dependencies
sudo apt-get install -yq chrpath libssl-dev libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev

# Define the version and hash of PhantomJS to be installed
dir_name=phantomjs-2.1.1-linux-x86_64
download_url="https://bitbucket.org/ariya/phantomjs/downloads/$dir_name.tar.bz2"
archive_path=/tmp/$dir_name.tar.bz2

curl -Lsfo "$archive_path" "$download_url"

# Extract the archive and create a symbolic link to the executable
sudo tar xjf "$archive_path" -C /usr/local/share
ln -sf /usr/local/share/$dir_name/bin/phantomjs /usr/local/bin
sudo chmod +x /usr/local/bin/phantomjs

cat >> loadspeed.js << EOF
var page = require('webpage').create(),
  system = require('system'),
  t, address;

if (system.args.length === 1) {
  console.log('Usage: loadspeed.js [some URL]');
  phantom.exit();
}

page.onError = function (msg, trace) {
    console.error(msg);
    trace.forEach(function(item) {
        console.error('  ', item.file, ':', item.line);
    });
};

page.set('settings', {
    userAgent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.97 Safari/537.11",
    javascriptEnabled: false,
    loadImages: false
});

t = Date.now();
address = system.args[1];
page.open(address, function(status) {
  if (status !== 'success') {
    console.log('FAIL to load the address: ' + address);
  } else {
    t = Date.now() - t;
    console.log('Loading ' + system.args[1]);
    console.log('Loading time ' + t + ' msec');
  }
  phantom.exit();
});
EOF

cat loadspeed.js

phantomjs loadspeed.js "http://www.google.com/"
