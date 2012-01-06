module BotAway
  module Version
    MAJOR = 2
    MINOR = 0
    PATCH = 0
    BUILD = nil
    
    STRING = BUILD ? [MAJOR, MINOR, PATCH, BUILD].join('.') : [MAJOR, MINOR, PATCH].join('.')
  end

  VERSION = BotAway::Version::STRING
end
