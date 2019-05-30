# Crystal: Twitter
require 'open-uri'
require 'twitter'

# Handles the @traumaheartstxt account functionality.
module Bot::Twitter
  extend Discordrb::EventContainer

  # ID of the #traumaheartstxt channel
  IMAGE_CHANNEL = 583469550260191282
  # Regex to match a mention
  MENTION_REGEX = /<@!?\d+>/

  twitter_config = YAML.load_file "#{ENV['DATA_PATH']}/twitter_app_config.yml"
  twitter_client = Twitter::REST::Client.new(twitter_config.each_with_object({}) { |(k,v),memo| memo[k.to_sym] = v })
  queued_posts = Hash.new { |h, k| h[k] = Array.new }

  # Queue an image when posted to image channel
  message in: IMAGE_CHANNEL do |event|
    # Skip unless an image is attached
    next unless event.message.attachments.size == 1 &&
                event.message.attachments[0].image?
    # Skip unless at least one user is mentioned
    next unless event.content =~ MENTION_REGEX

    mentioned_users = event.content.scan(MENTION_REGEX).map { |m| m.scan(/\d/).join.to_i }
    queued_posts[event.message.id] = mentioned_users

    # React to message with 👍 approval button
    event.message.react '👍'
  end

  # Handle user approval and post to Twitter if approved
  reaction_add emoji: '👍' do |event|
    # Skip unless reaction is on a queued post message
    next if (approval_users = queued_posts[event.message.id]).empty?

    # Delete event user from array of approved users, as user has given their approval
    approval_users.delete(event.user.id)

    # Skip unless approved user array is empty
    next unless approval_users.empty?

    download = open(event.message.attachments[0].url)
    file_path = "#{ENV['DATA_PATH']}/upload.#{File.extname(download.base_uri.to_s)}"
    IO.copy_stream(download, file_path)
    file = File.open file_path

    # Upload image to Twitter and delete local copy
    twitter_client.update_with_media('', file)
    File.delete file_path

    # Delete message from queued post tracker
    queued_posts.delete(event.message.id)
  end
end