require 'action_view/helpers'

module ActionView::Helpers::FormTagHelper
  # alias_method :original_form_tag_in_block, :form_tag_in_block

  def form_tag_in_block(html_options, &block)
    content = capture(&block)
    output = form_tag_html html_options
    output << content
    if spun_hashes = find_spun_hashes_in(content)
      signature = BotAway::Spinner.signature(*spun_hashes)
      html = "<input type='hidden' name='_ba_signature' " +
                    "value='#{signature}' />"
      output.safe_concat html
    end
    output.safe_concat "</form>"
  end

  # Returns an array of all occurrances of hashed field names in the
  # specified content string.
  def find_spun_hashes_in content
    len = BotAway::Spinner::SALT_LENGTH + BotAway::Spinner::HASH_LENGTH
    content.scan(/name="([a-f0-9]{#{len},#{len}})"/m).flatten
  end
end
