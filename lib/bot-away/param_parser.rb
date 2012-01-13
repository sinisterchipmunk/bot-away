module BotAway
  class ParamParser
    attr_reader :params, :ip, :authenticity_token

    def initialize(ip, params, authenticity_token = nil)
      params = params.with_indifferent_access if !params.kind_of?(HashWithIndifferentAccess)
      authenticity_token ||= params[:authenticity_token]
      @ip, @params, @authenticity_token = ip, params, authenticity_token
      
      if BotAway.dump_params
        Rails.logger.debug("[BotAway] IP: #{@ip}")
        Rails.logger.debug("[BotAway] Authenticity token: #{@authenticity_token}")
        Rails.logger.debug("[BotAway] Parameters: #{params.inspect}")
      end
      
      if authenticity_token
        if catch(:bastard) { deobfuscate! } == :took_the_bait
          # don't clear the controller or action keys, as Rails 3 needs them
          params.keys.each { |key| params.delete(key) unless %w(controller action).include?(key) }
          params[:suspected_bot] = true
        end
      end
    end

    def deobfuscate!(current = params, object_name = nil)
      return current if BotAway.excluded?(:controller => params[:controller], :action => params[:action])
      
      if object_name
        spinner = BotAway::Spinner.new(ip, object_name, authenticity_token)
      end
      
      current.each do |key, value|
        if value.kind_of?(Hash)
          deobfuscate!(value, object_name ? "#{object_name}[#{key}]" : key)
        else
          if object_name && !BotAway.excluded?(:object_name => object_name, :method_name => key)
            if value.blank? && params.keys.include?(spun_key = spinner.encode("#{object_name}[#{key}]"))
              current[key] = params.delete(spun_key)
            else
              #puts "throwing on #{object_name}[#{key}] because its not blank" if !value.blank?
              #puts "throwing on #{object_name}[#{key}] because its not found" if defined?(spun_key) && !spun_key.nil?
              throw :bastard, :took_the_bait
            end
          end
        end
      end
    end
  end
end
