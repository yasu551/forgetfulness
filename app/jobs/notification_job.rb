class NotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_id:)
    notification = Notification.find_by(id: notification_id)
    return if notification.blank?

    notification.push
  end
end
