var version = function (_verCheck) {
  if (typeof _verCheck === 'undefined') _verCheck = 'v0.12.0';
  _ver = process.version.replace('v', '').split('.');
  _verCheck = _verCheck.replace('v', '').split('.');
  for (var i = 0; i <= _ver.length - 1; i++) {
    if (_ver[i] < _verCheck[i]) return false;
  };
  return true;
}

var fs = require('fs'),
    shell = require("shelljs/global"),
    execSync = require("child_process").execSync,
    scrts = require('./secrets.json'),
    projectRoot = process.cwd();
if (!version()) {
  var execSync = require("execSync").run;
};


// init bower
if (!test('-f', 'bower.json')) {
  if (!which('bower')) {
    echo('bower not installed');
    echo('run npm install -g bower && npm install');
    echo('aborting');
    exit(1);
  } else {
    echo('bower not initialiased... initialising');
    execSync('bower init, --config.interactive');
  }
} else {
  echo('bower.json is initialised');
}


// create secrets
if (!test('-f', 'secrets.json')) {
  if (test('-f', 'secrets-sample.json')) {
    echo('creating your vey own secrets');
    cp('secrets-sample.json', 'secrets.json');
    echo('secrets.json created');
  } else {
    echo('who deleted the secrets-sample.json? Kill that mofo!');
    echo('no secrets.json created - look at the boilerplate, or get one from someone, and make secrets-sample.json');
    exit(1);
  }
} else {
  echo('secrets.json is ready');
}


// symlink styleguide
if (!test('-L', 'styleguide/src/assets/toolkit/assets')) {
  echo('symlinking styleguide assets to site assets');
  cd('styleguide/src/assets/toolkit');
  ln('-s', '../../../../unbuilt-assets', 'assets');
  cd(projectRoot)
  echo('assets symlinked');
} else {
  echo('styleguide correctly symlinked to site assets');
}


// copy config.yml for shopify_theme gem
if (!test('-f', 'src/config.yml')) {
  if (!which('theme')) {
    echo('shopify themekit not installed');
    echo('installing themekit using \'curl https:\/\/raw.githubusercontent.com\/Shopify\/themekit/installers/install | python\'');
    echo("curl https:\/\/raw.githubusercontent.com\/Shopify\/themekit\/installers\/install | python");
  }
  echo('setting up config for shopify theme');
  cd('src');
  execSync("cp config-sample.yml config.yml");
  cd(projectRoot)
  echo('add API keys to your new src/config.yml');
} else {
  echo('config for shopify theme already setup');
}


// write git hooks so that theme gem uploads all files on checkout / merge
(function() {
  var updateHook = {
    gitPath: '.git/hooks/',
    bashStr: [
      '# shopify_theme gem: upload changes when checkout / merge',
      'FILES="',
      './src/config/*',
      './src/layout/*',
      './src/snippets/*',
      './src/templates/*"',
      'for f in $FILES; do',
      'echo \"saving file $f for shopify to upload changes\"',
      'touch $f',
      'done'
    ].join('\n'),

    fileExists: function(fn) {
      return test('-f', '.git/hooks/' + fn);
    },

    hasUpdate: function(fn) {
      fs.readFile(fn, 'utf-8', function(err, data) {
        if (err) console.log(err);

        console.log(data);
        return data.indexOf('shopify_theme') > -1;
      });
    },

    createFile: function(fn) {
      fs.writeFile(updateHook.gitPath + fn, updateHook.bashStr, function(err) {
        if (err) throw err;

        console.log(fn + ' created');
      })
    },

    writeFile: function(fn) {
      fs.appendFile(updateHook.gitPath + fn, updateHook.bashStr, function(err) {
        if (err) throw err;

        console.log(fn + ' updated');
      })
    }
  };

  ['post-checkout', 'post-merge'].map(function(file) {
    if (updateHook.fileExists(file) && !updateHook.hasUpdate(file)) {
      updateHook.writeFile(file);
    } else {
      updateHook.createFile(file);
    }
  });
})
