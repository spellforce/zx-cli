#encoding: utf-8
class UsersRole < ApplicationRecord
  belongs_to :user
  belongs_to :role
end
