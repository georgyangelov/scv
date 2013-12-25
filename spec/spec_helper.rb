require 'scv'

RSpec.configure do |config|
  config.expect_with :rspec do |expect_config|
    expect_config.syntax = :expect
  end
end