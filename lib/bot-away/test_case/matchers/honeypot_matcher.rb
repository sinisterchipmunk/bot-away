class BotAway::TestCase::Matchers::HoneypotMatcher
  attr_reader :tag_name, :tag_id
  
  def initialize(tag_name, tag_id)
    @tag_name, @tag_id = tag_name, tag_id
  end
  
  def matches?(target)
    target = target.call if target.kind_of?(Proc)
    @target = target
    match(:id, tag_id) && match(:name, tag_name)
  end

  def match(key, value, suffix = nil)
    @rx = /#{key}=['"]#{Regexp::escape value}["']/
    @target[@rx]
  end

  def description
    "include a honeypot named '#{tag_name}' with id '#{tag_id}'"
  end

  def failure_message
    "expected #{@target.inspect}\n  to match #{@rx.inspect}"
  end
  
  def negative_failure_message
    "expected #{@target.inspect}\n  to not match #{@rx.inspect}"
  end
end
