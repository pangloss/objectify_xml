= Objectify::Xml

* http://github.com/pangloss/objectify_xml

== DESCRIPTION:

Provides an easy to use DSL resembling ActiveRecord for defining objects
representing any XML document, including deeply nested ones. This project was
extracted from my ruby-picasa gem. You can find ruby-picasa at
http://github.com/pangloss/ruby_picasa or available as a gem.

The project also has significant (if not complete) Atom support.

== FEATURES:

* Capture and typecast standard attributes
* Define both has_one and has_many nested element 'associations'
* Significant (if not full) namespace support
* Cleanly ignore unknown attributes and namespaces
* Support documents that nest data unnecessarily without creating bogus
  associated objects.
* Inheritable object definitions

== PROBLEMS:

* None known.

== SYNOPSIS:

The following are functioning early definitions for some of the objects used in
ruby-picasa in their entirety:

require 'objectify_xml'
require 'objectify_xml/atom' 
module RubyPicasa
  class PhotoUrl < Objectify::Xml::ElementParser
    attr_accessor :url, :height, :width
  end

  class Album < Objectify::Xml::DocumentParser
    attributes :id,
      :published,
      :updated,
      :title,
      :summary,
      :rights,
      :gphoto_id,
      :name,
      :access,
      :numphotos, 
      :total_results, 
      :start_index,
      :items_per_page,
      :allow_downloads
    has_many :links, Objectify::Atom::Link, 'link'
    has_many :entries, :Photo, 'entry'
    has_one :content, PhotoUrl, 'media:content'
    has_many :thumbnails, PhotoUrl, 'media:thumbnail'
    flatten 'media:group'
    namespaces %w[openSearch gphoto media]
  end

  class Photo < Objectify::Xml::DocumentParser
    attributes :id,
      :published,
      :updated,
      :title,
      :summary,
      :gphoto_id,
      :version, 
      :position,
      :albumid,
      :width,
      :height,
      :description,
      :keywords
    has_many :links, Objectify::Atom::Link, 'link'
    has_one :content, PhotoUrl, 'media:content'
    has_many :thumbnails, PhotoUrl, 'media:thumbnail'
    namespaces %w[gphoto media]
    flatten 'media:group'
  end
end


== REQUIREMENTS:

* nokogiri
* activeresource

== INSTALL:

* Installable either as a gem or vendored into a project.
* gem install objectify-xml
* gem install pangloss-objectify-xml --source http://gems.github.com

== LICENSE:

(The MIT License)

Copyright (c) 2009 Darrick Wiebe

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
