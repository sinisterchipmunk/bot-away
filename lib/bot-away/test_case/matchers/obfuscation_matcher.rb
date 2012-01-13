class BotAway::TestCase::Matchers::ObfuscationMatcher
  attr_reader :obfuscated_name, :obfuscated_id
  
  def initialize(obfuscated_name, obfuscated_id)
    @obfuscated_id, @obfuscated_name = obfuscated_id, obfuscated_name
  end

  def matches?(target)
    target = target.call if target.kind_of?(Proc)
    @target = target
    match(:id, obfuscated_id) && match(:name, obfuscated_name)
  end

  def match(key, value)
    @rx = /#{key}=['"]#{Regexp::escape value}["']/
    @target[@rx]
  end

  def failure_message
    "expected #{@target.inspect}\n  to match #{@rx.inspect}"
  end
  
  def negative_failure_message
    "expected #{@target.inspect}\n  to not match #{@rx.inspect}"
  end
end
