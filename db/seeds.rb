user = User.find_or_create_by!(name: 'yasu') do |u|
  u.password = 'password'
end
