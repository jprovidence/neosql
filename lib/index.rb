module NeoSQL

  class Index

    require 'cgi'

    attr_accessor :template,
                  :provider,
                  :type

    def initialize(h)
      @template = h[:template]
    end

    class << self

      def create(name)

        unless name.kind_of? Hash
          name = {:name => name}
        end

        res = Httpu.post("#{$root_url}/db/data/index/node", name)

        if name.has_key?(:name)
          Index.new(name[:name], res)
        elsif name.has_key?("name")
          Index.new(name["name"], res)
        else
          raise "Index#create must be provided with a name parameter for your index. Eg. {:name => 'idxname'}"
        end

      end


      def create_with(name, config=nil)

        if config.nil? && (name.kind_of?(String) || name.keys.length == 1)
          return create(name)
        end

        if name.kind_of?(Hash) && name.has_key("name")
          other = {}
          name.each do |k, v|
            other[k.intern] = v
          end
          name = other
        end

        if name.kind_of?(String)
          name = {:name => name}
        end

        if config && (config.has_key?(:config) || config.has_key?("config"))
          name.merge!(config)
        elsif config && !(config.has_key?(:config) || config.has_key?("config"))
          name.merge!({:config => config})
        end

        res = Httpu.post("#{$root_url}/db/data/index/node", name) # handles @name@ == full config hash 
        Index.new(name[:name], res)                               # by default        
          
      end


      def delete(index)
        Httpu.delete("#{$root_url}/db/data/index/node/#{index}")
      end


      def list(as_hash=false)

        res = Httpu.get("#{$root_url}/db/data/index/node/")

        if as_hash
          res
        else
          res.map do |i|
            Index.new(i.keys[0], i.values[0])
          end
        end

      end


      def add(index, key, value, node)

        begin
          node = Httpu.resolve_url(node)
          indx = resolve_index_name(index)
          hash = {:key   => key,
                  :value => value,
                  :uri   => node}
          Httpu.post("#{$root_url}/db/data/index/node/#{indx}", hash)
        rescue
          return false
        end

        true

      end


      def remove(index, node, key=nil, value=nil)
        if key.nil? && value.nil?
          remove_with_node(index, node)
        elsif !key.nil? && value.nil?
          remove_with_node_key(index, node, key)
        elsif !key.nil? && !value.nil?
          remove_with_node_key_value(index, node, key, value)
        end
      end


      def remove_with_node(index, node)
        node  = Node.node_number(node)
        index = resolve_index_name(index)
        Httpu.delete("#{$root_url}/db/data/index/node/#{index}/#{node}]")
      end


      def remove_with_node_key(index, node, key)
        node  = Node.node_number(node)
        index = resolve_index_name(index)
        Httpu.delete("#{$root_url}/db/data/index/node/#{index}/#{key}/#{node}")
      end


      def remove_with_node_key_value(index, node, key, value)
        node  = Node.node_number(node)
        index = resolve_index_name(index)
        value = CGI::escape(value)
        Httpu.delete("#{$root_url}/db/data/index/node/#{index}/#{key}/#{value}/#{node}")
      end


      def find(index, kq, value=nil)
        if value.nil?
          find_query(index, kq)
        else
          find_exact(index, kq, value)
        end
      end


      def find_exact(index, key, value)
        index = resolve_index_name(index)
        value = CGI::escape(value)
        res   = Httpu.get("#{$root_url}/db/data/index/node/#{index}/#{key}/#{value}")
        res.map do |r|
          Node.new(r)
        end
      end


      def find_query(index, query)
        query = CGI::escape(query)
        index = resolve_index_name(index)
        res = Httpu.get("#{$root_url}/db/data/index/node/#{index}?query=#{query}")
        res.map do |r|
          Node.new(r)
        end
      end
      alias :find_by_query :find_query


      def resolve_index_name(index)

        str = ""

        if index.kind_of? Index
          str = index.template
        elsif index.kind_of?(String) && index =~ /http/
          str = index
        else
          return index
        end

        str.match(/#{$root_url + "/db/data/index/node/"}(.*?)\/.*/)
        $1
        
      end

    end

  end

end
