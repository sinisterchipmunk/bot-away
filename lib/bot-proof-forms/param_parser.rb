module BotProofForms
  class ParamParser
    class ObfuscationMissing < StandardError; end #:nodoc:

    attr_reader :params, :ip, :authenticity_token

    def initialize(ip, params, authenticity_token = params[:authenticity_token])
      @ip, @params, @authenticity_token = ip, params, authenticity_token
      if authenticity_token
        if catch(:bastard) { deobfuscate! } == :took_the_bait
          params.clear
          params[:suspected_bot] = true
        end
      end
    end

    def deobfuscate!(current = params, object_name = nil)
      if object_name
        spinner = BotProofForms::Spinner.new(ip, object_name, authenticity_token)
      end
      
      current.each do |key, value|
        if object_name
          if value.blank? && params.keys.include?(spun_key = spinner.encode("#{object_name}[#{key}]"))
            current[key] = params.delete(spun_key)
          else
            throw :bastard, :took_the_bait
          end
        end
        if value.kind_of?(Hash)
          deobfuscate!(value, object_name ? "#{object_name}[#{key}]" : key)
        end
      end
    end


=begin
    attr_reader :params, :ip, :authenticity_token, :spinner

    def initialize(ip, params, authenticity_token = params[:authenticity_token], spinner = nil)
      @ip = ip
      @params = params
      @authenticity_token = authenticity_token
      @spinner = spinner
      if authenticity_token
        if catch(:bastard) { while !deobfuscate! ; end } == :took_the_bait
          # we caught a spambot... Just drop the whole request.
          params.clear
          params[:suspected_bot] = true
        end
      end
    end

    private
    def deobfuscate!
      for key in params.keys
        spinner = self.spinner || BotProofForms::Spinner.new(ip, key, authenticity_token)
        deobfuscate(params, key, spinner)
      end
      true
    end

    def deobfuscate(params, key, spinner, raise_on_missing = false)
      if params.key?(spun_key = spinner.encode(key))
        params[key] = deobfuscate_nested_hash(params.delete(key), params.delete(spun_key), spinner)
      else
        raise ObfuscationMissing if raise_on_missing
      end
      params
    end

    # since the key for this entire value is obfuscated, we can assume that everything from this
    # point downward is also obfuscated. What we DON'T know is whether its key was the current spinner,
    # or if it was re-created using some lower level key as part of the secret.
    # So we'll try to deobfuscate based on what's known, and then fall back to creating a new parser.
    def deobfuscate_nested_hash(honeypot, spun_value, spinner)
      check_commonality(honeypot, spun_value)
      if spun_value.kind_of?(Hash)
        honeypot.each do |key, value|
          check_for_spambots(value)
          begin
            deobfuscate(spun_value, key, spinner, true)
          rescue ObfuscationMissing
            deobfuscate(spun_value, key, BotProofForms::Spinner.new(ip, key, authenticity_token))
          end
        end
        spun_value
      else
        spun_value
      end
    end

    def check_for_spambots(value)
      # check for spambots
      if value.kind_of?(Enumerable)
        throw :bastard, :took_the_bait if !value.empty?
      else
        throw :bastard, :took_the_bait if !value.blank?
      end
    end
    
    def check_commonality(honeypot, spun_value)
      if (one_kind_of?(Hash, honeypot, spun_value) ||
              one_kind_of?(Array, honeypot, spun_value)) &&
              !spun_value.is_a?(honeypot.class)
        # how do you know the value isn't a collection? ie, "post_ids"
        #raise "Oops! Spun value #{spun_value.inspect} is not the same type as honeypot #{honeypot.inspect}"
      end
    end

    def one_kind_of?(type, *objects)
      objects.each { |o| return true if o.kind_of?(type) }
      false
    end
=end
  end
end
