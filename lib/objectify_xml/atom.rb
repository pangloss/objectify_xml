module Objectify
  # Given as an example of usage, but fully functional. Must be required
  # separately: require 'objectify/atom'
  module Atom
    #  attributes :rel, :type, :href
    class Link < ElementParser
      attributes :rel, :type, :href
    end


    # attributes :scheme, :term
    class Category < ElementParser
      attributes :scheme, :term
    end


    # attributes :type, :xml_lang, :xml_base, :src, :inner_html
    class Content < ElementParser
      attributes :type, :xml_lang, :xml_base, :src, :inner_html
    end


    # attributes :version, :uri, :inner_text
    class Generator < ElementParser
      attributes :version, :uri, :inner_text
    end


    # The root object of an Atom feed.
    #
    #   attributes :id,
    #     :published,
    #     :updated,
    #     :title,
    #     :subtitle,
    #     :rights,
    #     :icon
    #   has_many :links, :Link, 'link'
    #   has_many :entries, :Entry, 'entry'
    #   has_one :generator, Generator, 'generator'
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


    # The feed has a collection of entries.
    #
    #   attributes :id,
    #     :published,
    #     :updated,
    #     :title,
    #     :summary
    #   has_many :links, Link, 'link'
    #   has_one :category, Category, 'category'
    #   has_many :contents, Content, 'content'
    #   has_one :author, :Author, 'author'
    #   has_many :contributors, :Contributor, 'contributor'
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


    # attributes :name, :uri, :email
    class Author < DocumentParser
      attributes :name, :uri, :email
    end


    # attributes :name
    class Contributor < DocumentParser
      attributes :name
    end
  end
end
