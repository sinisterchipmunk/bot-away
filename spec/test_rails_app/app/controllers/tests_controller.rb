class TestsController < ActionController::Base
  protect_from_forgery
  
  def model_form
    @post = Post.new(:persisted => !!params[:id])
  end

  def proc_form
    render :text => params.to_yaml
  end
end
