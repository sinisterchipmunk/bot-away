class TestController < ActionController::Base
  view_paths << File.expand_path(File.join(File.dirname(__FILE__), "../views"))

  def index
#    puts url_for(:action => 'hi')
  end
end
