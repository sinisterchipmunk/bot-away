class TestsController < ActionController::Base
  protect_from_forgery
  
  def model_form
    @post = Post.new
  end

  def proc_form
    render :text => params.to_yaml
  end
end
