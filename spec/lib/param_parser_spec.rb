describe BotAway::ParamParser do
  def params(honeypots)
    @params = { 'authenticity_token' => '1234',
                'bdf3e1964ac3a82c5f1c7385ed0100e4' => 'colin',
                'ed8fc4fe67d66bc7aeaf0b4817bd1311' => [1, 2]
           }.merge(honeypots).with_indifferent_access
  end

  before(:each) do
    # Root level is encoded with 208.77.188.166/test/1234
    #    which resolves to a spinner digest of 86ba3fd99e851587a849ad9ed9817f9b
    @ip = '208.77.188.166'
    @params = params('test' => { 'name' => '', 'posts' => [] })
  end

  subject { r = BotAway::ParamParser.new(@ip, @params); puts r.params.to_yaml; r }

  context "with blank honeypots" do
    it "drops obfuscated params" do
      subject.params.keys.should_not include('bdf3e1964ac3a82c5f1c7385ed0100e4')
    end

    it "drops obfuscated subparams" do
      subject.params.keys.should_not include('ed8fc4fe67d66bc7aeaf0b4817bd1311')
    end

    it "replaces honeypots" do
      subject.params[:test].should_not be_blank
    end

    it "replaces subhoneypots" do
      subject.params.keys.should include('test')
      subject.params[:test][:name].should == 'colin'
      subject.params[:test][:posts].should == [1,2]
    end
  end

  context "with a filled honeypot" do
    before(:each) { @params = params({'test' => {'name' => 'colin', 'posts' => []}}) }
    subject { r = BotAway::ParamParser.new(@ip, @params); puts r.params.to_yaml; r }

    it "drops all parameters" do
      subject.params.should == { "suspected_bot" => true }
    end
  end

  context "with a filled sub-honeypot" do
    before(:each) { @params = params({'test' => {'name' => '', 'posts' => [1, 2]}}) }
    subject { r = BotAway::ParamParser.new(@ip, @params); puts r.params.to_yaml; r }

    it "drops all parameters" do
      subject.params.should == { "suspected_bot" => true }
    end
  end
end
