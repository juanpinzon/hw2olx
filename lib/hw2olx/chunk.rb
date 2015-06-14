require 'rexml/document'

class Hw2Olx
  class Chunk
    require_relative 'autograder_chunk'
    require_relative 'vertical_chunk'

    # Encapsulates a chunk of content that will become part of a Vertical.
    
    # +type+ may be one of +:autograder+, +:ruql+, or +:html+
    attr_reader :type

    # The raw data before any processing happens
    attr_accessor :raw_data

    # The final output XML data
    attr_accessor :output

    # The display name, usually from +data-display-name+ attribute
    attr_accessor :display_name

    # One or more child chunks (recursive data structure)
    attr_accessor :chunks

    # A randomly-generated ID string used as edX object identifier
    def id
      @id ||= Chunk.random_id
    end

    @@part_counter = 1
    
    def initialize(raw_data='', display_name='')
      @raw_data = raw_data
      @display_name = display_name
      @output = ''
      @xml = Builder::XmlMarkup.new(:target => @output, :indent => 2)
    end

    def type
      self.class.to_s.split('::').last.downcase.gsub(/chunk$/, '').to_sym
    end
    
    # Return file path relative to current directory
    def file_path
      "studio/#{type}/#{id}.xml"
    end

    protected

    def self.name_for(elt)
      if (name = elt.attribute('data-display-name'))
        name.to_s
      else
        @@part_counter += 1
        "Part #{@@part_counter}"
      end
    end

    def self.random_id
      Array.new(4) { sprintf("%08x", rand(2**32)) }.join('')
    end

    public

    def write_self!
      File.open(file_path, "w") do |f|
        f.write self.to_edxml
      end
    end

  end

  class HtmlChunk < Chunk
    def initialize
      super('', '')
    end
    def append_content(elt)
      @raw_data << elt.to_s
    end
    def to_edxml
      @raw_data
    end
  end

  class RuqlChunk < Chunk
    def initialize(elt)
      super(elt.texts.join(''), Chunk.name_for(elt))
    end
    def type ; :problem ; end
    def to_edxml
      "(RuQL support pending)"
    end
  end

end
