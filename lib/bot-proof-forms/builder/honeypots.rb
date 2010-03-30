module BotProofForms
  class Builder < ActionView::Helpers::FormBuilder
    module Honeypots
      def date_select_honeypot(method, options = {}, html_options = {})
        disguise(date_select_without_obfuscation(method, options_with_nil_value(options, nil), html_options))
      end

      def time_select_honeypot(method, options = {}, html_options = {})
        disguise(time_select_without_obfuscation(method, options_with_nil_value(options, nil), html_options))
      end

      def datetime_select_honeypot(method, options = {}, html_options = {})
        disguise(datetime_select_without_obfuscation(method, options_with_nil_value(options, nil), html_options))
      end

      def check_box_honeypot(method, options = {}, checked_value = "1", unchecked_value = "0")
        disguise(check_box_without_obfuscation(method, options_with_nil_value(options), checked_value, unchecked_value))
      end

      def radio_button_honeypot(method, tag_value, options = {})
        disguise(radio_button_without_obfuscation(method, tag_value, options_with_nil_value(options)))
      end

      %w(file_field hidden_field password_field text_area text_field).each do |field|
        code = <<-end_code
        def #{field}_honeypot(method, options = {})
          disguise(self.send("#{field}_without_obfuscation", method, options_with_nil_value(options)))
        end
        end_code
        eval code
      end

      def collection_select_honeypot(method, collection, value_method, text_method, options = {}, html_options = {})
        disguise(collection_select_without_obfuscation(method, collection, value_method, text_method, options_with_nil_value(options), html_options))
      end

      def grouped_collection_select_honeypot(method, collection, group_method, group_label_method, option_key_method, option_value_method, options = {}, html_options = {})
        disguise(grouped_collection_select_without_obfuscation(method, collection, group_method, group_label_method, option_key_method, option_value_method, options_with_nil_value(options), html_options))
      end

      def select_honeypot(method, choices, options = {}, html_options = {})
        disguise(select_without_obfuscation(method, choices, options_with_nil_value(options), html_options))
      end

      def time_zone_select_honeypot(method, priority_zones = nil, options = {}, html_options = {})
        disguise(time_zone_select_without_obfuscation(method, priority_zones, options_with_nil_value(options, nil), html_options))
      end

      private
      def options_with_nil_value(options, value = '')
        options.merge(:value => value)
      end
    end
  end
end
