module NeoSQL

  class Httpu

    require 'rubygems'
    require 'yajl'
    require 'uri'
    require 'net/http'

    class << self

      def get(url)

        uri = URI.parse(url)
        req = Net::HTTP::Get.new(uri.path)
        res = Net::HTTP.start(uri.host, uri.port) do |http|
          http.request(req)
        end

        json = Yajl::Parser.parse(res.body)

      end


      def post(url, data)

        json = Yajl::Encoder.encode(data)

        uri = URI.parse(url)
        req = Net::HTTP::Post.new(uri.path, {'Content-Type' => 'application/json'})
        req.body = json
        res = Net::HTTP.start(uri.host, uri.port) do |http|
          http.request(req)
        end

        res.body

      end


      def delete(url)
        uri = URI.parse(url)
        req = Net::HTTP::Delete.new(uri.path)
        res = Net::HTTP.start(uri.host, uri.port) do |http|
          http.request(req)
        end
      end


      def resolve_url(u)
        if u.kind_of?(Relationship) || u.kind_of?(Node)
          u.self_url
        else
          u
        end
      end

    end

  end

end
