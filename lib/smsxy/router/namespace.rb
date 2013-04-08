require 'hash_regex'
require 'smsxy/adaptor'
module SMSXY
  class Router
    class Namespace
      @@sms = nil
      attr_accessor :matcher, :block, :parent, :sms, :current_match, :vars
      # ::nordoc
      DELIMITER = " ".freeze
      EMAIL_REGEX = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i.freeze

      TEN_DIGIT_US_PHONE_NUMBER           = /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/.freeze
      TEN_DIGIT_US_PHONE_NUMBER_WITH_ONE  = /^(?:\+?1[-. ]?)?\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/.freeze
      INTERNATIONAL_PHONE_NUMBER          = /^\+(?:[0-9] ?){6,14}[0-9]$/.freeze

      def let(symbol, &block)
        self.vars ||= {}
        self.vars[symbol] = block
      end

      def combined_vars
        self.vars ||= {}
        self.vars.merge!(self.parent.combined_vars) unless self.parent.nil?
        self.vars
      end

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
          raise ArgumentError, "Can only match text messages against strings or regexes, or an array of strings and regexes"
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

      def before(&block)
        @before = block
      end

      def before!
        unless self.parent.nil?
          self.parent.before! 
        end
        @before.call unless @before.nil?
      end

      def after(&block)
        @after = block
      end

      def after!
        unless self.parent.nil?
          self.parent.after!
        end
        @after.call unless @after.nil?
      end

      def redirect_to(method_sym)
        SMSXY.log("Redirecting to #{method_sym}", :tag => self.sms) 
        self.current_match = method(method_sym).to_proc
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

      def matches?(message)
        !matchers[sms.message].nil?
      end

      def match!(message)
        self.current_match = matchers[sms.message]
        before!
        return_data = self.current_match.call
        after!
        return_data
      end

      def receive(sms)
        self.sms = sms
        # Split up the body of the SMS by the delimiter
        components = sms.message.split(DELIMITER)
        # puts "Components: #{components.inspect}"
        # puts "Matchers: #{matchers.inspect}"
        # Let's check if we have any matchers that match that SMS
        if matches?(sms.message)
          # Cool, let's call that method now with the sms
          match!(sms.message)
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
        SMSXY.text(message, self.sms.phone, self.sms)
      end

      def email
        EMAIL_REGEX
      end

      def phone
        [TEN_DIGIT_US_PHONE_NUMBER, TEN_DIGIT_US_PHONE_NUMBER_WITH_ONE, INTERNATIONAL_PHONE_NUMBER]
      end

      def default_help
        Proc.new { SMSXY.log "No matcher for message: \"#{self.sms.message}\"! Also, no \"help\" block to handle unmatched messages." }
      end

      def method_missing(meth, *args, &blk)
        if self.combined_vars[meth]
          self.combined_vars[meth].call
        else
          super
        end
      end

    end
  end
end