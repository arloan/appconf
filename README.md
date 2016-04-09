# AppConf

**AppConf** is a ruby gem used to query config values from one ore more series of YAML configuration files in priority, via dot split item path names.



## Installation

```shell
gem install appconf
```

## Description

**AppConf** loads and parses a series of YAML configuration files in priority, which means if multiple configuration items with the same path name exist in different files, then the value of the item in the highest priority file will be selected as query result.

**AppConf** will loads all these YAML configuration files, if exist, in priority highest to lowest:

- *`/path/to/specified/deployment/dir`*/*`myapp`*.*`ruby-platform`*.yaml
- *`/path/to/specified/deployment/dir`*/*`myapp`*.yaml
- *`/home/username`*/*`.myapp`*/*`myapp`*.*`ruby-platform`*.yaml
- *`/home/username`*/*`.myapp`*/*`myapp`*.yaml
- /etc/*`myapp`*/*`myapp`*.*`ruby-platform`*.yaml
- /etc/*`myapp`*/*`myapp`*.yaml
- *`/path/to/myapp`*/conf/*`myapp`*.*`ruby-platform`*.yaml
- *`/path/to/myapp`*/conf/*`myapp`*.yaml

Where:

- *`/path/to/specified/deployment/dir`*: The directory where you app is deployed, use AppConfig::setup to tell the gem where it is.


- *`myapp`*: The name of the configuration file you requested via AppConfig::get_conf, or the name of your app when nil is used for configuration file name. The app name is setup via AppConfig::setup.
- *`.myapp`*: Note that there is a **dot** before `myapp` for the name of this directory, which holds user level configuration file. While on Windows, there is **no** such dot.


- *`ruby-platform`*: The platform of the ruby is running on. For jruby, it is `java`.


- *`/home/username`*: The home directory of the user who is running your app. In Windows, it's `ENV['USERPROFILE']`, for POSIX, `ENV['HOME']` is used.  


- `/etc`: In Windows, `ENV['ALLUSERSPROFILE']` is used. 


- *`/path/to/myapp`*: The root directory where your app resides in.

## Why YAML?

XML is heavy and verbose, JSON has no comments, that's it.

## Usage

Say you have a ruby app named `awsome`, need a default configuration file located in `conf` directory under your app's root path, named `awsome.yaml` like this (in YAML):

```yaml
---
db:
	driver: sequel
	conection: sqlite://awsome.db
```

While when you are testing you app on your development machine, you want to use a specific sqlite database file located at `/home/arloan/awsome-db/test-2016.db`, how can I do? It's simple, place a file named `awsome.yaml` under `/home/arloan/.awsome/`, with the contents:

```yaml
---
db:
	connection: sqlite:///home/arloan/awsome-db/test-2016.db
```

In addition, you want your app to be compatible with jruby, and want to use a different, jruby specific database connection method when running under jruby, then you can create a configuration file named `awsome.java.yaml`  and place it along with your default `awsome.yaml`, in  `conf` directory under your app's root path, with the contents:

```yaml
---
db:
	connection: jdbc:sqlite:awsome.db
```

In your app's code, you write:

```ruby
require 'appconf'

# in app's initialization part
AppConfig.setup 'Awsome', # app name, will be converted to lower case automatically
	File.dirname(__FILE__), # app root dir path
	'/path/to/app/deployment/directory' # app deployment path, i.e production env

# default config with app name and deployment directory
default_config = AppConfig.get_config

# use another series of configuration files with new name, use 'new-name.yaml' series
another_config = AppConfig.get_config 'new-name'

# you can overwrite deployment directory when get a config serie
overwritten_config = AppConfig.get_config nil, '/path/to/new/deployment/dir'

# to query config value:
# conn == 'sqlite://awsome.db' in default case
# conn == 'sqlite:///home/arloan/awsome-db/test-2016.db' in development environment.
# conn == 'jdbc:sqlite:awsome.db' in jruby
conn = default_config['db.connection']

# non exist path returns nil, no exception
this_is_nil = default_config['non.exist.conf.item.path']
```

## License

(The MIT License)

Copyright © Arloan Bone (arloan@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

