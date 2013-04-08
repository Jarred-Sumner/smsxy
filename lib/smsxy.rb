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

  def self.log(message, options)
    tag = ''
    if options[:tag].class == SMSXY::SMS
      tag = "[#{options[:tag].unique_id}] [#{options[:tag].phone}]"
    else
      tag = "#{options[:tag]}"
    end
    self.logger.info(tag + message) if @@logging == true
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger = Logger.new("log/smsxy.log")
  end



end
