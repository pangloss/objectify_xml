module Objectify
  class Xml
    module Dsl
      def self.extended(target)
        target.init
      end

      def init
        parent = ancestors[1]
        unless /Xml|ElementParser|DocumentParser/ =~ parent.name
          @collections = parent.instance_variable_get('@collections') || []
          @attributes = parent.instance_variable_get('@attributes') || []
          @flatten = parent.instance_variable_get('@flatten') || []
          @namespaces = parent.instance_variable_get('@namespaces') || []
          @types = parent.instance_variable_get('@types') || {}
        else
          @collections = []
          @attributes = []
          @flatten = []
          @namespaces = []
          @types = {}
        end
      end

      def has_one(name, type, qualified_name)
        set_type(qualified_name, type)
      end

      def has_many(name, type, qualified_name)
        @collections << qualified_name.to_s
        set_type(qualified_name, type)
        attribute name, true
      end

      def attributes(*names)
        names.each { |n| attribute n }
        @attributes
      end

      def attribute(name, collection = false)
        name = name.to_s.underscore
        @attributes << name
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
        @flatten << qualified_name
      end

      def flatten?(qualified_name)
        @flatten.include? qualified_name
      end

      def namespace?(namespace)
        @namespaces.include? namespace
      end

      def namespaces(*namespaces)
        @namespaces += namespaces
      end

      def attribute_type(qualified_name)
        type = @types[qualified_name]
        if type and not type.is_a? Class
          type = type.to_s.constantize rescue nil
          type ||= type.to_s.
            split(/::/).reject { |n| n.blank? }.
            inject(self) { |p, n| p.const_get(n) }
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
        [@attributes, @collections, @flatten, @namespaces, @types]
      end
    end
  end
end
