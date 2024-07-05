class User < ApplicationRecord
  has_secure_password

  has_many :notifications, dependent: :destroy
  has_many :subscriptions, dependent: :destroy
  has_many :tasks, dependent: :destroy
end
