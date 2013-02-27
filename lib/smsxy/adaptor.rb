require 'smsxy/adaptor/twilio_adaptor'

# Eventually, it'd be good to support other services
module SMSXY
  module Adaptor

    def self.adaptor
      @@adaptor ||= SMSXY::Adaptor::TwilioAdaptor
    end

    def self.phone=(val)
      @@phone = val
    end

    def self.phone
      @@phone
    end

  end
end