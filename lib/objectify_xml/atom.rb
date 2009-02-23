module Objectify
  module Atom
    class Link < ElementParser
      attributes :rel, :type, :href
    end


    class Category < ElementParser
      attributes :scheme, :term
    end


    class Content < ElementParser
      attributes :type, :xml_lang, :xml_base, :src, :inner_html
    end


    class Generator < ElementParser
      attributes :version, :uri, :inner_html
    end


    class Feed < DocumentParser
      attributes :id,
        :published,
        :updated,
        :title,
        :subtitle,
        :rights,
        :icon
      has_many :links, :Link, 'link'
      has_many :entries, :Entry, 'entry'
      has_one :generator, Generator, 'generator'
    end


    class Entry < DocumentParser
      attributes :id,
        :published,
        :updated,
        :title,
        :summary
      has_many :links, Link, 'link'
      has_one :category, Category, 'category'
      has_many :contents, Content, 'content'
      has_one :author, :Author, 'author'
      has_many :contributors, :Contributor, 'contributor'
    end


    class Author < DocumentParser
      attributes :name, :uri, :email
    end


    class Contributor < DocumentParser
      attributes :name
    end
  end
end
