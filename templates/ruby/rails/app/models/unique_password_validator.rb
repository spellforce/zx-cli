# models/unique_password_validator.rb
require 'bcrypt'
class UniquePasswordValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    record.password_histories.each do |ph|
      bcrypt = ::BCrypt::Password.new(ph.encrypted_password)
      hashed_value = ::BCrypt::Engine.hash_secret([value, Devise.pepper].join, bcrypt.salt)
      record.errors[attribute] << "has been used previously." and return if hashed_value == ph.encrypted_password
    end
  end
end