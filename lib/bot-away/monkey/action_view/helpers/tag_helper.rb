require 'action_view/helpers'

module ActionView::Helpers::TagHelper
  alias_method :original_tag, :tag
  alias_method :original_content_tag, :content_tag

  def tag name, options = nil, open = false, escape = true
    if options && BotAway::OBFUSCATED_TAGS.include?(name)
      honeypot_tag(name, options, open, escape) +
      obfuscated_tag(name, options, open, escape)
    elsif options && name == 'label'
      honeypot_label(name, options, open, escape) +
      obfuscated_label(name, options, open, escape)
    else
      original_tag name, options, open, escape
    end
  end

  def content_tag name, content_or_options_with_block = nil, options = nil, escape = true, &block
    if name == :label
      if block_given?
        options = content_or_options_with_block if content_or_options_with_block.is_a?(Hash)
        options['for'] = BotAway::Spinner.spin(options['for']) if options && options['for']
        content_tag_string(name, capture(&block), options, escape)
      else
        text = content_or_options_with_block
        escaped_text = text.to_s.chars.collect { |b| "&#x#{b.ord.to_s(16)};" }.join.html_safe
        options['for'] = BotAway::Spinner.spin(options['for']) if options && options['for']
        content_tag_string(name, escaped_text, options, escape)
      end
    else
      original_content_tag name, content_or_options_with_block, options, escape, &block
    end
  end

  def honeypot_tag name, options, open, escape
    options.reverse_merge! 'honeypot' => true
    if honeypot = options.delete('honeypot')
      options = options.dup
      options['style'] = "display:none;#{options['style']}"
      original_tag name, options, open, escape
    else
      "".html_safe
    end
  end

  def obfuscated_tag name, options, open, escape
    spun_name = BotAway::Spinner.spin options['name']
    spun_id = BotAway::Spinner.spin options['id']
    options = options.merge 'name' => spun_name, 'id' => spun_id
    original_tag name, options, open, escape
  end

  def honeypot_label name, options, open, escape
    # TODO hide the honeypot
    original_tag name, options, open, escape
  end

  def obfuscated_label name, options, open, escape
    spun_for = BotAway::Spinner.spin options['for']
    options = options.merge 'for' => spun_for
    original_tag name, options, open, escape
  end
end
