module BotAway::TestCase::Matchers
  autoload :ObfuscationMatcher, 'bot-away/test_case/matchers/obfuscation_matcher'
  autoload :HoneypotMatcher,    'bot-away/test_case/matchers/honeypot_matcher'
  
  def be_obfuscated_as(obfuscated_name, obfuscated_id)
    ObfuscationMatcher.new(obfuscated_name, obfuscated_id)
  end
  
  def include_honeypot_called(tag_name, tag_id)
    HoneypotMatcher.new(tag_name, tag_id)
  end
  
  def be_obfuscated
    be_obfuscated_as obfuscated_name, obfuscated_id
  end
  
  def include_honeypot
    include_honeypot_called tag_name, tag_id
  end
end
