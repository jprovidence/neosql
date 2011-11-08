require '../lib/node.rb'
require '../lib/relationship.rb'
require '../lib/property.rb'
require '../lib/httpu.rb'
include NeoSQL

describe NeoSQL::Node do

  context "instance methods" do

    before(:each) do 
      @h = { 
            :outgoing_relationships => "http://localhost:7474/db/data/node/1/relationships/out",
            :data => {:foo => "bar"},
            :traverse => "http://localhost:7474/db/data/node/1/traverse/{returnType}",
            :all_typed_relationships => "http://localhost:7474/db/data/node/1/relationships/all/{-list|&|types}",
            :property => "http://localhost:7474/db/data/node/1/properties/{key}",
            :self => "http://localhost:7474/db/data/node/1",
            :outgoing_typed_relationships => "http://localhost:7474/db/data/node/1/relationships/out/{-list|&|types}",
            :properties => "http://localhost:7474/db/data/node/1/properties",
            :incoming_relationships => "http://localhost:7474/db/data/node/1/relationships/in",
            :extensions => {},
            :create_relationship => "http://localhost:7474/db/data/node/1/relationships",
            :paged_traverse => "http://localhost:7474/db/data/node/1/paged/traverse/{returnType}{?pageSize,leaseTime}",
            :all_relationships => "http://localhost:7474/db/data/node/1/relationships/all",
            :incoming_typed_relationships => "http://localhost:7474/db/data/node/1/relationships/in/{-list|&|types}"
          }
      @n = NeoSQL::Node.new(@h)
    end
  
    describe "#new" do
    
      it "assigns all fields correctly on instantiation" do
        @n.outgoing_relationships_url.should == @h[:outgoing_relationships]
        @n.data.should == {:foo => "bar"}
        @n.traverse_url.should == @h[:traverse]
        @n.all_typed_relationships_url.should == @h[:all_typed_relationships]
        @n.incoming_relationships_url.should == @h[:incoming_relationships]  
        @n.properties_url.should == @h[:properties]
        @n.node_properties.should == {}
      end

    end


    describe "#get" do

      it "creates property accessors when not defined" do
        mock = true
        def mock.returns
          true
        end

        Node.any_instance.should_receive(:define_property_accessors).and_return(mock)
        @n.get(:random)
      end

      it "reads values from the properties hash if it exists" do
        @n.node_properties = NodeProperty.new({:bar => "baz"})
        @n.get(:bar).should == "baz"
      end

      it "raises an error with an unknown node_properties key" do
        @n.node_properties = NodeProperty.new({:bar => "baz"})
        lambda {@n.get(:qux)}.should raise_error
      end

      it "raises an error when #define_property_accessors says the key does not exist" do
        mock = false
        def mock.returns
          false
        end

        Node.any_instance.should_receive(:define_property_accessors).and_return(mock)
        lambda {@n.get(:random)}.should raise_error
      end

    end


    describe "#set" do

      it "calls NodeProperty#set_all when destructive" do
        NodeProperty.should_receive(:"set_all!")
        @n.set(:foo, :bar, true)
      end

      it "passes to NodeProperty#set_all and transforms independent key vals into a hash when destructive" do
        NodeProperty.should_receive(:set_all!).with({:foo => :bar})
        @n.set(:foo, :bar, true)
      end

      it "delegates to #set_from_hash when it receives a hash" do
        Node.any_instance.should_receive(:set_from_hash).with(:foo => :bar)
        @n.set({:foo => :bar})
      end

      it "delegates to NodeProperty#set when it receives independent key vals" do
        NodeProperty.should_receive(:set).with(:foo, :bar)
        @n.set(:foo, :bar)
      end

    end


    describe "#set_from_hash" do

      it "iterates through hash, passing each key val to NodeProperty#set" do
        NodeProperty.should_receive(:set).with("http://localhost:7474/db/data/node/1", {:foo => :bar})
        NodeProperty.should_receive(:set).with("http://localhost:7474/db/data/node/1", {:baz => :qux})
        @n.set_from_hash({:foo => :bar, :baz => :qux})
      end

    end


    describe "#set!" do

      it "just calls set with destructive set to true" do
        Node.any_instance.should_receive(:set).with({:foo => :bar}, "", true)
        @n.set!({:foo => :bar})
      end

    end


    describe "#all_properties" do
      
      it "Looks up properties when they aren't already known" do
        NodeProperty.should_receive(:get_all).and_return(NodeProperty.new({:foo => :bar}))
        @n.all_properties.should == NodeProperty.new({:foo => :bar})
        @n.node_properties.should == NodeProperty.new({:foo => :bar})
      end

      it "just returns properties from node_properties when it exists" do
        @n.node_properties = NodeProperty.new({:foo => :bar})
        @n.all_properties.should == NodeProperty.new({:foo => :bar})
      end

    end


    describe "#relationships" do

      it "forwards to correct node method" do
        Node.any_instance.should_receive(:all_relationships)
        Node.any_instance.should_receive(:outgoing_relationships)
        Node.any_instance.should_receive(:incoming_relationships)
        Node.any_instance.should_receive(:all_typed_relationships).with(nil)
        Node.any_instance.should_receive(:outgoing_typed_relationships).with(nil)
        Node.any_instance.should_receive(:incoming_typed_relationships).with(nil)

        @n.relationships(:all)
        @n.relationships(:outgoing)
        @n.relationships(:incoming)
        @n.relationships(:all_typed, nil)
        @n.relationships(:outgoing_typed, nil)
        @n.relationships(:incoming_typed, nil)
      end

      it "raises an error with unrecognised modifiers" do
        lambda {@n.relationships(:other)}.should raise_error
      end

    end


    describe "all individual relationship accessor methods" do

      it "forwards to static Relationship#all" do
        Relationship.should_receive(:all).with(@h[:self])
        @n.all_relationships
      end

      it "forwards to static Relationship#outgoing" do
        Relationship.should_receive(:outgoing).with(@h[:self])
        @n.outgoing_relationships
      end

      it "forwards to static Relationship#incoming" do
        Relationship.should_receive(:incoming).with(@h[:self])
        @n.incoming_relationships
      end

      it "forwards to static Relationship#typed" do
        Relationship.should_receive(:typed).with(@h[:self], [])
        @n.all_typed_relationships([])
      end

      it "forwards to static Relationship#outgoing_typed" do
        Relationship.should_receive(:outgoing_typed).with(@h[:self], [])
        @n.outgoing_typed_relationships([])
      end

      it "forwards to static Relationship#incoming_typed" do
        Relationship.should_receive(:incoming_typed).with(@h[:self], [])
        @n.incoming_typed_relationships([])
      end

    end


    describe "#delete" do

      it "forwards to Httpu#delete with self url" do
        Httpu.should_receive(:delete).with(@h[:self])
        @n.delete
      end

    end


    describe "#define_property_accessors_if_exists" do

      it "only returns true if node_properties already exists, regardless of params" do
        @n.node_properties = NodeProperty.new({:foo => :bar})
        @n.define_property_accessors_if_exists(:blah)
      end

      it "adds meta to return value for ease of reading" do
        NodeProperty.should_receive(:get_all).and_return({:foo => :bar})
        x = @n.define_property_accessors_if_exists(:blah)
        x.returns.should == false
      end

      it "returns false when key is unknown to properties" do
        NodeProperty.should_receive(:get_all).and_return({:foo => :bar})
        @n.define_property_accessors_if_exists(:blah).should == false
      end

      it "returns true when key is known to properties" do
        NodeProperty.should_receive(:get_all).and_return({:foo => :bar})
        @n.define_property_accessors_if_exists(:foo).should == true
      end

      it "initializes @node_properties@ when key is known" do
        NodeProperty.should_receive(:get_all).and_return(NodeProperty.new({:foo => :bar}))
        @n.define_property_accessors_if_exists(:foo)
        @n.node_properties.should == NodeProperty.new({:foo => :bar})
      end

    end


    describe "#respond_to_missing" do

      it "confirms an instance responds to attempts to create new typed relationships" do
        @n.respond_to?(:follow_relationship_with)
      end

      it "defines property accessors and confirms they are responded to" do
        mock = true
        def mock.returns
          true
        end

        Node.any_instance.should_receive(:define_property_accessors_if_exists).and_return(mock)
        @n.respond_to?(:key).should == true
      end

    end


    describe "#method_missing" do

      it "calls #relationship_with with correct params provided a matching method, node and hash" do
        Node.any_instance.should_receive(:relationship_with).with(:node1, "following", {:a => 'b'})
        @n.following_relationship_with(:node1, {:a => 'b'})
      end

      it "calls #relationship_with with correct params provided a matching method and node" do
        Node.any_instance.should_receive(:relationship_with).with(:node1, "following")
        @n.following_relationship_with(:node1)
      end

      it "initializes the properties and sets a property value when given a key and value" do
        Node.any_instance.should_receive(:define_property_accessors_if_exists)
        lambda {@n.qux = :foo}.should raise_error 
      end

    end

  end


  context "class methods" do

    describe "Node#create" do

      it "creates a new node via http post" do
        Httpu.should_receive(:post).and_return({})
        n = Node.create
        n.kind_of?(Node).should == true
      end

    end


    describe "Node#create_with" do
      
      it "creates a new node with certain properties via http post" do
        Httpu.should_receive(:post).and_return({})
        n = Node.create_with({:a => :b})
        n.kind_of?(Node).should == true
      end

    end


    describe "Node#get_node" do

      it "gets a node from the database via http get" do
        Httpu.should_receive(:get).and_return({})
        n = Node.get_node(1)
        n.kind_of?(Node).should == true
      end

    end


    describe "Node#delete" do

      it "deletes a node from the database via http delete" do
        Httpu.should_receive(:delete)
        Node.delete(1)
      end

    end

  end

end
