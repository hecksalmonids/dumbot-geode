# Model: HugUser


# A user giving or receiving hugs. Has a primary key of user ID and two fields for hugs given and received.
class Bot::Models::HugUser < Sequel::Model
  unrestrict_primary_key
end