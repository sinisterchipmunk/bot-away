class Post
  attr_reader :subject, :body, :subscribers
  
  def subscribers
    []
  end
  
  extend ActiveModel::Naming
  
  def to_key
    [1]
  end
  
  def persisted?
    @persisted
  end
  
  def initialize(options = {})
    @persisted = options.delete(:persisted)
  end
end
