require 'hash_regex'
require 'smsxy/adaptor'
module SMSXY
  class Router
    class Namespace
      attr_accessor :matcher, :block, :parent, :sms
      DELIMITER = " ".freeze

      def match(matcher, &block)
        raise ArgumentError, "You must provide a block with each route" if block.nil?
        if matcher.class == String || matcher.class == Regexp
          matchers[matcher] = block
        else
          raise ArgumentError, "Can only match text messages against strings or regexes"
        end
      end

      def namespace(matcher, &routes)
        raise ArgumentError, "Matcher must be Regexp or String." if matcher.class != Regexp && matcher.class != String
        namespace = SMSXY::Router::Namespace.new
        namespace.matcher = matcher
        namespace.instance_eval(&routes)
        namespace.parent = self if self.respond_to? "matcher"
        namespaces[matcher] = namespace
        namespace
      end

      def help(&block)
        @help = block
      end

      def receive(sms)
        # Split up the body of the SMS by the delimiter
        components = sms.message.split(DELIMITER)
        # puts "Components: #{components.inspect}"
        # puts "Matchers: #{matchers.inspect}"
        # Let's check if we have any matchers that match that SMS
        if !matchers[sms.message].nil?
          # Cool, let's call that method now with the sms
          matchers[sms.message].call
        # Let's look for matching namespaces
        elsif space = namespaces[components.first]
          space.sms          = self.sms
          sms.message        = components[1..-1].join(DELIMITER)
          space.receive(sms)
        else
          @help.call
        end
      end

      def matchers
        @matchers ||= {}.to_hash_regex
      end

      def call
        self.eval(&block)
      end

      def namespaces
        @namespaces ||= {}.to_hash_regex
      end

      def params
        self.sms.message.split(DELIMITER)
      end

      def reply(message)
        SMSXY::Adaptor.adaptor.text(message, self.sms.phone)
      end

      alias_method :h, :help
    end
  end
end