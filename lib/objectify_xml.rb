gem 'activesupport'
require 'active_support'
require 'active_support/inflections'
require 'nokogiri'
require File.join(File.dirname(__FILE__), 'objectify_xml/dsl')
require File.join(File.dirname(__FILE__), 'objectify_xml/document_parser')
require File.join(File.dirname(__FILE__), 'objectify_xml/element_parser')
require File.join(File.dirname(__FILE__), 'objectify_xml/nokogiri_before_1.3.0_patch') if Nokogiri::VERSION < "1.3"

module Objectify
  # Base class inherited by the DocumentParser and ElementParser. Not intended
  # for independent use.
  class Xml
    VERSION = '0.2.2'

    # When child nodes are created, they are given the name of the node
    # that created them which is available here.
    attr_reader :parent

    # A hash containing the values of the xml document's nodes. The data is
    # usually better accessed through the getter and setter methods that are
    # created for all attributes, has_one and has_many associations.
    attr_reader :attributes

    def self.inherited(target)
      # The Dsl module is added to every class that inherits from this
      target.extend Dsl
    end

    # Returns the first Nokogiri::XML::Element if any in the document.
    #
    # The xml attribute may be a string, a File object or a Nokogiri::XML
    # object.
    def self.first_element(xml)
      return if xml.nil?
      if xml.is_a?(String) or xml.is_a?(File)
        xml = Nokogiri::XML.parse(xml)
      end
      # skip the <?xml?> tag
      xml = xml.child if xml.class == Nokogiri::XML::Document
      while xml and xml.class != Nokogiri::XML::Element
        # skips past things like xml-stylesheet declarations.
        xml = xml.next
      end
      xml
    end

    def initialize(xml, parent = nil)
      @parent = parent
      @attributes = {}
      xml = self.class.first_element(xml)
      primary_xml_element(xml) if xml
    end

    # A short but informative indication of data type and which and how many
    # elements are present.
    def inspect
      begin
        attrs = (attributes || {}).map do |k,v| 
          if v.is_a? Objectify::Xml
            "#{ k }:#{ v.class.name }"
          elsif v.is_a? Array
            "#{ k }:#{ v.length }"
          else
            k.to_s
          end
        end
        "<#{ self.class.name } #{ attrs.join(', ') }>"
      rescue => e
        "<#{ self.class.name } Error inspecting class: #{ e.name } #{ e.message }>"
      end
    end

    # require 'pp'
    #
    # A more detailed recursive dump of the data in and associated to the
    # object.
    def pretty_print(q)
      begin
        q.object_group(self) do
          q.breakable
          q.seplist(attributes, nil, :each_pair) do |k, v|
            q.text "#{ k.to_s }: "
            if v.is_a? String and v.length > 200
              q.text "#{ v[0..80] }...".inspect
            else
              q.pp v
            end
          end
        end
      rescue => e
        q.text "<#{ self.class.name } Error inspecting class: #{ e.name } #{ e.message }>"
      end
    end

    protected

    # Attempts to recognize and typecast xml element text values.
    def xml_text_to_value(value)
      value = value.strip
      case value
      when 'true'
        true
      when 'false'
        false
      when /\A\d{4}-\d\d-\d\d(T(\d\d[:]){2}\d\d.*)?/
        DateTime.parse(value) rescue value
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
