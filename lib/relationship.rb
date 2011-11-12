module NeoSQL

  class Relationship

    attr_accessor :from_node_url,
                  :to_node_url,
                  :self_url,
                  :property_url,
                  :properties_url,
                  :data,
                  :type,
                  :extensions,
                  :properties


    def initialize(h)

      @from_node_url  = h[:start]
      @to_node_url    = h[:end]
      @self_url       = h[:self]
      @property_url   = h[:property]
      @properties_url = h[:properties]

      @type       = h[:type]
      @data       = h[:data]
      @extensions = h[:extensions]
      @properties = {}

    end


    def start_node
      num = Node.node_number(@from_node_url)
      Node.get_node(num)
    end
    alias :from :start_node


    def end_node
      num = Node.node_number(@to_node_url)
      Node.get_node(num)
    end
    alias :to :end_node


    def properties
      RelationshipProperties.get_all(@self_url)
    end


    def property(key)
      RelationshipProperties.get(@self_url, key)
    end


    class << self

      def retrieve(url)
        Httpu.get(url).map {|rel| Relationship.new(rel)}
      end


      def create(h)
        
        if h[:from].nil? || h[:to].nil?
          raise "Both start and end node must be specified to create a relationship"
        end

        from_url = Httpu.resolve_url h[:from]
        to_url   = Httpu.resolve_url h[:to]

        template        = {}
        template[:to]   = to_url
        template[:type] = h[:type] if h[:type]
        template[:data] = h[:data] if h[:data]
        
        response = Httpu.post("#{from_url}/relationships", template)
        Relationship.new(response)
      
      end


      def delete(relationship)
        r = resolve_url relationship
        Httpu.delete(r)
      end


      def all(node)
        
        r   = "#{Httpu.resolve_url node}/relationships/all"
        ary = Httpu.get(r).map {|rel| Relationship.new(rel)}

        def ary.incoming
          return Relationship.incoming(node)
        end
        
        def ary.outgoing
          return Relationship.outgoing(node)
        end

        def ary.typed(types)
          return Relationship.typed(node, types)
        end

        def ary.incoming_typed(types)
          return Relationship.incoming_typed(node, types)
        end

        def ary.outgoing_typed(types)
          return Relationship.outgoing_typed(node, types)
        end

        ary

      end


      def incoming(node)

        r   = "#{Httpu.resolve_url node}/relationships/in"
        ary = Httpu.get(r).map {|rel| Relationship.new(rel)}

        def ary.typed(types)
          return Relationship.incoming_typed(node, types)
        end

        ary

      end


      def outgoing(node)
        
        r = "#{Httpu.resolve_url node}/relationships/out"
        ary = Httpu.get(r).map {|rel| Relationship.new(rel)}

        def ary.typed(types)
          return Relationship.outgoing_typed(node, types)
        end

        ary

      end


      def typed(node, types)

        types = types.join('&')
        r     = "#{Httpu.resolve_url node}/relationships/all/#{types}"
        ary   = Httpu.get(r).map {|rel| Relationship.new(rel)}
        
        def ary.incoming
          return Relationship.incoming_typed(node, types)
        end

        def ary.outgoing
          return Relationship.outgoing_typed(node, types)
        end

        ary

      end


      def incoming_typed(node, types)
        types = types.join('&')
        r = "#{Httpu.resolve_url node}/relationships/in/#{types}"
        Httpu.get(r).map{|rel| Relationship.new(rel)}
      end


      def outgoing_typed(node, types)
        types = types.join('&')
        r = "#{Httpu.resolve_url node}/relationships/out/#{types}"
        Httpu.get(r).map{|rel| Relationship.new(rel)}
      end

    end

  end

end
