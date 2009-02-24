module Objectify
  class Xml
    module Dsl
      def self.extended(target)
        target.init
      end

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

      def has_one(name, type, qualified_name)
        set_type(qualified_name, type)
        attribute name, qualified_name
      end

      def has_many(name, type, qualified_name)
        set_type(qualified_name, type)
        attribute name, qualified_name, true
      end

      def attributes(*names)
        names.each { |n| attribute n }
        @attributes + @qualified_attributes.keys
      end

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

      def flatten(qualified_name)
        @flatten << qualified_name.to_s
      end

      def flatten?(qualified_name)
        @flatten.include? qualified_name
      end

      def namespace?(namespace)
        @namespaces.keys.include? namespace
      end

      def namespaces(*namespaces)
        namespaces.each do |ns|
          namespace ns
        end
        @namespaces
      end

      def default_namespace(url)
        @namespaces[''] = url
      end

      def namespace(name = nil, url = nil)
        @namespaces[name.to_s] = url
      end

      def find_namespace(name = '')
        @namespaces[name]
      end

      def attribute_type(qualified_name)
        type = @types[qualified_name]
        if type and not type.is_a? Class
          type_name = type.to_s
          begin
            type = type_name.constantize
          rescue
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
          end
          if type.nil?
            raise "Unable to instantiate the constant '#{ type_name }'."
          end
          @types[qualified_name] = type
        end
        type
      end

      def set_type(qualified_name, type)
        @types[qualified_name] = type
      end

      def collection?(qualified_name)
        @collections.include?(qualified_name)
      end

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
