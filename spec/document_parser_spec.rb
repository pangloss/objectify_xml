require File.join(File.dirname(__FILE__), 'spec_helper')

describe Objectify::DocumentParser do
  describe 'primary_xml_element' do
    it 'should call parse_xml'
  end
  describe 'xml helpers' do
    before do
      @xml = mock('xml', :name => 'name', :namespace => nil)
    end

    describe 'qualified_name' do
      it 'should return name with just name'
      it 'should return namespace:name with name and namespace'
    end

    describe 'attribute_type' do
      it 'should return an object'
      it 'should parse a symbol type definition'
      it 'should parse a string type definition'
      it 'should parse a type definition in a module'
      it 'should find an object in the current object scope'
    end

    describe 'flatten?' do
      it 'should be true for flatten definitions'
      it 'should be nil otherwise'
    end

    describe 'collection?' do
      it 'should be true for has_many definitions'
      it 'should be nil otherwise'
    end

    describe 'namespace?' do
      it 'should be true for specified namespaces'
      it 'should be nil otherwise'
    end

    describe 'namespace' do
      it 'should return nil if no default namespace url is defined'
      it 'should return the default namespace url if defined'
      it 'should return the url of a named namespace'
    end

    describe 'namespaces' do
      it 'should return a hash containing defined named and unnamed namespaces'
    end

    describe 'attribute' do
      it 'should return the method name of the given attribute'
      it 'should return the method name of the given attribute in a namespace'
      it 'should return nil if the attribute is not defined'
      it 'should return nil if the attribute is in the wrong namespace'
    end

    describe 'parse_xml' do
      it 'should call read_xml_element on each xml sibling node'
      it 'should have no next node when it returns'
    end

    describe 'read_xml_element' do
      it 'should skip text elements'
      it 'should skip elements in the wrong namespace'
      it 'should call parse_xml on the first child node of a flattened element'
      describe 'with an attribute type' do
        it 'should call set_attribute'
        it 'should initialize the new type with the current node'
        it 'should not initialize the new type with the current node if no yield'
      end
      describe 'without an attribute type' do
        it 'should call set_attribute'
        it 'should call xml_text_to_value on the node text'
        it 'should not call xml_text_to_value on the node text if no yield'
      end
    end

    describe 'set_attribute' do
      it 'should do nothing if the attribute is not found'
      it 'should yield and append the result to a collection'
      it 'should yield and set the result if not a collection'
    end
  end
end
