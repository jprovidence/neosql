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

  end

end
