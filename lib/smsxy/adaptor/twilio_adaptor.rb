require 'twilio-ruby'
module SMSXY
  module Adaptor
    class TwilioAdaptor
    
      def self.text(message, to, sms = nil, pretend = false)
        raise ArgumentError, "Phone number cannot be blank" if to.nil? || to.length == 0
        raise ArgumentError, "Message cannot be blank" if message.nil? || message.length == 0
        raise ArgumentError, "Sending outgoing text messages requires an incoming phone number" if adaptor.phone.nil? || adaptor.phone.length == 0
        raise ArgumentError, "Twilio requires an Account SID to send outgoing text messages. Set SMSXY::Adaptor::Twilio.account_sid to your Account SID" if self.account_sid.nil?
        raise ArgumentError, "Twilio requires a token to send outgoing text messages. Set SMSXY::Adaptor::Twilio.token to your token" if self.token.nil?
        message_parts = message.split(/(.{160})/)
        if sms.nil?
          SMSXY.log("Outgoing SMS: \"#{message}\"", :tag => to)
        else
          SMSXY.log("Outgoing SMS: \"#{message}\"", :tag => sms)
        end
        message_parts.each do |message_part|
          params =
          {
            :from => self.phone,
            :to   => to,
            :body => message_part
          }
          self.client.account.sms.messages.create(params) unless pretend
        end
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

      def self.adaptor
        self
      end

      def self.phone
        SMSXY::Adaptor.phone
      end

      def self.receive(params)
        sms               = SMSXY::SMS.new
        sms.message       = params['Body']
        sms.full_message  = sms.message
        sms.phone         = params['From'].to_phone.to_s
        sms
      end

      private

      def self.client
        @account ||= Twilio::REST::Client.new(self.account_sid, self.token)
      end
    
    end
  end
end