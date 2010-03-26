describe BotProofForms::ParamParser do
  def params(honeypots)
    @params = { 'authenticity_token' => 'hvOox8HTm31KyTalk60MwelhWvQwq5HuztjcmV1hx3o=',
             '62e70bf492873ce0b088ed3ed4d0251b' => { '1c5b4f68648b1d78a7a62566b2089736' => 'colin',
                                                     '732cc190ad260f9f9319e3a476325e75' => [1, 2] }
           }.merge(honeypots).with_indifferent_access
  end

  before(:each) do
    # Root level is encoded with 208.77.188.166/test/hvOox8HTm31KyTalk60MwelhWvQwq5HuztjcmV1hx3o=
    #    which resolves to a spinner of 67ee1c4264c7689606030f435dc9b9ab
    #
    # 'posts' is treated as being constructed with #fields_for, so it is encoded with
    #    208.77.188.166/posts/hvOox8HTm31KyTalk60MwelhWvQwq5HuztjcmV1hx3o=
    #    which resolves to a spinner of f4f561e383b50e824e980ffcaca82d46
    @ip = '208.77.188.166'
    @params = params('test' => { 'name' => '', 'posts' => [] })
  end

  subject { r = BotProofForms::ParamParser.new(@ip, @params); puts r.params.to_yaml; r }

  context "with blank honeypots" do
    it "drops obfuscated params" do
      subject.params.keys.should_not include('62e70bf492873ce0b088ed3ed4d0251b')
    end

    it "replaces honeypots" do
      subject.params[:test].should_not be_blank
    end

    it "drops obfuscated subparams" do
      subject.params[:test].keys.should_not include('1c5b4f68648b1d78a7a62566b2089736')
    end

    it "replaces subhoneypot values with subparam values" do
      subject.params[:test][:name].should == 'colin'
    end
  end

  context "with a filled honeypot" do
    before(:each) { @params = params({'test' => {'name' => 'colin', 'posts' => []}}) }
    subject { r = BotProofForms::ParamParser.new(@ip, @params); puts r.params.to_yaml; r }

    it "drops all parameters" do
      subject.params.should == { "suspected_bot" => true }
    end
  end

  context "with a filled sub-honeypot" do
    before(:each) { @params = params({'test' => {'name' => '', 'posts' => [1, 2]}}) }
    subject { r = BotProofForms::ParamParser.new(@ip, @params); puts r.params.to_yaml; r }

    it "drops all parameters" do
      subject.params.should == { "suspected_bot" => true }
    end
  end
end
