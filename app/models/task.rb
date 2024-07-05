class Task < ApplicationRecord
  belongs_to :user

  validates :content, presence: true
  validates :scheduled_at, presence: true

  scope :default_order, -> { order(:scheduled_at) }
end
