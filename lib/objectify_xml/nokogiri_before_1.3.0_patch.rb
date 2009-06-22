# nokogiri 1.3.0 change namespace from a string to an object.
# so all references to namespace should be replace by namespace.prefix
# objectify_xml works by default with nokogiri >= 1.3.0,
# so this patch is loaded only with nokogiri < 1.3.0
module Objectify
  # 
  class DocumentParser < Xml
    # Returns the given element's name as it would appear in the xml document,
    # including namespace if present.
    def qualified_name(x)
      qn = x.name
      qn = "#{ x.namespace }:#{ x.name }" if x.namespace
      qn
    end

    # Returns boolean to indicate if the given element's namespace is supported.
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
  end
end