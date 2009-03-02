module Objectify
  # 
  class DocumentParser < Xml
    # The entry point to the parser, normally called by initialize after the 
    # initialization is complete.
    def primary_xml_element(xml)
      parse_xml(xml.child)
    end

    private

    # Returns the given element's name as it would appear in the xml document,
    # including namespace if present.
    def qualified_name(x)
      qn = x.name
      qn = "#{ x.namespace }:#{ x.name }" if x.namespace
      qn
    end

    # Returns the type of the element's association if one is defined, otherwise nil.
    def attribute_type(x)
      self.class.attribute_type qualified_name(x)
    end

    # Returns boolean to indicate if the children of the element should be
    # treated as part of the current object's data.
    def flatten?(x)
      self.class.flatten?(qualified_name(x))
    end

    # Returns boolean to indicate if the given element is defined as being one
    # member of a collection.
    def collection?(x)
      self.class.collection?(qualified_name(x))
    end

    # Returns boolean to indicate if the given element's namespace is supported.
    def namespace?(x)
      if x.namespace
        self.class.namespace?(x.namespace)
      else
        true
      end
    end

    # Returns the attribute name representing the given element. If the element
    # is not defined, returns nil.
    def attribute(x)
      self.class.find_attribute(qualified_name(x), x.namespace, x.name)
    end

    # Parses the given xml element and all of its siblings.
    def parse_xml(xml)
      while xml
        read_xml_element(xml)
        xml = xml.next
      end
    end

    # Processes the given element and stores the resultant value if it is
    # a defined attribute or association.
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

    # Stores the value of the given attribute or association if it is defined.
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
