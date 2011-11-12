module NeoSql

  class NodeProperty

    attr_accessor :node

    def initialize(node=nil)
      @node = node if node
    end


    def get(key)
      if key.intern == :all
        NodeProperty.get_all(@node)
      else
        NodeProperty.get(@node, key)
      end
    end


    def get_all
      NodeProperty.get_all(@node)
    end


    def set(key, val="", destructive=false)

      return set_hash(key, destructive) if key.kind_of? Hash

      if destructive
        NodeProperty.set!(@node, key, val)
      else
        NodeProperty.set(@node, key, val)
      end

    end


    def set!(key, val="")
      set(key, val, true)
    end
    alias :update :"set!"


    def set_hash(hash, destructive=false)
      
      return set_multiple(hash, destructive) if hash.keys.length > 1

      key = hash.keys[0]
      val = hash.values[0]

      if destructive
        NodeProperty.set!(@node, key, val)
      else
        NodeProperty.set(@node, key, val)
      end

    end


    def set_hash!(hash)
      set_hash(hash, true)
    end


    def set_multiple(hash, destrucive=false)
      if destructive
        NodeProperty.set_all!(@node, hash)
      else
        hash.each do |k, v|
          NodeProperty.set(@node, k, v)
        end
      end
    end


    def set_multiple!(hash)
      set_multiple(hash, true)
    end


    def delete_properties
      NodeProperty.delete(@node)
    end
    alias :delete_all :delete_properties


    def delete_property(key)

      correct_copy = {}

      get_all.each do |k, v|
        correct_copy[k] = v unless key.intern == k.intern
      end

      set_multiple!(correct_copy)

    end
    alias :delete :delete_property


    def each
      get_all.each do |k, v|
        yield k, v
      end 
    end


    def each_key
      get_all.each_key do |k|
        yield k
      end
    end


    def each_value
      get_all.each_value do |v|
        yield v
      end
    end


    def [](key)
      get(key)
    end


    def []=(key, val)
      set(key, val)
    end


    def <<(param)
      set(param)
    end


    def method_missing(meth, *args)

      properties = get_all

      if properties.keys.map {|k| k.to_s}.include?(meth.to_s)
        get(meth)
      elsif properties.keys.map {|k| "#{k}="}.include?(meth.to_s)
        
        if args[0] && args[0] == true
          set!(meth)
        else
          set(meth)
        end

      end
    end


    class << self

      def create(node, hash)
        node &&= Httpu.resolve_url(node)
        Httpu.put("#{node}/properties", hash)
      end


      def get(node, key)
        node &&= Httpu.resolve_url(node)
        Httpu.get("#{node}/properties/#{key}")
      end


      def get_all(node)
        node &&= Httpu.resolve_url(node)
        Httpu.get("#{node}/properties")
      end


      def set(node, key, val)
        raise "#{key} cannot be nil/null." if key == nil
        node &&= Httpu.resolve_url(node)
        Httpu.put("#{node}/properties/#{key}", val)
      end


      def set!(node, key, val)
        raise "#{key} cannot be nil/null." if key == nil
        node &&= Httpu.resolve_url(node)
        Httpu.put("#{node}/properties", {key.intern => val})
      end
      alias :update :"set!"


      def set_all!(node, hash)
        node &&= Httpu.resolve_url(node)
        Httpu.put("#{node}/properties", hash)
      end


      def delete(node)
        node &&= Httpu.resolve_url(node)
        Httpu.delete("#{node}/properties")
      end

    end

  end


  class RelationshipProperty

    class << self

      def get(rel, key)
        rel &&= Httpu.resolve_url(rel))
        Httpu.get("#{rel}/properties/#{key}")
      end


      def get_all(rel)
        rel &&= Httpu.resolve_url(rel)
        Httpu.get("#{rel}/properties")
      end
        

      def set(rel, key, val)
        rel &&= Httpu.resolve_url(rel)
        copy = get_all(rel)
        copy[key.intern] = val
        Httpu.put("#{rel}/properties", copy)
      end


      def set!(rel, key, val)
        rel &&= Httpu.resolve_url(rel)
        Httpu.put("#{rel}/properties", {key.intern => val})
      end


      def set_hash(rel, hash)

        rel &&= Httpu.resolve_url(rel)
        copy = get_all(rel)

        hash.each do |k, v|
          copy[k.intern] = v
        end

        Httpu.put("#{rel}/properties", hash)

      end


      def set_hash!(rel, hash)
        rel &&= Httpu.resolve_url(rel)
        Httpu.put("#{rel}/properties", hash)
      end


      def delete_all(rel)
        rel &&= Httpu.resolve_url(rel)
        Httpu.delete("#{rel}/properties")
      end


      def delete(rel, key)
        rel &&= Httpu.resolve_url(rel)
        Httpu.delete("#{rel}/properties/#{key}")
      end
        
    end

  end

end
