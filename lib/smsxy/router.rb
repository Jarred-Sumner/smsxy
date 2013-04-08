require 'smsxy/router/namespace'
module SMSXY
  class Router

    def self.draw(&routes)
      @root_namespace = SMSXY::Router::Namespace.new
      @root_namespace.instance_eval(&routes)
      @root_namespace
    end

    def self.receive(sms)
      SMSXY.log("Incoming SMS: \"#{sms.full_message}\"", :tag => sms)
      @root_namespace.receive(sms)
    end

    def self.root
      @root_namespace
    end

  end
end