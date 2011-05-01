class SourceUser < ActiveRecord::Base
  include SecondDatabase
  set_table_name :users

  def self.migrate
    all.each do |source_user|
      # TODO: Merge changes of snowyu for better user migration
      next if User.find_by_mail(source_user.mail)
      next if User.find_by_login(source_user.login)
      next if source_user.type == "AnonymousUser"
      
      u = User.create(source_user.attributes)
      u.login = source_user.login
      u.admin = source_user.admin
      u.hashed_password = source_user.hashed_password
      u.save()
    end
  end
end
