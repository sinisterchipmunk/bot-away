class Post
  attr_reader :subject, :body, :subscribers
end

class TestController < ActionController::Base
  view_paths << File.expand_path(File.join(File.dirname(__FILE__), "../views"))

  def index
  end

  def model_form
    @post = Post.new
  end

  def proc_form
    render :text => params.to_yaml
  end
end
