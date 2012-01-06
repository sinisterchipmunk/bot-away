class ActionView::Helpers::InstanceTag
  attr_reader :spinner

  def initialize_with_spinner(object_name, method_name, template_object, object = nil)
    initialize_without_spinner(object_name, method_name, template_object, object)
    
    if template_object.controller.send(:protect_against_forgery?) &&
               !BotAway.excluded?(:object_name => object_name, :method_name => method_name) &&
               !BotAway.excluded?(:controller => template_object.controller.controller_name,
                                  :action => template_object.controller.action_name)
      @spinner = BotAway::Spinner.new(template_object.request.ip, object_name, template_object.form_authenticity_token)
    end
  end

  def obfuscate_options(options)
    add_default_name_and_id(options)
    assuming(spinner && options) do
      options['name'] &&= spinner.encode(options['name'])
      options['id'] &&= spinner.encode(options['id'])
    end
  end

  def honeypot_options(options)
    add_default_name_and_id(options)
    assuming(spinner && options) do
      options['value'] &&= ''
      options['autocomplete'] = 'off'
      options['tabindex'] = -rand(10) - 1
    end
  end

  def assuming(object)
    yield if object
    object
  end
  
  def honeypot_tag(name, options = nil, *args)
    tag_without_honeypot(name, honeypot_options(options ? options.dup : {}), *args)
  end

  def obfuscated_tag(name, options = nil, *args)
    tag_without_honeypot(name, obfuscate_options(options ? options.dup : {}), *args)
  end

  def tag_with_honeypot(name, options = nil, *args)
    if spinner
      obfuscated_tag(name, options, *args) + disguise(honeypot_tag(name, options, *args))
    else
      tag_without_honeypot(name, options, *args)
    end
  end

  # Special case
  def to_label_tag_with_obfuscation(text = nil, options = {}, &block)
    # TODO: Can this be simplified? It's pretty similar to to_label_tag_without_obfuscation...
    options = options.stringify_keys
    tag_value = options.delete("value")
    name_and_id = options.dup

    if name_and_id["for"]
      name_and_id["id"] = name_and_id["for"]
    else
      name_and_id.delete("id")
    end

    add_default_name_and_id_for_value(tag_value, name_and_id)
    options["for"] ||= name_and_id["id"]
    options["for"] = spinner.encode(options["for"]) if spinner && options["for"]
    to_label_tag_without_obfuscation(text, options)
  end

  def content_tag_with_obfuscation(name, content_or_options_with_block = nil, options = nil, *args, &block)
    if block_given?
      content_tag_without_obfuscation(name, content_or_options_with_block, options, *args, &block)
    else
      # this should cover all Rails selects.
      if spinner && options && (options.keys.include?('id') || options.keys.include?('name'))
        if name == 'select' && !content_or_options_with_block.empty?
          content = '<option selected value=""></option>'
        else
          content = ""
        end
        disguise(content_tag_without_obfuscation(name, content, honeypot_options(options), *args)) +
                content_tag_without_obfuscation(name, content_or_options_with_block, obfuscate_options(options), *args)
      else
        content_tag_without_obfuscation(name, content_or_options_with_block, options, *args)
      end
    end
  end

  alias_method_chain :initialize, :spinner
  alias_method_chain :tag, :honeypot
  alias_method_chain :to_label_tag, :obfuscation
  alias_method_chain :content_tag, :obfuscation

  def disguise(element)
    return element.replace("Honeypot(#{element})") if BotAway.show_honeypots
    case rand(3)
      when 0 # Hidden
        element.replace "<div style='display:none;'>Leave this empty: #{element}</div>"
      when 1 # Off-screen
        element.replace "<div style='position:absolute;left:-1000px;top:-1000px;'>Don't fill this in: #{element}</div>"
      when 2 # Negligible size
        element.replace "<div style='position:absolute;width:0px;height:1px;z-index:-1;color:transparent;overflow:hidden;'>Keep this blank: #{element}</div>"
      else # this should never happen?
        disguise(element)
    end
  end
end
