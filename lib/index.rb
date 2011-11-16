module NeoSQL

  class Index

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


      def resolve_index_name(index)

        str = ""

        if index.kind_of? Index
          str = index.template
        elsif index.kind_of?(String) && index =~ /http/
          str = index
        else
          return index
        end

        str.match(/#{$root_url + "/db/data/index/node/"}(.*?)\/.*/, '')
        $1
        
      end

    end

  end

end
