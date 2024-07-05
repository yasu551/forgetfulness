class SubscriptionsController < ApplicationController
  def create
    subscription = Subscription.new(subscription_params)
    if subscription.save
      Notification.create(
        user: current_user,
        title: "Great!",
        body: "You've got subscribe to the push manager."
      )
      render json: { status: :ok }
    else
      render json: { status: :unprocessable_entity }
    end
  end

  def destroy
    subscription = Subscription.find_by(endpoint: subscription_params[:endpoint], user_id: subscription_params[:user_id]&.to_i)
    subscription.destroy!
  end

  private

  def subscription_params
    params.require(:subscription).permit(%i[endpoint auth_key p256dh_key user_id])
  end
end
