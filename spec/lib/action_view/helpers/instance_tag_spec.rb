require 'spec_helper'

describe ActionView::Helpers::InstanceTag do
  include BotAway::TestCase::InstanceTagTestCase

  subject { default_instance_tag }
  
  context "honeypot" do
    subject { default_instance_tag.honeypot_tag(:input, :type => :text, :name => 'name') }
    it { should be_html_safe }
  end
  
  it "should have bdo in the instance tag" do
    subject.tag(:input, :type => :text).to_s.should =~ /<bdo/
  end

  context "honeypot warning text" do
    before { default_instance_tag.honeypot_index = 1 } # always produce the same honeypot
    subject { default_instance_tag.honeypot_warning_tag }
    
    it "should obfuscate honeypot warning text" do
      # 'Leave this empty: ' reversed and then converted to HTML escaped unicode:
      subject.should =~ /#{Regexp::escape '&#x20;&#x3a;&#x79;&#x74;&#x70;&#x6d;&#x65;&#x20;&#x73;&#x69;&#x68;&#x74;&#x20;&#x65;&#x76;&#x61;&#x65;&#x4c;'}/
    end
  
    it "should use bdo to display honeypot warning text accurately" do
      subject.should match(/<bdo dir=['"]rtl["']>.*?<\/bdo>/)
    end
    
    context "I18n" do
      it "should allow overridden honeypot warning" do
        default_instance_tag.honeypot_index = 2
        CGI.unescapeHTML(default_instance_tag.honeypot_warning_message).reverse.should == "Overridden honeypot warning"
      end
      
      it "shold allow additional honeypot warnings" do
        I18n.t('bot_away.number_of_honeypot_warning_messages').to_i.should == 4
        
        default_instance_tag.honeypot_index = 4
        CGI.unescapeHTML(default_instance_tag.honeypot_warning_message).reverse.should == "Additional honeypot warning"
      end
    end
  end
  
  context "with a valid text area tag" do
    subject do
      dump { default_instance_tag.to_text_area_tag }
    end

    it "should produce blank honeypot value" do
      subject.should_not =~ /name="object_name\[method_name\]"[^>]+>method_value<\/textarea>/
    end
  end

  context "with a valid input type=text tag" do
    before(:each) { @tag_options = ["input", {:type => 'text', 'name' => 'object_name[method_name]', 'id' => 'object_name_method_name', 'value' => 'method_value'}] }
    
    it "should turn off autocomplete for honeypots" do
      subject.honeypot_tag(*@tag_options).should =~ /autocomplete="off"/
    end

    it "should obfuscate tag name" do
      subject.obfuscated_tag(*@tag_options).should =~ /name="#{obfuscated_name}"/
    end

    it "should obfuscate tag id" do
      subject.obfuscated_tag(*@tag_options).should =~ /id="#{obfuscated_id}"/
    end

    it "should include unobfuscated tag value" do
      subject.obfuscated_tag(*@tag_options).should =~ /value="method_value"/
    end

    it "should create honeypot name" do
      subject.honeypot_tag(*@tag_options).should =~ /name="object_name\[method_name\]"/
    end

    it "should create honeypot id" do
      subject.honeypot_tag(*@tag_options).should =~ /id="object_name_method_name"/
    end

    it "should create empty honeypot tag value" do
      subject.honeypot_tag(*@tag_options).should =~ /value=""/
    end
  end
end
