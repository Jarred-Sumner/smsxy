require 'logger'

require "smsxy/version"
require 'smsxy/router'
require 'smsxy/sms'
require 'smsxy/adaptor'

module SMSXY
  @@logging = false
  def self.text(message, to)
    SMSXY::Adaptor.adaptor.text(message, to)
  end

  def self.receive(params)
    sms = SMSXY::Adaptor::TwilioAdaptor.receive(params)
    SMSXY::Router.receive(sms)
  end

  def self.start_logging!
    @@logging = true 
  end

  def self.log(message)
    self.logger.info(message) if @@logging == true
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger = Logger.new("log/smsxy.log")
  end



end
