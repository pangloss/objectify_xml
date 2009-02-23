module Objectify
  class DocumentParser < Xml
    # The entry point to the parser, normally called by initialize after the 
    # initialization is complete.
    def primary_xml_element(xml)
      parse_xml(xml.child)
    end

    private

    def qualified_name(x)
      qn = x.name
      qn = "#{ x.namespace }:#{ x.name }" if x.namespace
      qn
    end

    def attribute_type(x)
      self.class.attribute_type qualified_name(x)
    end

    def flatten?(x)
      self.class.flatten?(qualified_name(x))
    end

    def collection?(x)
      self.class.collection?(qualified_name(x))
    end

    def namespace?(x)
      if x.namespace
        self.class.namespace?(x.namespace)
      else
        true
      end
    end

    def attribute(x)
      self.class.find_attribute(qualified_name(x), x.namespace, x.name)
    end

    def parse_xml(xml)
      while xml
        read_xml_element(xml)
        xml = xml.next
      end
    end

    def read_xml_element(x)
      return if x.is_a? Nokogiri::XML::Text
      return unless namespace?(x)
      if flatten?(x)
        parse_xml(x.child)
      elsif type = attribute_type(x)
        set_attribute(x) { type.new(x, self) }
      else
        set_attribute(x) { xml_text_to_value(x.text) }
      end
    end

    def set_attribute(x)
      if attr_name = attribute(x)
        if collection?(x)
          send(attr_name) << yield
        else
          send("#{attr_name}=", yield)
        end
      end
    end
  end
end
