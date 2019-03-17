  require 'bundler/setup'
  Bundler.require

  if development?
    ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
  end

  class Video < ActiveRecord::Base
    belongs_to :user
  end

  class User < ActiveRecord::Base
    has_secure_password
    has_many :videos
  end