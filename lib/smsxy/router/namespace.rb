module SMSXY
  class Router
    class Namespace
      attr_accessor :matcher, :block, :parent
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
        puts "Components: #{components.inspect}"
        puts "Matchers: #{matchers.inspect}"
        # Let's check if we have any matchers that match that SMS
        if !matchers[sms.message].nil?
          # Cool, let's call that method now with the sms
          matchers[sms.message].call
        # Let's look for matching namespaces
        elsif namespaces[components.first]
          namespace = namespaces[components.first]
          namespace.params.push(components.first)
          sms.message = components[1..-1].join(DELIMITER)
          namespace.receive(sms)
        else
          @help.call
        end
      end

      def params
        @params ||= []
      end

      def matchers
        @matchers ||= {}.to_hash_regex
      end

      def params
        if @params.nil?
          if self.parent
            @params = self.parent.params
          else
            @params = []
          end
          @params.unshift(matcher)
        end
        @params
      end

      def call
        self.eval(&block)
      end

      def namespaces
        @namespaces ||= {}.to_hash_regex
      end

      alias_method :h, :help
    end
  end
end