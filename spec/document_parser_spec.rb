require File.join(File.dirname(__FILE__), 'spec_helper')

describe Objectify::DocumentParser do
  class D < Objectify::DocumentParser
    def initialize; end
    public *private_instance_methods.map { |s| s.to_sym }
  end

  before do
    @author = Nokogiri::XML('<author><name>Joe</name></author>').child
  end

  describe 'primary_xml_element' do
    it 'should call parse_xml' do
      d = D.new
      d.expects(:parse_xml).with(@author.child)
      d.primary_xml_element(@author)
    end
  end

  describe 'xml helpers' do
    before do
      @title = Nokogiri::XML('<title>Joe</title>').child
      @isbn = Nokogiri::XML('<entry xmlns:book="http://example.com"><book:isbn>123</book:isbn></entry>').child.child
      @generator = Nokogiri::XML('<generator type="friendly">Mr. Happy</title>').child
    end

    describe 'qualified_name' do
      it 'should return name with just name' do
        D.new.qualified_name(@author).should == 'author'
      end

      it 'should return namespace:name with name and namespace' do
        D.new.qualified_name(@isbn).should == 'book:isbn'
      end
    end

    describe 'delegate methods' do
      it 'attribute_type' do
        D.expects(:attribute_type).with('title').returns(:result)
        D.new.attribute_type(@title).should == :result
      end
      it 'flatten?' do
        D.expects(:flatten?).with('title').returns(:result)
        D.new.flatten?(@title).should == :result
      end
      it 'collection?' do
        D.expects(:collection?).with('title').returns(:result)
        D.new.collection?(@title).should == :result
      end
      it 'attribute' do
        D.expects(:find_attribute).with('book:isbn', 'book', 'isbn').returns(:result)
        D.new.attribute(@isbn).should == :result
      end
    end

    describe 'namespace?' do
      it 'should delegate if the element has a namespace' do
        d = D.new
        d.class.expects(:namespace?).with('book').returns(:result)
        d.namespace?(@isbn).should == :result
      end

      it 'should just return true if no namespace' do
        d = D.new
        d.class.expects(:namespace?).never
        d.namespace?(@title).should be_true
      end
    end

    describe 'parse_xml' do
      it 'should call read_xml_element on each xml sibling node' do
        xml2 = mock('xml2', :next => nil)
        xml = mock('xml1', :next => xml2)
        d = D.new
        d.expects(:read_xml_element).with(xml)
        d.expects(:read_xml_element).with(xml2)
        d.parse_xml(xml)
      end
    end

    describe 'read_xml_element' do
      class FlattenAuthor < D
        flatten :author
        attribute :name
      end

      it 'should skip text elements' do
        d = D.new
        d.expects(:set_attribute).never
        @title.child.should be_an_instance_of(Nokogiri::XML::Text)
        d.read_xml_element(@title.child)
      end

      it 'should skip elements in the wrong namespace' do
        d = D.new
        d.expects(:set_attribute).never
        d.read_xml_element(@isbn)
      end

      it 'should call parse_xml on the first child node of a flattened element' do
        e = FlattenAuthor.new
        e.flatten?(@author).should be_true
        e.expects(:parse_xml).with(@author.child)
        e.read_xml_element(@author)
      end

      describe 'with an attribute type' do
        class HasAuthor < D
          has_one 'author', Objectify::Atom::Author, 'author'
        end
        it 'should set the attribute' do
          e = HasAuthor.new
          e.attribute_type(@author).should == Objectify::Atom::Author
          e.expects(:author=).with(instance_of(Objectify::Atom::Author))
          e.read_xml_element(@author)
        end
      end

      describe 'without an attribute type' do
        it 'should set the attribute' do
          e = FlattenAuthor.new
          e.expects(:xml_text_to_value).with('Joe').returns(43)
          e.expects(:name=).with(43)
          e.read_xml_element(@author)
        end
      end
   end

    describe 'set_attribute' do
      it 'should do nothing if the attribute is not found' do
        d = D.new
        d.expects(:attribute).with(:xml).returns(nil)
        d.set_attribute(:xml) do
          fail "Shouldn't get here"
        end
      end
      it 'should yield and append the result to a collection' do
        d = D.new
        d.expects(:attribute).with(:xml).returns('attr_name')
        d.expects(:collection?).with(:xml).returns(true)
        array = []
        d.expects(:attr_name).returns(array)
        d.set_attribute(:xml) { :value }
        array.should == [:value]
      end
      it 'should yield and set the result if not a collection' do
        d = D.new
        d.expects(:attribute).with(:xml).returns('attr_name')
        d.expects(:collection?).with(:xml).returns(false)
        d.expects(:attr_name=).with(:value)
        d.set_attribute(:xml) { :value }
      end
    end
  end
end
