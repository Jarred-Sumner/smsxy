require "smsxy/version"
require 'smsxy/router'
require 'smsxy/sms'
require 'smsxy/adaptor'

module SMSXY

  def self.text(message, to)
    SMSXY::Adaptor.adaptor.text(message, to)
  end

end
