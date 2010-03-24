module BotProofForms
  class Builder < ActionView::Helpers::FormBuilder
    def initialize(object_name, object, template, options, proc)
      #@timestamp = Time.now
      #@client_ip = template.controller.request.ip
      #@entry_id = (object && object.respond_to?(:id) && object.id) || object_name
      #@secret = Digest::MD5.hexdigest(Time.now.to_i.to_s)
      super(object_name, object, template, options, proc)
    end
  end
end
