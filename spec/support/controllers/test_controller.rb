class TestController < ActionController::Base
  view_paths << File.expand_path(File.join(File.dirname(__FILE__), "../views"))

  def index
  end

  def proc_form
    render :text => params.to_yaml
  end
end
