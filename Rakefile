#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-

require 'rake/testtask'

Rake::TestTask.new do |t|
	t.libs << %w{ test }
	t.pattern = 'test/test*.rb'
end

task :default => :test
