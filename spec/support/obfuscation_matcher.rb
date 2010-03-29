class ObfuscationMatcher
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

def be_obfuscated_as(object_name, method_name)
  ObfuscationMatcher.new(object_name, method_name)
end
