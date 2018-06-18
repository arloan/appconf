# -*- encoding: utf-8 -*-
# author: Arloan Bone (arloan@gmail.com)

require 'yaml'

##usage:
# AppConfig.setup('myApp', 'app/root/dir', 'deploy/config/dir')
# 	#'app_root_dir' determines where distribute-default config resides
#		#'myApp' will be converted to lowercase automatically.
#		#'deploy_config_dir': config file residential dir on deployment, can be nil,
#		#	in which case, config dir from environment MYAPP_CONFIG_DIR will be used.
# config = AppConfig::get_config('config_name', 'config/dir')
#		#'config_name' can be nil, in which case myapp.config.yaml is used.
#		#'config/dir' non-nil to override deploy config dir from AppConfig::setup
##to query config item:
# config['some.settings.item.dotted.path']

class Hash
	def path_lookup(path)
		return nil if path == nil || path.to_s.empty?
		path = path.to_s
		path_list = path.split('.')

		o = self
		path_list.each_with_index do |pe, idx|
			o = o[pe] || o[pe.to_sym]
			return nil if o == nil || !o.is_a?(Hash) && idx < path_list.length - 1
		end
		o
	end
end


require 'appconf_version'
class AppConfig

	class ConfigError < RuntimeError; end

	CONFIG_BASE_NAME = 'config'

	def self.setup(app_name, app_root_dir, deploy_conf_dir = nil)
		raise ArgumentError, 'app name cannot be empty' if app_name.nil? or app_name.length == 0
		raise ArgumentError, 'app root directory not specified' if app_root_dir.nil? or app_root_dir.length == 0
		raise ArgumentError, 'app root directory does not exist or not a directory' unless File.directory?(app_root_dir)

		@@app_raw_name = app_name
		@@app_name = app_name.downcase
		@@app_root_dir = File.expand_path(app_root_dir)

		raise ArgumentError, 'deploy config directory does not exist or not a directory' if deploy_conf_dir && !File.directory?(deploy_conf_dir)
		@@deploy_config_dir = deploy_conf_dir or ENV[@@app_name.upcase + '_CONF_DIR']
		raise ConfigError, 'config directory `%s\' specifed by environment does not exist or not a directory' %
			@@deploy_config_dir if @@deploy_config_dir && !File.directory?(@@deploy_config_dir)
	end
	def self.app_name
		@@app_raw_name
	end
	def self.get_config config_name = nil, config_dir = nil
		raise ConfigError, ('please call %s::setup() before getting a config instance' % self.name) if @@app_name.nil?
		self.new config_name, config_dir
	end

	def [] key
		@deploy_platform_config.path_lookup(key) ||
			@deploy_config.path_lookup(key) ||
			@user_platform_config.path_lookup(key) ||
			@user_config.path_lookup(key) ||
			@global_platform_config.path_lookup(key) ||
			@global_config.path_lookup(key) ||
			@dist_platform_config.path_lookup(key) ||
			@dist_config.path_lookup(key)
	end

	def reload
		@deploy_platform_config = deploy_platform_config || {}
		@deploy_config = deploy_config || {}

		@user_platform_config = user_platform_config || {}
		@user_config = user_config || {}

		@global_platform_config = global_platform_config || {}
		@global_config = global_config || {}

		@dist_platform_config = dist_platform_config || {}
		@dist_config = dist_config || {}
	end

	attr_reader :config_files, :config_file_name, :platform_config_file_name,
		:dist_config_dir, :global_config_dir, :user_config_dir, :deploy_config_dir

  private

	def initialize(config_name = nil, config_dir = nil)
		raise ArgumentError, 'specified config directory `%s\' does not exist'%config_dir if config_dir && !File.exist?(config_dir)
		
		@base_name = config_name || @@app_name
		@deploy_config_dir = config_dir || @@deploy_config_dir
		@deploy_config_dir = nil if config_dir && config_dir.length == 0
		@deploy_config_dir = File.expand_path(@deploy_config_dir) if @deploy_config_dir

		@config_file_name = '%s.%s.yaml' % [@base_name, CONFIG_BASE_NAME]
		@platform_config_file_name = '%s.%s.%s.yaml' % [@base_name, RUBY_PLATFORM, CONFIG_BASE_NAME]

		@dist_config_dir = File.join @@app_root_dir, CONFIG_BASE_NAME
		@global_config_dir = sys_config_dir
		@user_config_dir = usr_config_dir

		@config_files = []
		reload
	end

	def dist_config
		file_path = File.join @dist_config_dir, @config_file_name
		if File.exist?(file_path)
			@config_files << file_path
			return load_yaml_file file_path
		end
		nil
	end
	def dist_platform_config
		file_path = File.join @dist_config_dir, @platform_config_file_name
		if File.exist?(file_path)
			@config_files << file_path
			return load_yaml_file file_path
		end
		nil
	end
	def global_config
		file_path = File.join @global_config_dir, @config_file_name
		if File.exist?(file_path)
			@config_files << file_path
			return load_yaml_file file_path
		end
		nil
	end
	def global_platform_config
		file_path = File.join @global_config_dir, @platform_config_file_name
		if File.exist?(file_path)
			@config_files << file_path
			return load_yaml_file file_path
		end
		nil
	end
	def user_config
		file_path = File.join @user_config_dir, @config_file_name
		if File.exist?(file_path)
			@config_files << file_path
			return load_yaml_file file_path
		end
		nil
	end
	def user_platform_config
		file_path = File.join @user_config_dir, @platform_config_file_name
		if File.exist?(file_path)
			@config_files << file_path
			return load_yaml_file file_path
		end
		nil
	end
	def deploy_config
		return nil if @deploy_config_dir.nil?
		file_path = File.join @deploy_config_dir, @config_file_name
		if file_path && File.file?(file_path)
			@config_files << file_path
			return load_yaml_file(file_path)
		end
		nil
	end
	def deploy_platform_config
		return nil if @deploy_config_dir.nil?
		file_path = File.join @deploy_config_dir, @platform_config_file_name
		if file_path && File.file?(file_path)
			@config_files << file_path
			return load_yaml_file(file_path)
		end
		nil
	end

	def load_yaml_file(file_path)
		YAML.load(IO.read(file_path)) if File.file?(file_path)
	end

	def sys_config_dir
		if ENV['OS'] == 'Windows_NT'
			dir = File.join(ENV['ALLUSERSPROFILE'], 'Application Data', @@app_name)
		else
			dir = File.join('/etc', @@app_name)
		end
		return File.expand_path(dir)
	end
	def usr_config_dir
		if ENV['OS'] == 'Windows_NT'
			dir = File.join(ENV['USERPROFILE'], @@app_name)
		else
			dir = File.join(ENV['HOME'], '.' + @@app_name)
		end
		return File.expand_path(dir)
	end
end
