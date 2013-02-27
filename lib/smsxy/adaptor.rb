require 'smsxy/adaptor/twilio_adaptor'

# Eventually, it'd be good to support other services
module SMSXY
  class Adaptor

    def self.text(message, to)
      raise ArgumentError, "Phone number cannot be blank" if to.nil? || to.length == 0
      raise ArgumentError, "Message cannot be blank" if message.nil? || message.length == 0
      raise ArgumentError, "Sending outgoing text messages requires an incoming phone number" if adaptor.phone.nil? || adaptor.phone.length == 0
      adaptor.text(message, to)
    end

    def self.adaptor
      @adaptor ||= SMSXY::Adaptor::Twilio
    end

    def self.phone=(val)
      @phone = val
    end

    def self.phone
      @phone
    end

  end
end