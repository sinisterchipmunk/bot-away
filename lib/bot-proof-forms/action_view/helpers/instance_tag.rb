class ActionView::Helpers::InstanceTag
  def datetime_selector(options, html_options)
    datetime = options.key?(:value) ? options.delete(:value) : value(object) || default_datetime(options)

    options = options.dup
    options[:field_name]           = @method_name
    options[:include_position]     = true
    options[:prefix]             ||= @object_name
    options[:index]                = @auto_index if defined?(@auto_index) && @auto_index && !options.has_key?(:index)
    options[:datetime_separator] ||= ' &mdash; '
    options[:time_separator]     ||= ' : '

    ActionView::Helpers::DateTimeSelector.new(datetime, options.merge(:tag => true), html_options)
  end

  def to_select_tag(choices, options, html_options)
    html_options = html_options.stringify_keys
    add_default_name_and_id(html_options)
    value = options.key?(:value) ? options.delete(:value) : value(object)
    selected_value = options.has_key?(:selected) ? options[:selected] : value
    disabled_value = options.has_key?(:disabled) ? options[:disabled] : nil
    content_tag("select", add_options(options_for_select(choices, :selected => selected_value, :disabled => disabled_value), options, selected_value), html_options)
  end

  def to_collection_select_tag(collection, value_method, text_method, options, html_options)
    html_options = html_options.stringify_keys
    add_default_name_and_id(html_options)
    value = options.key?(:value) ? options.delete(:value) : value(object)
    disabled_value = options.has_key?(:disabled) ? options[:disabled] : nil
    selected_value = options.has_key?(:selected) ? options[:selected] : value
    content_tag(
      "select", add_options(options_from_collection_for_select(collection, value_method, text_method, :selected => selected_value, :disabled => disabled_value), options, value), html_options
    )
  end

  def to_grouped_collection_select_tag(collection, group_method, group_label_method, option_key_method, option_value_method, options, html_options)
    html_options = html_options.stringify_keys
    add_default_name_and_id(html_options)
    value = options.key?(:value) ? options.delete(:value) : value(object)
    content_tag(
      "select", add_options(option_groups_from_collection_for_select(collection, group_method, group_label_method, option_key_method, option_value_method, value), options, value), html_options
    )
  end

  def to_time_zone_select_tag(priority_zones, options, html_options)
    html_options = html_options.stringify_keys
    add_default_name_and_id(html_options)
    value = options.key?(:value) ? options.delete(:value) : value(object)
    content_tag("select",
      add_options(
        time_zone_options_for_select(value || options[:default], priority_zones, options[:model] || ActiveSupport::TimeZone),
        options, value
      ), html_options
    )
  end
end