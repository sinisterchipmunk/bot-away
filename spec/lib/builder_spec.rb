###
# The original implementation of BotAway extended ActionView::Helpers::FormBuilder, and these tests were written
# for it. This approach has since been abandoned in favor of a direct override of ActionView::Helpers::InstanceTag for
# reasons of efficiency. The FormBuilder tests have been kept around simply for an extra layer of functional testing.
###

require 'spec_helper'

class MockObject; attr_accessor :method_name; def initialize; @method_name = 'method_value'; end; end

describe ActionView::Helpers::FormBuilder do
  subject { builder }

  it "should not create honeypots with default values" do
    builder.text_field(:method_name).should match(/name="object_name\[method_name\]"[^>]*?value=""/)
  end
  
  context "with BotAway.show_honeypots == true" do
    before(:each) { BotAway.show_honeypots = true }
    after(:each) { BotAway.show_honeypots = false }
    
    it "should not disguise honeypots" do
      builder.text_area(method_name).should_not match(/<\/div>/)
    end
  end
  
  it "should not obfuscate names that have been explicitly ignored" do
    BotAway.accepts_unfiltered_params 'method_name'
    builder.text_field('method_name').should_not match(/name="a0844d45bf150668ff1d86a6eb491969/)
    BotAway.unfiltered_params.delete 'method_name'
  end
  
  # select(method, choices, options = {}, html_options = {})
  obfuscates(:select) { builder.select(:method_name, {1 => :a, 2 => :b }) }

  #collection_select(method, collection, value_method, text_method, options = {}, html_options = {})
  obfuscates(:collection_select) { builder.collection_select method_name, [MockObject.new], :method_name, :method_name }
  
  #grouped_collection_select(method, collection, group_method, group_label_method, option_key_method,
  #                          option_value_method, options = {}, html_options = {})
  obfuscates(:grouped_collection_select) do
    builder.grouped_collection_select method_name, [MockObject.new], :method_name, :method_name, :to_s, :to_s
  end
  
  #time_zone_select(method, priority_zones = nil, options = {}, html_options = {})
  obfuscates(:time_zone_select) do
    builder.time_zone_select method_name
  end

  %w(hidden_field text_field text_area file_field password_field check_box).each do |field|
    obfuscates(field) { builder.send(field, method_name) }
  end

  obfuscates(:radio_button, '53640013be550817d040597218884288') { builder.radio_button method_name, :value }

  context "#label" do
    subject { dump { builder.label(method_name) } }

    it "links labels to their obfuscated elements" do
      subject.should match(/for=\"e21372563297c728093bf74c3cb6b96c\"/)
    end
  end
end
