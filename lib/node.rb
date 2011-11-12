module NeoSQL

  class Node

    attr_accessor :outgoing_relationships_url,
                  :traverse_url,
                  :all_typed_relationships_url,
                  :property_url,
                  :node,
                  :outgoing_typed_relationships_url,
                  :properties_url,
                  :incoming_relationships_url,
                  :create_relationship_url,
                  :paged_traverse_url,
                  :all_relationships_url,
                  :incoming_typed_relationships_url,
                  :data,
                  :extensions,
                  :node_properties,
                  :h


    def initialize(h, auto_define_properties=false)

      h.each do |k, v|
        next if k == :data || k == :extensions
        eval("@#{k}_url = \"#{v}\"")  unless k == :self
      end

      @data            = h[:data]
      @node            = h[:self]
      @node_properties = nil
      @extensions      = h[:extensions]
      @h               = h

      define_properties if auto_define_properties

    end


    def properties
      NodeProperty.new(@self_url)
    end  


    def get(key)
      
      define_properties unless properties_defined?

      if key == :all
        get_all
      else
        @node_properties[key.intern]
      end

    end


    def get_all
      define_properties unless properties_defined?
      @node_properties
    end


    def set(key, val="", destructive=false)

      return set_hash(key, destructive) if key.kind_of? Hash
      @node_properties[key] = val

      if destructive
        NodeProperty.set!(@self_url, key, val)
      else
        NodeProperty.set(@self_url, key, val)
      end

    end


    def set!(key, val="")
      set(key, val, true)
    end


    def set_hash(hash, destructive)

      return set_multiple(hash, destructive) if hash.keys.length > 1

      key = hash.keys[0]
      val = hash.values[1]

      @node_properties[key] = val
      
      if destructive
        NodeProperty.set!(@self_url, key, val)
      else
        NodeProperty.set(@self_url, key, val)
      end

    end


    def set_hash!(hash)
      set_hash(hash, true)
    end


    def set_multiple(hash, destructive)
      if destructive
        @node_properties = NodeProperty.create(@self_url, hash)
        NodeProperty.set_all!(@self_url, hash)
      else
        hash.each do |k, v|
          @node_properties[k] = v
          NodeProperty.set(@self_url, k, v)
        end
      end
    end


    def set_multiple!(hash)
      set_multiple(hash, true)
    end


    def delete_properties
      NodeProperty.delete(@self_url)
    end


    def delete_property(key)

      correct_copy = {}

      @node_properties.each do |k, v|
        correct_copy[k] = v unless k.intern == key.intern
      end

      set_multiple!(correct_copy)

    end

    def [](key)
      get(key)
    end


    def []=(key, val)
      set(key, val)
    end


    def <<(param)
      set(param)
      @node_properties.merge!(param)
    end


    def ==(other)
      
      return false unless other.kind_of? Node

      if other.h == @h && other.node_properties == properties
        true
      else
        false
      end

    end


    def relationships(modifier=:all, params=[])
      case modifier
        when :all            then all_relationships
        when :outgoing       then outgoing_relationships
        when :incoming       then incoming_relationships
        when :all_typed      then all_typed_relationships(params)
        when :outgoing_typed then outgoing_typed_relationships(params)
        when :incoming_typed then incoming_typed_relationships(params)
        else raise "#{modifier} is not a valid relationship request."
      end
    end


    def all_relationships
      Relationship.all(@self_url)
    end


    def outgoing_relationships
      Relationship.outgoing(@self_url)
    end


    def incoming_relationships
      Relationship.incoming(@self_url)
    end


    def all_typed_relationships(types)
      Relationship.typed(@self_url, types)
    end


    def outgoing_typed_relationships(types)
      Relationship.outgoing_typed(@self_url, types)
    end


    def incoming_typed_relationships(types)
      Relationship.incoming_typed(@self_url, types)
    end


    def relationship_with(node, type=nil, data=nil)

      h = {:from => @self_url,
           :to   => node}
      h.merge!({:type => type}) if type
      h.merge!({:data => data}) if data

      Relationship.create(h)

    end


    def delete
      Httpu.delete(@self_url)
    end


    def properties_defined?
      if @node_properties == nil then false else true end
    end


    def define_properties
      @node_properties = NodeProperty.get_all(node)
    end


    def respond_to_missing?(meth, include_private)

      define_properties unless properties_defined?

      if @node_properties.map {|n| n.to_s}.include?(meth.to_s) ||
         @node_properties.map {|n| "#{n}="}.include?(meth.to_s)
        true
      else
        super
      end

    end


    def method_missing(meth, *args)

      define_properties unless properties_defined?

      if @node_properties.map {|n| n.to_s}.include?(meth.to_s)
        get(meth)
      elsif @node_properties.map {|n| "#{n}="}.include?(meth.to_s)
        if args[1] then set(meth.to_s, args[0], args[1]) else set(meth.to_s, args[0]) end
      else
        super
      end

    end


    class << self

      ## create a new node
      def create
        response = Httpu.post("#{$root_url}/db/data/node", {})
        Node.new(response)
      end


      ## create a new node and apply the given properties
      def create_with(properties)
        response = Httpu.post("#{$root_url}/db/data/node", properties)
        Node.new(response)
      end


      ## lookup a specific node in the database
      def get_node(node_id)
        response = Httpu.get("#{$root_url}/db/data/node/#{node_id}")
        Node.new(response)
      end
      alias :retrieve :get_node


      ## delete a the node with the given id
      def delete(node_id)
        Httpu.delete("#{$root_url}/db/data/node/#{node_id}")
      end


      def node_number(node)
        url = Httpu.resolve_url(node)
        url.match(/.*?\/node\/(\d*?)\//)
        $1
      end

    end

  end

end
