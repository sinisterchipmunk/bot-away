require 'spec_helper'

describe ActionView::Helpers::FormBuilder do
  include BotAway::TestCase::Matchers
  
  it "should not create honeypots with default values" do
    builder.text_field(method_name).should match(/name="object_name\[method_name\]"[^>]*?value=""/)
  end
  
  context "with BotAway.show_honeypots == true" do
    before { BotAway.show_honeypots = true }
    after { BotAway.show_honeypots = false }
    
    it "should not disguise honeypots" do
      builder.text_area(method_name).should_not match(/<\/div>/)
    end
  end

  it "should not obfuscate names that have been explicitly ignored" do
    BotAway.accepts_unfiltered_params 'method_name'
    builder.text_field('method_name').should_not match(/name="#{obfuscated_name}/)
    BotAway.unfiltered_params.delete 'method_name'
  end
  
  shared_examples_for "an obfuscated tag" do
    it { should be_obfuscated }
    it { should include_honeypot }
  end
  
  shared_examples_for "an obfuscated select tag" do
    it_should_behave_like "an obfuscated tag"
    
    it "should fill honeypots with html-safe options" do
      subject.to_s.should match(/<select[^>]*><option[^>]*><\/option>/)
    end
  end
  
  # select(method, options)
  context '#select' do
    context "with options" do
      subject { builder.select(method_name, {1 => :a, 2 => :b}) }
      it_should_behave_like "an obfuscated select tag"
    end
  end
  
  # collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
  context '#collection_select' do
    subject { builder.collection_select method_name, [mock_object], :method_name, :method_name }
    it_should_behave_like "an obfuscated select tag"
  end
  
  # grouped_collection_select(method, collection, group_method, group_label_method, option_key_method,
  #                           option_value_method, options = {}, html_options = {})
  context '#grouped_collection_select' do
    subject { builder.grouped_collection_select method_name, [mock_object], object_name, method_name, method_name, :to_s }
    it_should_behave_like "an obfuscated select tag"
  end
  
  # time_zone_select(method, priority_zones = nil, options = {}, html_options = {})
  context '#time_zone_select' do
    subject { builder.time_zone_select method_name }
    it_should_behave_like "an obfuscated tag"
  end

  context '#hidden_field' do
    subject { builder.hidden_field method_name }
    it_should_behave_like "an obfuscated tag"
  end

  context '#text_field' do
    subject { builder.text_field method_name }
    it_should_behave_like "an obfuscated tag"
  end

  context '#text_area' do
    subject { builder.text_area method_name }
    it_should_behave_like "an obfuscated tag"
  end

  context '#file_filed' do
    subject { builder.file_field method_name }
    it_should_behave_like "an obfuscated tag"
  end

  context '#password_field' do
    subject { builder.password_field method_name }
    it_should_behave_like "an obfuscated tag"
  end

  context '#check_box' do
    subject { builder.check_box method_name }
    it_should_behave_like "an obfuscated tag"
  end
  
  context '#radio_button' do
    subject { builder.radio_button method_name, :value }
    it { should be_obfuscated_as obfuscated_name, '767c870add970ab6d64803043c4ccfbb' }
    it { should include_honeypot_called tag_name, tag_id+'_value' }
  end

  context '#label' do
    subject { builder.label method_name, :for => tag_id }
    
    it "links labels to their obfuscated elements" do
      subject.should match(/for=["']#{obfuscated_id}['"]/)
    end
    
    # TODO ideas for future implementation, but they may break nested tags
    # it "obfuscates label text using bdo dir" do
    #   subject.should match(/<bdo dir=['"]rtl["']/)
    # end
    # 
    # it "uses reversed unicode entities for label text" do
    #   # method_name => reversed(eman_dohtem)
    #   subject.should match("&#x65;&#x6d;&#x61;&#x6e;&#x5f;&#x64;&#x6f;&#x68;&#x74;&#x65;&#x6d;")
    # end
  end
end
