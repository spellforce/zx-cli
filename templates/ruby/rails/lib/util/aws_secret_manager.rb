require 'aws-sdk-secretsmanager'

asm_client = Aws::SecretsManager::Client.new

secret_mapping = ENV['AWS_SECRET'].dup
secret_mapping = secret_mapping.gsub!(/\s+/, "").split(",")

# fetch secret information from aws secret manager, then store in ENV
secret_mapping.each do |secret|
  temp = secret.split("=")
  env_key = temp[0]
  secret_id = temp[1]
  env_key_str = env_key.to_s
  # unless Rails.env.development?
  response = asm_client.get_secret_value(secret_id: secret_id)

  if response.secret_string
    secret = response.secret_string
  else
    secret = Base64.decode64(response.secret_binary)
  end
  secret = ActiveSupport::JSON.decode(secret)
  if env_key_str == 'ENV'
    secret.each do |key, val|
      ENV[key.to_s] = val
    end
  else
    secret.each do |key, val|
      ENV["#{env_key_str}_#{key.to_s.upcase}"] = val
      p "#{env_key_str}_#{key.to_s.upcase}=#{val}"
    end
  end
  # end
end
