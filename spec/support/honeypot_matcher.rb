class HoneypotMatcher
  def initialize(object_name, method_name)
    @object_name, @method_name = object_name, method_name
  end

  def matches?(target)
    target = target.call if target.kind_of?(Proc)
    @target = target
    @rx = "name=\"#{@object_name}[#{@method_name}]\""
    @target =~ /#{Regexp::escape @rx}/
  end

  def failure_message
    "expected #{@target.inspect}\n  to contain #{@rx.inspect}"
  end

  def negative_failure_message
    "expected #{@target.inspect}\n  to not contain #{@rx.inspect}"
  end
end

def include_honeypot(object_name, method_name)
  HoneypotMatcher.new(object_name, method_name)
end

alias contain_honeypot include_honeypot
