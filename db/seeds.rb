User.destroy_all
Admin.destroy_all

puts 'Creating admin...'

Admin.create!(email: 'admin@example.com', password: 'AdminPassword', password_confirmation: 'AdminPassword')

puts 'Creating user...'

User.create!(email: 'aubry.prieur@copas.coop', password: 'UserPassword', password_confirmation: 'UserPassword')

puts 'This is the end'
