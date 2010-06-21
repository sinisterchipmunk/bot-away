require 'spec/mocks'

module Rails
  class << self
    def logger
      return @logger if @logger
      @logger = Object.new
      klass = class << @logger; self; end
      klass.send(:include, Spec::Mocks::Methods)
      
      def @logger.debug(message); end
      def @logger.info(message); end
      def @logger.error(message); end
      def @logger.warn(message); end
      @logger
    end
  end
end