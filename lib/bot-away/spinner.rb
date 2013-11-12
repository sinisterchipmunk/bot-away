class BotAway::Spinner
  include BotAway::TimeHelpers

  attr_reader :value, :salt

  SALT_LENGTH = 64
  HASH_LENGTH = 64

  class << self
    def spin value, *salt
      new(value, *salt).hash
    end

    def generate_salt time = nil
      time ||= BotAway::Spinner.new(nil).time
      digest time.to_i.to_s
    end

    def digest *keys
      Digest::SHA2.hexdigest [ Rails.configuration.secret_key_base,
                               *keys ].join('-"')
    end

    # Returns a digital signature by building an MD5 digest from the specified
    # string and the application's secret token.
    #
    # TODO: investigate the need and feasibility to include timestamp in SHA.
    def signature *string
      salt = digest Rails.configuration.secret_key_base
      spin(string.flatten.sort.join('-'), salt)[SALT_LENGTH..-1]
    end
  end

  def initialize value, salt = nil
    @value = value
    @salt = salt || BotAway::Spinner.generate_salt(time)
  end

  def time
    @time ||= current_time
  end

  def hash
    digested_value = self.class.digest salt, value
    [ salt, digested_value ].join
  end
end
