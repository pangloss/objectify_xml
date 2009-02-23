require File.join(File.dirname(__FILE__), 'spec_helper')

describe Objectify::Xml do
  describe 'initialize' do
    describe 'with nil' do
      it 'should handle nil string'
      it 'should assign the parent'
      it 'should initialize the attributes'
    end

    describe 'with ""' do
      it 'should call primary_xml_element with a Nokogiri XML object'
    end
    describe 'with valid xml' do
      it 'should call primary_xml_element with a Nokogiri XML object'
    end
  end

  describe 'xml_text_to_value' do
    it 'should cast true'
    it 'should cast false'
    it 'should cast integer'
    it 'should cast float'
    it 'should cast date1'
    it 'should cast date2'
    it 'should cast date3'
    it 'should cast date4'
    it 'should not cast anything else'
  end
end
