require 'active_support'
require 'active_support/inflections'
require 'nokogiri'
require File.join(File.dirname(__FILE__), 'objectify_xml/dsl')
require File.join(File.dirname(__FILE__), 'objectify_xml/document_parser')
require File.join(File.dirname(__FILE__), 'objectify_xml/element_parser')

module Objectify
  class Xml
    VERSION = '0.1.0'

    def self.inherited(target)
      # The Dsl module is added to every class that inherits from this
      target.extend Dsl
    end

    def initialize(xml)
      @attributes = {}
      return if xml.nil?
      if xml.is_a? String
        xml = Nokogiri::XML(xml) 
        # skip the <?xml?> tag
        xml = xml.child if xml.name == 'document'
      end
      primary_xml_element(xml) if xml
    end

    protected

    def xml_text_to_value(value)
      value = value.strip
      case value
      when 'true'
        true
      when 'false'
        false
      when /\A\d{4}-\d\d-\d\dT(\d\d[:.]){3}\d{3}\w\Z/
        DateTime.parse(value)
      when /\A\d+\Z/
        value.to_i
      when /\A\d+\.\d+\Z/
        value.to_f
      else
        value
      end
    end
  end
end
