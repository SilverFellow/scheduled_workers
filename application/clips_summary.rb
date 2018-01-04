# frozen_string_literal: true

require 'econfig'
require 'aws-sdk-sqs'

require_relative '../init.rb'

extend Econfig::Shortcut
Econfig.env = ENV['WORKER_ENV'] || 'development'
Econfig.root = File.expand_path('..', File.dirname(__FILE__))

ENV['AWS_ACCESS_KEY_ID'] = config.AWS_ACCESS_KEY_ID
ENV['AWS_SECRET_ACCESS_KEY'] = config.AWS_SECRET_ACCESS_KEY
ENV['AWS_REGION'] = config.AWS_REGION

queue = LoyalFan::Messaging::Queue.new(config.SCHEDULED_QUEUE_URL)
channels = []

queue.poll do |channel_json|
  channel = LoyalFan::ChannelRepresenter
            .new(OpenStruct.new)
            .from_json(channel_json)
  channels << channel
end

# Notify user about popular clips of all time.

puts 'Popular clips of all time:\n\n'
channels.each do |channel|
  puts "#{channel.name}: "
  channel.clips.sort_by! { |i| i.view }
  channel.clips.reverse!
  puts "View: #{channel.clips[0].view}, title: #{channel.clips[0].title}, #{channel.clips[0].url}"
  puts '========================='
end
