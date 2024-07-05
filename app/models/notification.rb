class Notification < ApplicationRecord
  belongs_to :user
  has_many :subscriptions, through: :user

  validates :title, presence: true
  validates :body, presence: true
  validates :run_at, presence: true

  before_validation :set_run_at, if: -> { run_at.blank? }
  after_create do
    NotificationJob.set(wait_until: run_at).perform_later(notification_id: id)
  end

  def push
    subscriptions.default_order.each do |subscription|
      response =
        WebPush.payload_send(
          message: to_json,
          endpoint: subscription.endpoint,
          p256dh: subscription.p256dh_key,
          auth: subscription.auth_key,
          vapid: {
            private_key: Rails.application.credentials.webpush.private_key,
            public_key: Rails.application.credentials.webpush.public_key
          }
        )
      logger.info "WebPush Info: #{response.inspect}"
    rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
      logger.warn "WebPush Warn: #{response.inspect}"
    rescue WebPush::ResponseError => e
      logger.error "WebPush Error: #{e.message}"
    end
  end

  private

  def set_run_at
    self.run_at = Time.current
  end
end
