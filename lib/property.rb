module NeoSql

  class NodeProperty

    class << self

      def create(node, hash)
        node &&= Httpu.resolve_url(node)
        Httpu.put("#{node}/properties", hash)
      end


      def get(node)
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
