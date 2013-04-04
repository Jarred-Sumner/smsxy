require 'hash_regex'
require 'smsxy/adaptor'
module SMSXY
  class Router
    class Namespace
      @@sms = nil
      attr_accessor :matcher, :block, :parent, :sms
      # ::nordoc
      DELIMITER = " ".freeze
      EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i.freeze

      TEN_DIGIT_US_PHONE_NUMBER           = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/.freeze
      TEN_DIGIT_US_PHONE_NUMBER_WITH_ONE  = /^(?:\+?1[-. ]?)?\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/.freeze
      INTERNATIONAL_PHONE_NUMBER          = /^\+(?:[0-9] ?){6,14}[0-9]$/.freeze

      def match(matcher, &block)
        raise ArgumentError, "You must provide a block with each route" if block.nil?
        matcher = email if matcher.to_s == 'email'
        matcher = phone if matcher.to_s == 'phone'
        if matcher.class == String || matcher.class == Regexp
          matchers[matcher] = block
        elsif matcher.class == Array
          matcher.each do |match|
            matchers[match] = block
          end
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
        matcher = phone if matcher.to_s == 'phone'
        if matcher.respond_to?("each")
          matcher.each do |match|
            raise ArgumentError, "Matcher must be Regexp, String" if match.class != Regexp && match.class != String
            namespace = SMSXY::Router::Namespace.new
            namespace.matcher = match
            namespace.instance_eval(&routes)
            namespace.parent = self if self.respond_to? "matcher"
            namespaces[match] = namespace
          end
        else
          raise ArgumentError, "Matcher must be Regexp, String" if matcher.class != Regexp && matcher.class != String
          namespace = SMSXY::Router::Namespace.new
          namespace.matcher = matcher
          namespace.instance_eval(&routes)
          namespace.parent = self if self.respond_to? "matcher"
          namespaces[matcher] = namespace
          namespace
        end
      end

      def receive(sms)
        self.sms = sms
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
          abbrievd_sms         = sms
          abbrievd_sms.message = components[1..-1].join(DELIMITER)
          space.receive(abbrievd_sms)
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
        self.sms.full_message.split(DELIMITER)
      end

      def reply(message)
        SMSXY.text(message, self.sms.phone)
      end

      def email
        EMAIL_REGEX
      end

      def phone
        [TEN_DIGIT_US_PHONE_NUMBER, TEN_DIGIT_US_PHONE_NUMBER_WITH_ONE, INTERNATIONAL_PHONE_NUMBER]
      end

      def default_help
        Proc.new { puts "No matcher for message: \"#{self.sms.message}\"! Also, no \"help\" block to handle unmatched messages." }
      end

    end
  end
end