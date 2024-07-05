user = User.find_or_create_by!(name: 'yasu') do |u|
  u.password = 'password'
end

user.subscriptions.delete_all
user.notifications.delete_all
user.tasks.delete_all

start_time = "2024-07-05 18:00:00".to_datetime
task_contents = %w[
  外に出る前に財布をポケットに入れる
  電車から出る前にお土産を持つ
  外に出る前に、ケーキとプレゼントを持つ
  外に出る前に、弁当箱をカバンに入れる
  退社前に家の鍵を持っていることを確認する
]

task_contents.each_with_index do |content, i|
  user.tasks.create!(
    content: content,
    scheduled_at: start_time + i.hours
  )
end
