require File.join(File.dirname(__FILE__), 'spec_helper')

describe Objectify::Xml do
  class Xml < Objectify::Xml
    def initialize(*args)
      yield self if block_given?
      super
    end
    public :xml_text_to_value
  end

  describe 'initialize' do
    describe 'with nil' do
      it 'should handle nil string' do
        Xml.new(nil) do |x|
          x.expects(:primary_xml_element).never
        end
      end
      it 'should assign the parent' do
        x = Xml.new(nil, :parent)
        x.parent.should == :parent
      end
      it 'should initialize the attributes' do
        x = Xml.new(nil)
        x.attributes.should == {}
      end
    end

    describe 'with multiple nodes before the first element' do
      it 'should call parse_xml with the first element' do
        xml_string = <<-exml
<?xml version="1.0"?>
<?xml-stylesheet type="text/css" href="http://en.wikipedia.org/skins-1.5/common/feed.css?206xx"?>
<feed xmlns="http://www.w3.org/2005/Atom" xml:lang="en"></feed>
        exml
        xml = Nokogiri::XML(xml_string).child.next
        x = Xml.new(xml_string) do |x|
          def x.primary_xml_element(xml)
            xml.name.should == 'feed'
            @parent = :called
          end
        end
        x.parent.should == :called
      end
    end

    describe 'with ""' do
      it 'should call primary_xml_element with a Nokogiri XML object' do
        Xml.new('') do |x|
          x.expects(:primary_xml_element)
        end
      end
    end
    describe 'with valid xml' do
      it 'should call primary_xml_element with a Nokogiri XML object' do
        Xml.new('<foo><bar>no</bar></foo>') do |x|
          x.expects(:primary_xml_element)
        end
      end
    end
  end

  describe 'inspect' do
    it 'should work' do
      f = Objectify::Atom::Feed.new(sample_feed('wikipedia.atom'))
      f.inspect.should == '<Objectify::Atom::Feed title, id, subtitle, links:2, generator:Objectify::Atom::Generator, entries:50, updated>'
    end
  end

  describe 'xml_text_to_value' do
    it('should cast true') { Xml.new('').xml_text_to_value('true').should == true }
    it('should cast false') { Xml.new('').xml_text_to_value('false').should == false }
    it('should cast integer') { Xml.new('').xml_text_to_value('12').should == 12 }
    it('should cast float') { Xml.new('').xml_text_to_value('3.5').should == 3.5 }
    it('should cast date1') { Xml.new('').xml_text_to_value('2009-02-01T11:32:11.03Z').should be_an_instance_of(DateTime) }
    it('should cast date2') { Xml.new('').xml_text_to_value('2009-02-01T11:32:11+400Z').should be_an_instance_of(DateTime) }
    it('should cast date3') { Xml.new('').xml_text_to_value('2009-02-01T11:32:11').should be_an_instance_of(DateTime) }
    it('should cast date4') { Xml.new('').xml_text_to_value('2009-02-01').should be_an_instance_of(DateTime) }
    it('should not cast anything else') { Xml.new('').xml_text_to_value('anything').should == 'anything' }
  end
end
