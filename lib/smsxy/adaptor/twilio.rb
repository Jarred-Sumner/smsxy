require 'twilio-ruby'
module SMSXY
  class Adaptor
    class Twilio < Adaptor
    
      def self.text(message, to)
        raise ArgumentError, "Twilio requires an Account SID to send outgoing text messages. Set SMSXY::Adaptor::Twilio.account_sid to your Account SID" if self.account_sid.nil?
        raise ArgumentError, "Twilio requires a token to send outgoing text messages. Set SMSXY::Adaptor::Twilio.token to your token" if self.token.nil?
        params =
        {
          :from => self.phone,
          :to   => to,
          :body => message
        }
        self.client.account.sms.messages.create(params)
      end

      def self.account_sid=(val)
        @account_sid = val
      end
      
      def self.token=(val)
        @token       = val
      end

      def self.account_sid
        @account_sid
      end

      def self.token
        @token
      end

      private

      def self.client
        @account ||= Twilio::REST::Client.new(self.account_sid, self.token)
      end
    
    end
  end
end