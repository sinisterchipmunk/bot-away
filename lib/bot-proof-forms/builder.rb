module BotProofForms
  class Builder < ActionView::Helpers::FormBuilder
    include BotProofForms::Builder::Honeypots

    attr_reader :timestamp, :client_ip, :entry_id, :template, :spinner
    
    def initialize(object_name, object, template, options, proc)
      @spinner    = BotProofForms::Spinner.new(template.controller.request.ip,
                                               object_name.to_s,
                                               template.form_authenticity_token)

      super(object_name, object, template, options, proc)
    end

    def select_with_hashes(method, choices, options = {}, html_options = {})
      options = options_with_value(options, method)
      template.select(spinner.encode(object_name), spinner.encode(method), choices, objectify_options(options),
                      @default_options.merge(html_options))
    end

    def collection_select_with_hashes(method, collection, value_method, text_method, options = {}, html_options = {})
      options = options_with_value(options, method)
      template.collection_select(spinner.encode(object_name), spinner.encode(method), collection, value_method,
                                 text_method, objectify_options(options), @default_options.merge(html_options))
    end

    def grouped_collection_select_with_hashes(method, collection, group_method, group_label_method, option_key_method,
                                  option_value_method, options = {}, html_options = {})
      options = options_with_value(options, method)
      template.grouped_collection_select(spinner.encode(object_name), spinner.encode(method), collection, group_method,
                                         group_label_method, option_key_method, option_value_method,
                                         objectify_options(options), @default_options.merge(html_options))
    end

    def time_zone_select_with_hashes(method, priority_zones = nil, options = {}, html_options = {})
      options = options_with_value(options, method)
      template.time_zone_select(spinner.encode(object_name), spinner.encode(method), priority_zones,
                                objectify_options(options), @default_options.merge(html_options))
    end

    %w(hidden_field text_field text_area file_field password_field date_select datetime_select time_select
       ).each do |field|
      line = __LINE__ + 2
      code = <<-end_code
        def #{field}_with_hashes(method, options = {}, *args)
          options = options_with_value(options, method)
          template.#{field}(spinner.encode(object_name), spinner.encode(method), objectify_options(options), *args)
        end
      end_code
      eval code, binding, __FILE__, line
    end

    def label(method, text = nil, options = {})
      if template.controller.send(:protect_against_forgery?)
        text ||= method.to_s.humanize
        template.label(spinner.encode(object_name), spinner.encode(method), text, objectify_options(options))
      else
        template.label(object_name, method, text, objectify_options(options))
      end
    end
    #object_name, method, options = {}, checked_value = "1", unchecked_value = "0"
    def check_box_with_hashes(method, options = {}, checked_value = "1", unchecked_value = "0")
      options = options.dup
      if object && object.respond_to?(method)
        if ActionView::Helpers::InstanceTag.check_box_checked?(object.send(method), checked_value)
          options.merge!(:checked => true)
        else options.merge! :checked => false
        end
      end
      template.check_box(spinner.encode(object_name), spinner.encode(method),
                         objectify_options(options), checked_value, unchecked_value)
    end

    def radio_button_with_hashes(method, tag_value, options = {})
      options = options.dup
      if object && object.respond_to?(method)
        if ActionView::Helpers::InstanceTag.radio_button_checked?(object.send(method), tag_value)
          options.merge!(:checked => true)
        else options.merge!(:checked => false)
        end
      end
      template.radio_button(spinner.encode(object_name), spinner.encode(method), tag_value, objectify_options(options))
    end

    %w(hidden_field text_field text_area file_field password_field check_box radio_button
       select collection_select grouped_collection_select time_zone_select date_select
       datetime_select time_select).each do |field|
      line = __LINE__ + 2
      code = <<-end_code
        def #{field}_with_obfuscation(method, *args)                                # def text_field_with_obfuscation(method, *args)
          if template.controller.send(:protect_against_forgery?)                    # if template.controller.send(:protect_against_forgery?)
            #{field}_honeypot(method, *args) + #{field}_with_hashes(method, *args)  #   text_field_honeypot(method, *args) + text_field_with_hashes(method, *args)
          else                                                                      # else
            # no forgery protection means no authenticity token, means no secret.   #
            # We could feasibly code around this, but if forgery protection is      #
            # disabled then it is so for a reason,                                  #
            # and user may not WANT obfuscation.                                    #
            #{field}_without_obfuscation(method, *args)                             #   text_field_without_obfuscation(method, *args)
          end                                                                       # end
        end

        alias_method_chain :#{field}, :obfuscation                                  # alias_method_chain :text_field, :obfuscation
      end_code
      eval code, binding, __FILE__, line
    end

    def options_with_value(options, method)
      options = options.dup
      if object && object.respond_to?(method)
        value = object.send(method)
        options.reverse_merge! :value => (caller[0][/date|time/] ? value : value.to_s)
      end
      options
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
