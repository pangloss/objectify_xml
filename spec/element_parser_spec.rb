require File.join(File.dirname(__FILE__), 'spec_helper')

describe Objectify::ElementParser do
  class TestElement < Objectify::ElementParser
    attr_accessor :attr

    def initialize(*args)
      yield self if block_given?
      super
    end
  end

  class TestBodyElement < Objectify::ElementParser
    attr_accessor :attr, :inner_html, :inner_text
  end

  describe 'primary_xml_element' do
    before do
      @xml = Nokogiri::XML('<element attr="value" attr2="value2"><div>body</div></element>').child
    end
    it 'should call xml_text_to_value for defined attributes only' do
      TestElement.new(@xml) do |te|
        te.expects(:xml_text_to_value).with('value')
        te.expects(:xml_text_to_value).with('value2').never
      end
    end
    it 'should set inner_html and inner_text if the methods are defined' do
      e = TestBodyElement.new(@xml)
      e.inner_html.should == '<div>body</div>'
      e.inner_text.should == 'body'
    end
    it 'should not set inner_html and inner_text if the methods are not defined' do
      @xml.expects(:inner_html).never
      @xml.expects(:inner_text).never
      e = TestElement.new(@xml)
    end
  end
end
