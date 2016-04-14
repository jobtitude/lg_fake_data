require 'date'

module Utils
  def self.random_hour
    "#{rand(9..21).to_s}:#{rand(0..59).to_s}"
  end
end
