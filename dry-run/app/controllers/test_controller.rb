class TestController < ApplicationController
  def index
    @post = Post.new(:subject => 'enter a subject', :body => 'enter a body', :subscribers => 12)
    @post.created_at = Time.now
#    respond_to do |f|
#      f.text { render }
#    end
  end

end
