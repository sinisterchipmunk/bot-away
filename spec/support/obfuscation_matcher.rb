class ObfuscationMatcher
  def initialize(object_name, method_name)
    @object_name, @method_name = object_name, method_name
  end

  def matches?(target)
    target = target.call if target.kind_of?(Proc)
    @target = target
    @rx = /name="#{Regexp::escape @object_name}\[#{Regexp::escape @method_name}/m
#    @rx = "name=\"#{@object_name}[#{@method_name}]\""
    @target[@rx]
#    @target =~ /#{Regexp::escape @rx}/
  end

  def failure_message
    "expected #{@target.inspect}\n  to match #{@rx.inspect}"
  end

  def negative_failure_message
    "expected #{@target.inspect}\n  to not match #{@rx.inspect}"
  end
end

def be_obfuscated_as(object_name, method_name)
  ObfuscationMatcher.new(object_name, method_name)
end
