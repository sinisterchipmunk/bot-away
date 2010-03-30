class HoneypotMatcher
  def initialize(object_name, method_name)
    @object_name, @method_name = object_name, method_name
  end

  def matches?(target)
    target = target.call if target.kind_of?(Proc)
    @target = target
    @rx = /name="#{Regexp::escape @object_name}\[#{Regexp::escape @method_name}/m
    @target[@rx]
  end

  def failure_message
    "expected #{@target.inspect}\n  to match #{@rx.to_s}"
  end

  def negative_failure_message
    "expected #{@target.inspect}\n  to not match #{@rx.to_s}"
  end
end

def include_honeypot(object_name, method_name)
  HoneypotMatcher.new(object_name, method_name)
end

alias contain_honeypot include_honeypot
