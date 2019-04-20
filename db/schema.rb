# This file contains the schema for the database.
# Under most circumstances, you shouldn't need to run this file directly.
require 'sequel'

module Schema
  Sequel.sqlite(ENV['DB_PATH']) do |db|
    db.create_table?(:hug_users) do
      primary_key :id
      Integer :given, :default=>0
      Integer :received, :default=>0
    end
  end
end