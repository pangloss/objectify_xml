require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/objectify_xml'))
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/objectify_xml/atom'))
require 'spec'
require 'mocha'

def sample_feed(name)
  open(File.join(File.dirname(__FILE__), File.join('sample', name)))
end

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
