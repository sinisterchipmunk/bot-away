class ActionView::Helpers::InstanceTag
=begin
  attr_reader :spinner

  def initialize_with_spinner(object_name, method_name, template_object, object = nil)
    initialize_without_spinner(object_name, method_name, template_object, object)
    if template_object.controller.send(:protect_against_forgery?)
      @spinner = Spinner.new(template_object.ip, object_name, template_object.form_authenticity_token)
    end
  end

  def to_input_field_tag_with_honeypot(field_type, options = {})
    options = options.stringify_keys
    options["size"] = options["maxlength"] || DEFAULT_FIELD_OPTIONS["size"] unless options.key?("size")
    options = DEFAULT_FIELD_OPTIONS.merge(options)
    if field_type == "hidden"
      options.delete("size")
    end
    options["type"] = field_type
    options["value"] = options["value"].to_s if options.key?("value")
    options["value"] ||= value_before_type_cast(object) unless field_type == "file"
    options["value"] &&= html_escape(options["value"])
    add_default_name_and_id(options)
    disguise(tag("input", options)) + to_input_field_tag_without_honeypot(field_type, options)
  end

  #def add_default_name_and_id_with_obfuscation(options)
  #  add_default_name_and_id_without_obfuscation(options)
  #  options["name"] = spinner.encode(options["name"])
  #  options["id"] = spinner.encode(options["id"])
  #end

  def tag_with_obfuscation(name, options = nil, open = false, escape = true)
    if options
      options['id'] = spinner.encode(options['id']) if options.key?('id')
      options['name'] = spinner.encode(options['name']) if options.key?('name')
    end
    tag_without_obfuscation(name, options, open, escape)
  end

  alias_method_chain :initialize, :spinner
  alias_method_chain :tag, :obfuscation
  alias_method_chain :to_input_field_tag, :honeypot

  def disguise(tag)
    "disguise { #{tag} }"
  end
=end

  def error_message
    object.errors.on(BotProofForms::Spinner.new(ip, @method_name, secret).encode(@method_name))
  end

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