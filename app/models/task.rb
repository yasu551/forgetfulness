class Task < ApplicationRecord
  belongs_to :user

  validates :content, presence: true
  validates :scheduled_at, presence: true

  scope :default_order, -> { order(:scheduled_at) }

  after_create :create_notification!
  after_create do
    UpdateTaskItemsJob.set(wait_until: 3.seconds.ago).perform_later(task_id: :id)
  end

  def update_items!
    client = OpenAI::Client.new
    messages = [
      { role: "system", content: "assistantは日本語のことをよくわかっている日本語言語学者です。assistantは 以下のようなカンマで区切った文字列だけを出力します。\n 財布, お土産, ケーキ, プレゼント" },
      { role: "assistant", content: "了解しました！" },
      { role: "user", content: "以下の文章の中から、物だけをピックアップしてカンマで区切った文字列を出力して。\n #{content}" }
    ]
    response = client.chat(
      parameters: {
        model: "gpt-4o",
        messages:
      }
    )
    p response.dig("choices", 0, "message", "content")
    update!(items: response.dig("choices", 0, "message", "content").strip)
  end

  private

  def create_notification!
    user.notifications.create!(
      title: 'タスクをする時間の５分前です',
      body: content,
      run_at: scheduled_at.in_time_zone - 5.minutes
    )
  end
end
