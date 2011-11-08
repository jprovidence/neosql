require '../lib/node.rb'
require '../lib/relationship.rb'
require '../lib/property.rb'
require '../lib/httpu.rb'
include NeoSQL

describe NeoSQL::Relationship do

  context "instance methods" do

    describe "#new" do

      it "correctly initialized all fields" do
        h = { :start      => "http://localhost:7474/db/data/node/4",
              :data       => {},
              :self       => "http://localhost:7474/db/data/relationship/1",
              :property   => "http://localhost:7474/db/data/relationship/1/properties/{key}",
              :properties => "http://localhost:7474/db/data/relationship/1/properties",
              :type       => "know",
              :extensions => {},
              :end        => "http://localhost:7474/db/data/node/3" }
        r = Relationship.new(h)
        r.from_node_url.should  == h[:start]
        r.to_node_url.should    == h[:end]
        r.self_url.should       == h[:self]
        r.property_url.should   == h[:property]
        r.properties_url.should == h[:properties]
        r.type.should           == h[:type]
        r.data.should           == h[:data]
        r.extensions.should     == h[:extensions]
        r.properties.should     == {}
      end

    end

  end

end
