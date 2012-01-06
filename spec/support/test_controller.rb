class Post
  attr_reader :subject, :body, :subscribers
  
  def subscribers
    []
  end
  
  if defined?(ActiveModel)
    extend ActiveModel::Naming
    
    def to_key
      [1]
    end
  end
end

class ApplicationController < ActionController::Base
  
end

class TestController < ApplicationController
  def index
  end

  def model_form
    @post = Post.new
  end

  def proc_form
    render :text => params.to_yaml
  end
end
