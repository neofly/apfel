module Apfel
  require 'json'
  class ParsedDotStrings
    attr_accessor :kv_pairs

    def initialize
      @kv_pairs = []
    end

    def replace_pair(key, value, comment=nil)
      line = Line.new("\"" + key +  "\"=\"" + value + "\";")
      i = kv_pairs.index {|pair| pair.key == key }
      
      old = i != nil ? @kv_pairs[i] : nil
      new = KVPair.new(line, (comment != nil ? comment : (old != nil ? old.comment : nil)))
  
      if i != nil
        @kv_pairs[i] = new
      else
        @kv_pairs.push(new)
      end
    end

    def key_values
      kv_pairs.map do |pair|
        {pair.key => pair.value}
      end
    end

    def keys
      kv_pairs.map do |pair|
        pair.key
      end
    end

    def values
      kv_pairs.map do |pair|
        pair.value
      end
    end

    def comments(args={})
      with_keys = args[:with_keys].nil? ? true : args[:with_keys]
      cleaned_pairs = kv_pairs.map do |pair|
        pair
      end
      with_keys ? build_comment_hash(cleaned_pairs) : cleaned_pairs.map(&:comment)
    end

    def to_hash(args={})
      with_comments = args[:with_comments].nil? ? true : args[:with_comments]

      build_hash { |hash, pair|
      hash_value = with_comments ? { pair.value => pair.comment } : pair.value
        hash[pair.key] = hash_value
      }
    end

    def to_json(args={})
      self.to_hash(with_comments: args[:with_comments]).to_json
    end

    def to_s(args={})
      with_comments = args[:with_comments].nil? ? true : args[:with_comments]
      s = ""
      
      kv_pairs.each do |pair|
        s << "/* " + pair.comment.to_s + " */\n" if with_comments
        s << pair.line.to_s + "\n"
      end
      
      return s
    end

    private

      def build_comment_hash(kv_pairs)
        build_hash { |hash, pair|
          hash[pair.key] = pair.comment
        }
      end

      def build_hash(&block)
        hash = {}
        kv_pairs.each do |pair|
          yield hash, pair
        end
        hash
      end

  end
end
