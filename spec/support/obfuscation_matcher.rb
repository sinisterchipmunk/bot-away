class ObfuscationMatcher
  def initialize(id, name)
    @id, @name = id, name
  end

  def matches?(target)
    target = target.call if target.kind_of?(Proc)
    @target = target
    match(:id) && match(:name)
  end

  def match(which)
    @rx = /#{which}=['"]#{Regexp::escape instance_variable_get("@#{which}")}/
    @target[@rx]
  end

  def failure_message
    "expected #{@target.inspect}\n  to match #{@rx.inspect}"
  end

  def negative_failure_message
    "expected #{@target.inspect}\n  to not match #{@rx.inspect}"
  end
end

def be_obfuscated_as(id, name)
  ObfuscationMatcher.new(id, name)
end
