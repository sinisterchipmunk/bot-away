class ActionController::RequestForgeryProtection::ProtectionMethods::BotCaught
  def initialize controller
    @controller = controller
  end

  def handle_unverified_request
    @controller.render text: "bot detected"
  end
end

class AccountsController < ActionController::Base
  protect_from_forgery with: :bot_caught

  def new
    @account = Account.new
  end

  def create
    render text: "OK"
  end
end
