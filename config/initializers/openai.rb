OpenAI.configure do |config|
  config.access_token = Rails.application.credentials.openai.api_key
  config.log_errors = true
end
