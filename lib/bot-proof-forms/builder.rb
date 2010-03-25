module BotProofForms
  class Builder < ActionView::Helpers::FormBuilder
    attr_reader :timestamp, :client_ip, :entry_id, :secret, :spinner, :template
    
    def initialize(object_name, object, template, options, proc)
      @secret    = template.form_authenticity_token
      @spinner = Digest::MD5.hexdigest(File.join(Time.now.to_i.to_s,
                                                 template.controller.request.ip,
                                                 object_name.to_s,
                                                 secret))
      #puts self.class.field_helpers
      super(object_name, object, template, options, proc)
    end

    def text_field_with_obfuscation(method, options = {})
      options = options.dup
      options.merge!(object.send(method)) if object && object.respond_to?(method)
      template.send("text_field", secret_field_name(object_name), secret_field_name(method), objectify_options(options))
    end

    def text_field_with_honeypot(method, options = {})
      disguise(text_field_without_obfuscation(method, options)) + text_field_with_obfuscation(method, options)
    end

    alias_method_chain :text_field, :obfuscation
    alias_method_chain :text_field, :honeypot

    def disguise(element)
      case rand(3)
        when 0 # Hidden
          "<div style='display:none;'>Leave this empty: #{element}</div>"
        when 1 # Off-screen
          "<div style='position:absolute;left:-1000px;top:-1000px;'>Leave this empty: #{element}</div>"
        when 2 # Negligible size
          "<div style='position:absolute;width:0px;height:1px;z-index:-1;color:transparent;'>Leave this empty: #{element}</div>"
      end
    end

    private
    def secret_field_name(real_field_name)
      Digest::MD5.hexdigest(File.join(real_field_name.to_s, spinner, secret))
    end
  end
end
