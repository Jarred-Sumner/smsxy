require 'hash'
# Utility class for letting you access the values of a Hash by the first matching regex
# This is significantly slower than a Hash, so only use this if you need it for this use case.

# For example

# Using HashRegex:
# hash_regex = { /\s/ => "bagel" }.to_hash_regex
# hash_regex[' ']
# => "bagel"

# Using Hash:
# hash = { /\s/ => "bagel" }
# hash[' ']
# => nil


# In a Hash, there would be no key named " ", but since this is a HashRegex
# It'll match the regex, /\s/ to " " and return the appropriate value
class HashRegex < Hash
  def [](key)
    if key.class == String
      self.each do |k, v|
        return v if k.class == Regexp && k =~ key
      end
      super
    else
      super
    end
  end
end