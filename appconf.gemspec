# -*- encoding: utf-8 -*-

require File.expand_path('./lib/appconf_version', File.dirname(__FILE__))

Gem::Specification.new do |s|
	s.name			= 'appconf'
	s.version		= AppConfig::VERSION
	s.date			= '2016-04-09'
	s.authors		= ['Arloan Bone']
	s.email			= 'arloan@gmail.com'
	s.homepage		= 'https://github.com/arloan/appconf'
	s.summary		= 'App YAML Config in Priority'
	s.description	= 'Query config values from one or more series of YAML files in priority.'

	# s.required_rubygems_version = ">= 1.3.6"
	# s.add_dependency "another", "~> 1.2"

	s.license		= 'MIT'
	s.files			= Dir["{lib}/**/*.rb", "{test}/**/*", "bin/*", "Rakefile", "*LICENSE*", "*.md"]
	# s.require_path = 'lib'

	# If you need an executable, add it here
	# s.executables = ["newgem"]

	# If you have C extensions, uncomment this line
	# s.extensions = "ext/extconf.rb"
end
