require 'spec_helper'

class MockObject; attr_accessor :method_name; def initialize; @method_name = 'method_value'; end; end

describe BotProofForms::Builder do
  subject { builder }

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

  %w(date_select time_select datetime_select).each do |field|
    obfuscates(field) { builder.object.method_name = Time.now; builder.send(field, method_name) }
  end

  obfuscates(:radio_button) { builder.radio_button method_name, :value }

  context "#label" do
    subject { dump { builder.label(method_name) } }

    it "links labels to their obfuscated elements" do
      subject.should match(/for=\"50206624c6a61ddd6f3e6eddb2ac02d3_76042ec523072e08e3313cb0ea54aca6\"/)
    end
  end
end
