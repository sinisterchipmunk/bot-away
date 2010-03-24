require 'spec_helper'

describe 'BotProofForms::Builder' do
  include ActionController::Integration::Runner

  subject do
    puts ActionController::Routing::Routes.routes_by_controller.inspect
    puts ActionController::Routing::Routes.recognize_path("/test/index").inspect
#    subject = ActionController::Integration::Session.new()
#    r = subject.get("/test/index")
#    puts subject.controller.controller_name
    r = get("/test/index")
    puts controller.class
    r
  end

  before(:all) do
  #  @rack_env = Rack::MockRequest.env_for("/test").merge('REQUEST_URI' => '/test')
  end

  it "test" do
    subject
  end
end
