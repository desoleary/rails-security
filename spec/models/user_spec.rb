require 'rails_helper'

RSpec.describe User, type: :model do
  let!(:user) { create(:user, username: 'user1', password: 'user') }
  let!(:admin) { create(:admin, username: 'admin1', password: 'admin') }

  context 'sql injection' do
    it 'does not escape dangerous params' do

      username = "admin' OR 1); -- "
      password = ''


      users = User.where("username = '#{username}' AND password = '#{password}'")
      expect(users.to_sql).to eql("SELECT `users`.* FROM `users` WHERE (username = 'admin' OR 1); -- ' AND password = '')")
      expect(users.count).to eql(2)
    end

    it 'escapes dangerous params' do

      username = "admin' OR 1); -- "
      password = ''


      users = User.where('username = ? AND password = ?', username, password)
      expect(users.to_sql).to eql("SELECT `users`.* FROM `users` WHERE (username = 'admin\\' OR 1); -- ' AND password = '')")
      expect(users.count).to eql(0)
    end
  end
end


# User.create(
#     real_name: 'A. Administrator',
#     email: 'admin@example.net',
#     username: 'admin',
#     password: 'admin',
#     admin: true
# )
#
# User.create(
#     real_name: 'U. User',
#     email: 'user@example.net',
#     username: 'user',
#     password: 'user',
#     admin: false
# )
