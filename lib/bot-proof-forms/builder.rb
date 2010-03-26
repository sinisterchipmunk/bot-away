module BotProofForms
  class Builder < ActionView::Helpers::FormBuilder
    attr_reader :timestamp, :client_ip, :entry_id, :template, :spinner
    
    def initialize(object_name, object, template, options, proc)
      @spinner    = BotProofForms::Spinner.new(template.controller.request.ip,
                                               object_name.to_s,
                                               template.form_authenticity_token)

      super(object_name, object, template, options, proc)
    end

    %w(hidden_field text_field text_area file_field password_field check_box).each do |field|
      line = __LINE__ + 2
      code = <<-end_code
        def #{field}_with_hashes(method, options = {}, *args)
          options = options.dup
          if object && object.respond_to?(method)
            options.merge! :value => object.send(method).to_s
          end
          template.send("#{field}", spinner.encode(object_name), spinner.encode(method), objectify_options(options), *args)
        end
      end_code
      eval code, binding, __FILE__, line
    end

    def label(method, text = nil, options = {})
      if template.controller.send(:protect_against_forgery?)
        text ||= method.to_s.humanize
        @template.label(spinner.encode(@object_name), spinner.encode(method), text, objectify_options(options))
      else
        @template.label(@object_name, method, text, objectify_options(options))
      end
    end

    def radio_button_with_hashes(method, tag_value, options = {})
      options = options.dup
      if object && object.respond_to?(method)
        if ActionView::FormHelper::InstanceTag.radio_button_checked?(object.send(method), tag_value)
          options.merge!(:checked => true)
        end
      end
      @template.radio_button(spinner.encode(@object_name), spinner.encode(method), tag_value, objectify_options(options))
    end

    %w(hidden_field text_field text_area file_field password_field check_box radio_button).each do |field|
      line = __LINE__ + 2
      code = <<-end_code
        def #{field}_honeypot(method, *args)
          disguise(#{field}_without_obfuscation(method, *args))
        end

        def #{field}_with_obfuscation(method, *args)
          if template.controller.send(:protect_against_forgery?)
            #{field}_honeypot(method, *args) + #{field}_with_hashes(method, *args)
          else
            # no forgery protection means no authenticity token, means no secret.
            # We could feasibly code around this, but if forgery protection is disabled then it is so for a reason,
            # and user may not WANT obfuscation.
            #{field}_without_obfuscation(method, *args)
          end
        end

        alias_method_chain :#{field}, :obfuscation
      end_code
      eval code, binding, __FILE__, line
    end

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
  end
end
