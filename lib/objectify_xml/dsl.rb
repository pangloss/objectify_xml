module Objectify
  class Xml
    module Dsl
      def self.extended(target)
        target.init
      end

      # Initializes required metadata variables when the module is included in a
      # class or a class is inherited.
      def init
        parent = ancestors[1]
        unless /^Objectify::(Xml|ElementParser|DocumentParser)$/ =~ parent.name
          @collections = parent.instance_variable_get('@collections').clone || []
          @attributes = parent.instance_variable_get('@attributes').clone || []
          @qualified_attributes = parent.instance_variable_get('@qualified_attributes').clone || {}
          @flatten = parent.instance_variable_get('@flatten').clone || []
          @namespaces = parent.instance_variable_get('@namespaces').clone || {}
          @types = parent.instance_variable_get('@types').clone || {}
        else
          @collections = []
          @attributes = []
          @qualified_attributes = {}
          @flatten = []
          @namespaces = {}
          @types = {}
        end
      end

      # Define a typed association attribute. The type should be derived from
      # either DocumentParser or ElementParser.
      #
      # If the type has not yet been defined at the point that the declaration
      # is made, a String or Symbol may be used and will be looked up from
      # the scope that the declaration is made in.
      def has_one(name, type, qualified_name)
        set_type(qualified_name, type)
        attribute name, qualified_name
      end

      # Define an attribute as a collection of typed associations. The type
      # should be derived from either DocumentParser or ElementParser.
      #
      # If the type has not yet been defined at the point that the declaration
      # is made, a String or Symbol may be used and will be instantiated from
      # the scope that the declaration is made in.
      def has_many(name, type, qualified_name)
        set_type(qualified_name, type)
        attribute name, qualified_name, true
      end

      # Define a list of simple attributes.
      def attributes(*names)
        names.each { |n| attribute n }
        @attributes + @qualified_attributes.keys
      end

      # Define a simple attribute or collection of simple attributes. This
      # method can be used if the desired attribute name is different from the
      # xml element name by specifying a qualified name.
      def attribute(name, qualified_name = nil, collection = false)
        name = name.to_s.underscore
        @qualified_attributes[qualified_name] = name if qualified_name
        @collections << (qualified_name || name).to_s if collection
        @attributes << name unless qualified_name
        module_eval %{
          def #{name}=(value)
            @attributes['#{name}'] = value
          end
          def #{name}
            @attributes['#{name}']#{ collection ? ' ||= []' : '' }
          end
        }
        name
      end

      # Used internally to find the name of an attribute based on the name of
      # the xml element.
      def find_attribute(qualified_name, namespace, name)
        if qname = @qualified_attributes[qualified_name]
          return qname
        end
        names = []
        plural = collection?(qualified_name)
        if plural
          if namespace
            names << "#{ namespace }_#{ name.pluralize }"
          end
          names << name.pluralize
        end
        if namespace
          names << "#{ namespace }_#{ name }"
        end
        names << name
        names.map { |n| n.underscore }.find do |n|
          @attributes.include? n.underscore
        end
      end

      # Specify that an element should be recursed into while still associating
      # its child elements with the current object.
      def flatten(qualified_name)
        @flatten << qualified_name.to_s
      end

      # Used internally to determine whether an element has been flattened.
      def flatten?(qualified_name)
        @flatten.include? qualified_name
      end

      # Used internally to determine whether a namespace is supported.
      def namespace?(namespace)
        @namespaces.keys.include? namespace
      end

      # Specify a list of supported namespaces.
      def namespaces(*namespaces)
        namespaces.each do |ns|
          namespace ns
        end
        @namespaces
      end

      # Specify the url of the default namespace.
      def default_namespace(url)
        @namespaces[''] = url
      end

      # Specify a namespace with its url.
      def namespace(name = nil, url = nil)
        @namespaces[name.to_s] = url
      end

      # Return the url (if any) associated with a namespace.
      def find_namespace(name = '')
        @namespaces[name]
      end

      # Returns the attribute type associated to an element name if any.
      #
      # Searches up the defining object's namespace to the root namespace for
      # the definition of the constant.
      def attribute_type(qualified_name)
        type = @types[qualified_name]
        if type and not type.is_a? Class
          type_name = type.to_s
          type = nil
          # Try to search the current object's namespace explicitly
          sections = self.name.split(/::/)
          while sections.length > 1
            sections.pop
            begin
              sections.push(type_name)
              type = sections.join('::').constantize
              break
            rescue
              sections.pop
            end
          end
          if type.nil?
            type = type_name.constantize rescue nil
          end
          if type.nil?
            raise "Unable to instantiate the constant '#{ type_name }'."
          end
          @types[qualified_name] = type
        end
        type
      end

      # Sets the associated type of an attribute. Generally used only internally
      # via has_one or has_many.
      def set_type(qualified_name, type)
        @types[qualified_name] = type
      end

      # Used internally to determine whether an element is represented by a
      # collection.
      def collection?(qualified_name)
        @collections.include?(qualified_name)
      end

      # Return the object's metadata for testing and debugging purposes.
      def metadata
        { :attributes => @attributes, 
          :qualified_attributes => @qualified_attributes, 
          :collections => @collections, 
          :flatten => @flatten, 
          :namespaces => @namespaces, 
          :types => @types }
      end
    end
  end
end
