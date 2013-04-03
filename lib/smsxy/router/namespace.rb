require 'hash_regex'
require 'smsxy/adaptor'
module SMSXY
  class Router
    class Namespace
      @@sms = nil
      attr_accessor :matcher, :block, :parent, :message
      # ::nordoc
      DELIMITER = " ".freeze
      EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i.freeze

      def match(matcher, &block)
        raise ArgumentError, "You must provide a block with each route" if block.nil?
        matcher = email if matcher.to_s == 'email'
        if matcher.class == String || matcher.class == Regexp
          matchers[matcher] = block
        else
          raise ArgumentError, "Can only match text messages against strings or regexes"
        end
      end

      def help(&block)
        if !block.nil?
          @help = block
        elsif !@help.nil?
          @help.call
        elsif self.parent && self.parent.help?
          self.parent.help
        else
          default_help
        end
      end

      def namespace(matcher, &routes)
        matcher = email if matcher.to_s == 'email'
        raise ArgumentError, "Matcher must be Regexp or String." if matcher.class != Regexp && matcher.class != String
        namespace = SMSXY::Router::Namespace.new
        namespace.matcher = matcher
        namespace.instance_eval(&routes)
        namespace.parent = self if self.respond_to? "matcher"
        namespaces[matcher] = namespace
        namespace
      end

      def receive(message)
        self.message = message
        # Split up the body of the SMS by the delimiter
        components = message.split(DELIMITER)
        # puts "Components: #{components.inspect}"
        # puts "Matchers: #{matchers.inspect}"
        # Let's check if we have any matchers that match that SMS
        if !matchers[message].nil?
          # Cool, let's call that method now with the sms
          matchers[message].call
        # Let's look for matching namespaces
        elsif space = namespaces[components.first]
          space.receive(components[1..-1].join(DELIMITER))
        else
          help
        end
      end

      def help?
        !@help.nil?
      end

      def matchers
        @matchers ||= {}.to_hash_regex
      end

      def call
        self.instance_eval(&block)
      end

      def namespaces
        @namespaces ||= {}.to_hash_regex
      end

      def params
        SMSXY::Router::Namespace.sms.message.split(DELIMITER)
      end

      def reply(message)
        SMSXY.text(message, SMSXY::Router::Namespace.sms.phone)
      end

      def self.sms
        @sms
      end

      def self.sms=(val)
        @sms = val
      end

      def email
        EMAIL_REGEX
      end

      def default_help
        Proc.new { puts "No matcher for message: \"#{self.message}\"! Also, no \"help\" block to handle unmatched messages." }
      end

    end
  end
end