require 'hash_regex'
class Hash
  def to_hash_regex
    HashRegex.new.merge(self)
  end
end