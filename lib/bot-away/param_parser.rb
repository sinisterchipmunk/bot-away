class BotAway::ParamParser
  include BotAway::TimeHelpers

  attr_reader :original_params, :resultant_params

  def initialize original_params
    @original_params = original_params.with_indifferent_access
    @resultant_params = @original_params.dup

    process
    original_params.clear
    original_params.merge! resultant_params
  end

  def process
    return bot_detected if signature_mismatch?
    return if hashed_fields.empty?
    return bot_detected if too_fast?
    return bot_detected if too_slow?

    honeypot_fields.each do |field|
      return bot_detected unless original_params[field].blank?
      resultant_params[field] = real_value_for field
      resultant_params.delete honeypot_map[field]
    end
  end

  # Returns true if the signature generated from all of the hashed field names
  # is not the same as the signature submitted with the form data.
  def signature_mismatch?
    original_params['_ba_signature'] != signature
  end

  # Returns a hex string which is a signature generated from the
  # hashed field names sent as part of the request. The resultant
  # signature will only be correct if the hex strings were not tampered with.
  # Check for correctness by calling #signature_mismatch?
  def signature
    BotAway::Spinner.signature hashed_fields
  end

  # Returns true if the salt for a new spinner matches any of the salts used
  # in the request parameters. In this case, the request came too quickly
  # after the original form was generated, indicating an automated client.
  def too_fast?
    current_salt = BotAway::Spinner.generate_salt
    honeypot_map.each do |field, hash|
      salt = hash[0...BotAway::Spinner::SALT_LENGTH]
      return true if current_salt == salt
    end
    false
  end

  # Returns true if none of the salts that would be generated within the last
  # N seconds matches the salts that were actually used for the request, where
  # N is the value of `BotAway.max_form_age`. In this case, the request came
  # too long after the original form was generated, indicating that the
  # request may have been replayed from a previous session.
  def too_slow?
    time = current_time.to_i
    time.step time - BotAway.max_form_age, -BotAway.time_increment do |time|
      salt_in_time = BotAway::Spinner.generate_salt time
      honeypot_map.values.each do |spun_value|
        return false if spun_value[0...BotAway::Spinner::SALT_LENGTH] == salt_in_time
      end
    end
    true
  end

  def real_value_for field
    original_params[honeypot_map[field]]
  end

  # Called when a bot is detected. This method invalidates the authenticity
  # token.
  def bot_detected
    resultant_params.delete 'authenticity_token'
  end

  # Returns every field whose name is a hashed field name
  def hashed_fields
    len = BotAway::Spinner::SALT_LENGTH + BotAway::Spinner::HASH_LENGTH
    @hashed_fields ||= original_params.keys.select do |name|
      name =~ /\A[a-f0-9]{#{len},#{len}}\z/
    end
  end

  # Returns every field whose name is NOT a hashed field name, but
  # for which there is a corresponding hex string.
  def honeypot_fields
    @honeypot_fields ||= honeypot_map.keys
  end

  # Returns every field which is neither a hashed nor honeypot field.
  # The authenticity token falls into this category.
  def extra_fields
    @extra_fields ||= original_params.keys - (hashed_fields + honeypot_fields)
  end

  # Constructs a Hash of `{ field_name => hashed_value }` for all honeypots
  # given in the params.
  def honeypot_map
    @honeypot_map ||= original_params.keys.reduce({}) do |hash, key|
      if hashed_key = honeypot?(key)
        hash[key] = hashed_key
      end
      hash
    end
  end

  # Returns a truthy value if the given field name is a honeypot. The named
  # field is a honeypot if it is not a hashed field name, and if there
  # is a hashed field name which matches its hash.
  #
  # The truthy value is the hash that the honeypot maps to. If no mapping
  # could be found, `false` is returned.
  def honeypot? name
    len = BotAway::Spinner::SALT_LENGTH + BotAway::Spinner::HASH_LENGTH
    return false if name =~ /\A[a-f0-9]{#{len},#{len}}\z/
    hashed_fields.each do |hashed_name|
      salt = hashed_name[0...BotAway::Spinner::SALT_LENGTH]
      digested_hash = BotAway::Spinner.spin name, salt
      return hashed_name if hashed_name == digested_hash
    end
    false
  end
end
