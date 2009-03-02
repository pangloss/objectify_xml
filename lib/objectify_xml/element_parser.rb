module Objectify
  class ElementParser < Xml
    # Stores the xml element's attribute values, inner_text and inner_html if
    # they are defined.
    #
    # Attributes can be defined either with the attribute dsl method or by
    # defining a name= method in the object.
    def primary_xml_element(xml)
      xml.attributes.keys.each do |name|
        method = "#{ name }="
        if respond_to? method
          send(method, xml_text_to_value(xml[name]))
        end
      end
      if respond_to? :inner_html=
        self.inner_html = xml.inner_html
      end
      if respond_to? :inner_text=
        self.inner_text = xml.inner_text
      end
    end
  end
end
