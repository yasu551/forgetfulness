class Notification < ApplicationRecord
  belongs_to :user
  has_many :subscriptions, through: :user

  validates :title, presence: true
  validates :body, presence: true

  after_create :push

  private

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
end
