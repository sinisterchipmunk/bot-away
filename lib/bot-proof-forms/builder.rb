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

    def text_field_with_hashes(method, options = {})
      options = options.dup
      options.merge!(object.send(method)) if object && object.respond_to?(method)
      template.send("text_field", secret_field_name(object_name), secret_field_name(method), objectify_options(options))
    end

    def text_field_with_honeypot(method, options = {})
      disguise(text_field_without_obfuscation(method, options))
    end

    def text_field_with_obfuscation(method, options = {})
      if template.controller.send(:protect_against_forgery?)
        text_field_with_honeypot(method, options) + text_field_with_hashes(method, options)
      else
        # no forgery protection means no authenticity token, means no secret.
        # We could feasibly code around this, but if forgery protection is disabled then it is so for a reason,
        # and user may not WANT obfuscation.
        text_field_without_obfuscation(method, options)
      end
    end

    alias_method_chain :text_field, :obfuscation

    def disguise(element)
      case rand(3)
        when 0 # Hidden
          "<div style='display:none;'>Leave this empty: #{element}</div>"
        when 1 # Off-screen
          "<div style='position:absolute;left:-1000px;top:-1000px;'>Don't fill this in: #{element}</div>"
        when 2 # Negligible size
          "<div style='position:absolute;width:0px;height:1px;z-index:-1;color:transparent;overflow:hidden;'>Keep this blank: #{element}</div>"
        else # this should never happen?
          disguise(element)
      end
    end

    private
    def secret_field_name(real_field_name)
      Digest::MD5.hexdigest(File.join(real_field_name.to_s, spinner, secret))
    end
  end
end
