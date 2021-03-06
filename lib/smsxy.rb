require 'logger'
require 'phones'

require "smsxy/version"
require 'smsxy/router'
require 'smsxy/sms'
require 'smsxy/adaptor'

module SMSXY
  @@logging = false
  def self.text(message, to, original_sms = nil)
    sms = SMS.new
    sms.full_message = message
    sms.message      = message
    sms.phone        = to
    response = SMSXY::Adaptor.adaptor.text(sms, original_sms)
    self.messages.push(sms) if self.pretend?
    return response
  end

  def self.receive(params)
    sms = SMSXY::Adaptor::TwilioAdaptor.receive(params)
    SMSXY::Router.receive(sms)
  end

  def self.start_logging!
    @@logging = true 
  end

  def self.messages
    @messages ||= []
  end

  def self.log(message, options)
    tag = ''
    if options[:tag].class == SMSXY::SMS
      tag = "[#{options[:tag].unique_id}] [#{options[:tag].phone}] "
    else
      tag = "[#{options[:tag]}] "
    end
    self.logger.info(tag + message) if @@logging == true
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger = Logger.new("log/smsxy.log")
  end

  def self.pretend=(val)
    @pretend = val
  end

  def self.pretend?
    @pretend == true
  end

  def self.real?
    @pretend == false
  end



end
