require 'mailjet'
Mailjet.configure do |config|
config.api_key = ENV['MAIL_API']
config.secret_key = ENV['MAIL_SECRET']
config.api_version = "v3.1"
end