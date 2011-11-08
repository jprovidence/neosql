require '../lib/node.rb'
require '../lib/relationship.rb'
require '../lib/property.rb'
require '../lib/httpu.rb'
include NeoSQL

describe NeoSQL::NodeProperty do

  context "instance methods" do

    before(:each) do
      @h  = { :a => 'a',
              :b => 'b',
              :c => 'c',
              :d => 'd'}
      @np = NodeProperty.new(@h)
    end


    describe "#new" do

      it "correctly initializes @data" do
        @np.data.should == {:a => 'a',
                            :b => 'b',
                            :c => 'c',
                            :d => 'd'}
      end

    end


    describe "#has_key?" do

      it "correctly determines if @data has a certain key" do
        @np.has_key?(:a).should == true
        @np.has_key?(:b).should == true
        @np.has_key?(:c).should == true
        @np.has_key?(:q).should == false
      end

    end


    describe "#all" do
    
      it "returns itself" do
        @np.all.should == NodeProperty.new(@h)
      end

    end


    describe "#each" do

      it "yields each key pair of @data" do
        count = 0
        @np.each do |k, v|
          k.should == @h.keys[count]
          v.should == @h.values[count]
          count += 1  
        end
      end

    end


    describe "#each_key" do

      it "yields each key of @data" do
        count = 0
        @np.each_key do |k|
          k.should == @h.keys[count]
          count += 1
        end
      end

    end


    describe "#each_value" do

      it "yields each value of @data" do
        count = 0
        @np.each_value do |v|
          v.should == @h.values[count]
          count += 1
        end
      end

    end


    describe "#keys" do

      it "returns all the keys of @data" do
        @np.keys.should == @h.keys
      end

    end


    describe "#values" do
      
      it "returns all the values of @data" do
        @np.values.should == @h.values
      end

    end


    describe "#get" do

      it "returns the value that corresponds to the key given" do
        @np.get(:a).should == "a"
        @np.get(:b).should == "b"
        @np.get(:d).should == "d"
        @np.get(:q).should == nil
      end

    end


    describe "#set" do

      it "merges a hash provided into @data overwriting any existing k/v pairs with the same key" do
        @np.set({:a => "aa"})
        @np.all[:a].should == "aa"
        @np.set({:q => "qq"})
        @np.all[:q].should == "qq"
      end


      it "merges key value pairs provided separately into @data" do
        @np.set(:a, "aa")
        @np.all[:a].should == "aa"
        @np.set(:q, "qq")
        @np.all[:q].should == "qq"
      end

    end


    describe "#[]" do

      it "accesses @data" do
        @np[:a].should == @np.data[:a]
      end

    end


    describe "#[]= " do

      it "writes to @data" do
        @np[:a] = 5 
        @np.data[:a].should == 5
      end

    end


    describe "#<<" do
      
      it "adds the provided hash to @data" do
        @np << {:rand => "rand"}
        @np.rand.should == "rand"
      end

    end


    describe "#==" do

      it "accurately compares two NodeProperty instances" do
        other = NodeProperty.new(@h)
        (@np == other).should == true
        (@np == "ran").should == false
      end

    end


    describe "#respond_to_missing?" do

      it "confirms keys of @data are also reader methods on node property instance" do
        @np.respond_to?(:a).should == true
        @np.respond_to?(:q).should == false
      end

      it "confirms respond to general writer methods, include addition of new key pairs" do
        @np.respond_to?(:"a=").should == true
        @np.respond_to?(:"q=").should == true
      end

    end


    describe "#method_missing" do

      it "defines reader method for all keys of @data" do
        @np.a.should == "a"
        lambda {@np.q}.should raise_error
      end

      it "defines general writer methods, including addition of new key pairs" do
        @np.a = "aa"
        @np.all[:a].should == "aa"
        @np.q = "qq"
        @np.all[:q].should == "qq"
      end
      
    end

  end


  context "class methods" do

    describe "#get" do

      it "delegates to #get all when key == :all" do
        NodeProperty.should_receive(:get_all)
        NodeProperty.get(@np, :all)
      end

      it "makes an HTTP get request for the property requested " do
        Httpu.should_receive(:resolve_url).and_return("url")
        Httpu.should_receive(:get).with("url/properties/key")
        NodeProperty.get(@np, :key)
      end

    end


    describe "#get_all" do

      it "makes an HTTP get request for a list of all properties as a new NodeProperty instance" do
        Httpu.should_receive(:resolve_url).and_return("url")
        Httpu.should_receive(:get).with("url/properties")
        x = NodeProperty.get_all(@np)
        x.kind_of?(NodeProperty).should == true
      end

    end


    describe "#set_all!" do

      it "makes an HTTP put to the destructive API endpoint" do
        Httpu.should_receive(:resolve_url).and_return("url")
        Httpu.should_receive(:put).with("url/properties", {:a => "b"})
        NodeProperty.set_all!(@np, {:a => "b"})
      end

    end

  end

end
