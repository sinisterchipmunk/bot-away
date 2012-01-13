class BotAway::TestCase::MockObject
  attr_accessor :method_name

  def id
    1
  end

  # for testing grouped_collection_select
  def object_name
    [self]
  end

  def initialize
    @method_name = 'method_value'
  end
end
