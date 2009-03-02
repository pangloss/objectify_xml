# -*- ruby -*-

require 'rubygems'
require 'hoe'
require './lib/objectify_xml.rb'
require 'spec/rake/spectask'

Hoe.new('objectify-xml', Objectify::Xml::VERSION) do |p|
  p.rubyforge_name = 'objectify-xml' # if different than lowercase project name
  p.developer('pangloss', 'darrick@innatesoftware.com')
  p.extra_deps = %w[nokogiri activesupport]
  p.testlib = 'spec'
  p.test_globs = 'spec/**/*_spec.rb'
  p.url = 'http://github.com/pangloss/objectify_xml'
  p.remote_rdoc_dir = ''
end

desc "Run all specifications"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.libs = ['lib', 'spec']
  t.spec_opts = ['--colour', '--format', 'specdoc']
end

# vim: syntax=Ruby
