require 'securerandom'
module SMSXY
  class SMS
    attr_accessor :message, :full_message, :phone
    attr_reader :unique_id

    def initialize
      @unique_id = SecureRandom.hex(6)
    end
  end
end