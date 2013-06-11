# SMSXY

SMSXY is a microframework for receiving, replying to, and sending text messages. It makes it dramatically easier to write SMS apps. 

Unfortunately, I don't have have time to document this right now. Here's a code sample:

```ruby
require 'smsxy'

SMSXY.pretend = true

SMSXY::Router.draw do
    
  match ['hi', 'yo'] do
    reply "hello"
  end
  
  match 'whoami' do
    reply self.sms.phone
  end
  
  match :phone do
    reply "#{params[0]} is a phone."
  end
  
  match :email do
    reply "#{params[0]} is an email."
  end
  
  help do
    reply "Say hi! Or, type in a phone/email"
  end
    
end

SMSXY.receive('Body' => '+15555555555', 'From' => "+12345678901")
SMSXY.receive('Body' => 'jarred@jarredsumner.com', 'From' => "+12345678901")
SMSXY.receive('Body' => 'whoami', 'From' => "+12345678901")
SMSXY.receive('Body' => 'hi', 'From' => "+12345678901")
SMSXY.receive("Body" => "what can I do!", 'From' => "+12345678901")
puts SMSXY.messages.collect(&:message)

```

Here's an example on how to configure it:
```ruby
SMSXY.logger = Logger.new("#{Rails.root}/log/smsxy.log")
SMSXY::Adaptor.phone = ENV['TWILIO_PHONE']
SMSXY::Adaptor::TwilioAdaptor.account_sid = ENV["TWILIO_ACCOUNT_SID"]
SMSXY::Adaptor::TwilioAdaptor.token = ENV['TWILIO_TOKEN']
SMSXY.start_logging!
SMSXY.pretend = !Rails.env.test?
```

It supports Twilio right now, but is flexible enough to support others later.


## Installation

Add this line to your application's Gemfile:

    gem 'smsxy', :git => "git://github.com/Jarred-Sumner/smsxy.git", :require => "smsxy"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install smsxy
