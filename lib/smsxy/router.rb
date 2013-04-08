require 'smsxy/router/namespace'
module SMSXY
  class Router
    def self.draw(&routes)
      @routes = routes
    end

    def self.receive(sms, to = nil)
      SMSXY.log("Incoming SMS: \"#{sms.full_message}\"", :tag => sms)
      root.receive(sms)
    end

    def self.root
      namespace = SMSXY::Router::Namespace.new
      namespace.instance_eval(&@routes)
      namespace 
    end

  end
end