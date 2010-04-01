module BotAway
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
        spinner = BotAway::Spinner.new(ip, object_name, authenticity_token)
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
  end
end
