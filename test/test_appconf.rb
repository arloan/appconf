#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'minitest/autorun'
require 'appconf' # use this with Rake
#require_relative '../lib/appconf' # use this without Rake

class AppConfigTest < MiniTest::Unit::TestCase
	DEPLOY_VALUE			= 'deployment value'
	DEPLOY_PLATFORM_VALUE	= 'deployment platform value'
	USER_VALUE				= 'user value'
	USER_PLATFORM_VALUE		= 'user platform value'
	GLOBAL_VALUE			= 'global value'
	GLOBAL_PLATFORM_VALUE	= 'global platform value'
	DIST_VALUE				= 'distribution value'
	DIST_PLATFORM_VALUE		= 'distribution platform value'

	TEST_CONFIG_NAME		= 'foo.bar'

	# a new TestCase object created for every test method testing
	AppConfig.setup 'Test', File.dirname(__FILE__), ENV['TMP']
	@@config = AppConfig.get_config

	def self.clean
		#puts 'AppConfigTest::clean called.'
		@@config.config_files.each { |f| File.delete f if File.exist? f }
		begin
			Dir.rmdir @@config.dist_config_dir   if File.exist? @@config.dist_config_dir
			Dir.rmdir @@config.user_config_dir   if File.exist? @@config.user_config_dir
			Dir.rmdir @@config.global_config_dir if File.exist? @@config.global_config_dir
		rescue
			$stderr.puts $!
		end
	end

	self.clean

	def self.test_order
		:alpha
	end

	def test_h_deploy_platform_value
		create_deploy_platform_config_file
		@@config.reload
		assert_equal DEPLOY_PLATFORM_VALUE, query_config_value
	end
	def test_g_deploy_value
		create_deploy_config_file
		@@config.reload
		assert_equal DEPLOY_VALUE, query_config_value
	end
	def test_f_user_platform_value
		create_user_platform_config_file
		@@config.reload
		assert_equal USER_PLATFORM_VALUE, query_config_value
	end
	def test_e_user_value
		create_user_config_file
		@@config.reload
		assert_equal USER_VALUE, query_config_value
	end
	def test_d_global_platform_value
		create_global_platform_config_file
		@@config.reload
		assert_equal GLOBAL_PLATFORM_VALUE, query_config_value
	end
	def test_c_global_value
		create_global_config_file
		@@config.reload
		assert_equal GLOBAL_VALUE, query_config_value
	end
	def test_b_dist_platform_value
		create_dist_platform_config_file
		@@config.reload
		assert_equal DIST_PLATFORM_VALUE, query_config_value
	end
	def test_a_dist_value
		create_dist_config_file
		@@config.reload
		assert_equal DIST_VALUE, query_config_value
	end
	def test_i_non_exist_value
		assert_equal nil, @@config['non.exist.config.item']
	end

	def test_z_clean
		self.class.clean
	end

	private

	def query_config_value
		@@config[TEST_CONFIG_NAME]
	end

	def create_yaml_with_value(path, v, more = nil)
		c = { :foo => { :bar => v } }
		c.merge! more if more and more.is_a?(Hash)
		dir = File.dirname(path)
		Dir.mkdir dir unless File.exist?(dir)
		File.open(path, 'w') { |f| f.write c.to_yaml }
		puts 'YAML created: %s' % path
	end
	def create_deploy_config_file
		path = File.join @@config.deploy_config_dir, @@config.config_file_name
		create_yaml_with_value path, DEPLOY_VALUE
	end
	def create_deploy_platform_config_file
		path = File.join @@config.deploy_config_dir, @@config.platform_config_file_name
		create_yaml_with_value path, DEPLOY_PLATFORM_VALUE
	end
	def create_user_config_file
		path = File.join @@config.user_config_dir, @@config.config_file_name
		create_yaml_with_value path, USER_VALUE
	end
	def create_user_platform_config_file
		path = File.join @@config.user_config_dir, @@config.platform_config_file_name
		create_yaml_with_value path, USER_PLATFORM_VALUE
	end
	def create_global_config_file
		path = File.join @@config.global_config_dir, @@config.config_file_name
		create_yaml_with_value path, GLOBAL_VALUE
	end
	def create_global_platform_config_file
		path = File.join @@config.global_config_dir, @@config.platform_config_file_name
		create_yaml_with_value path, GLOBAL_PLATFORM_VALUE
	end
	def create_dist_config_file
		path = File.join @@config.dist_config_dir, @@config.config_file_name
		create_yaml_with_value path, DIST_VALUE
	end
	def create_dist_platform_config_file
		path = File.join @@config.dist_config_dir, @@config.platform_config_file_name
		create_yaml_with_value path, DIST_PLATFORM_VALUE
	end

end

# this line does not work
# MiniTest::Unit.after_tests { AppConfigTest.clean }
