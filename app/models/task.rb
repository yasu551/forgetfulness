class Task < ApplicationRecord
  belongs_to :user

  validates :content, presence: true
  validates :scheduled_at, presence: true

  scope :default_order, -> { order(:scheduled_at) }

  after_create :create_notification!

  private

  def create_notification!
    user.notifications.create!(
      title: 'タスクをする時間の５分前です',
      body: content,
      run_at: scheduled_at.in_time_zone - 5.minutes
    )
  end
end
