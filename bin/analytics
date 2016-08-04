#!/usr/bin/env ruby

require 'segment/analytics'
require 'rubygems'
require 'commander/import'
require 'time'
require 'json'

program :name, 'simulator.rb'
program :version, '0.0.1'
program :description, 'scripting simulator'

# use an env var for write key, instead of a flag
Analytics = Segment::Analytics.new({
  write_key: ENV['SEGMENT_WRITE_KEY'],
  on_error: Proc.new { |status, msg| print msg }
})

def toObject(str)
  return JSON.parse(str)
end

# high level
# analytics <method> [options]
# SEGMENT_WRITE_KEY=<write_key> ./analytics.rb <method> [options]
# SEGMENT_WRITE_KEY=<write_key> ./analytics.rb track --event testing --user 1234 --anonymous 567 --properties '{"hello": "goodbye"}' --context '{"slow":"poke"}'



# track
command :track do |c|
  c.description = 'track a user event'
  c.option '--user <id>', String, 'the user id to send the event as'
  c.option '--event <event>', String, 'the event name to send with the event'
  c.option '--anonymous <id>', String, 'the anonymous user id to send the event as'
  c.option '--properties <data>', 'the event properties to send (JSON-encoded)'
  c.option '--context <data>', 'additional context for the event (JSON-encoded)'

  c.action do |args, options|
    Analytics.track({
      user_id: options.user,
      event: options.event,
      anonymous_id: options.anonymous,
      properties: toObject(options.properties),
      context: toObject(options.context)
       })
    Analytics.flush
  end

end

# page
command :page do |c|
  c.description = 'track a page view'
  c.option '--user <id>', String, 'the user id to send the event as'
  c.option '--anonymous <id>', String, 'the anonymous user id to send the event as'
  c.option '--name <name>', String, 'the page name'
  c.option '--properties <data>', 'the event properties to send (JSON-encoded)'
  c.option '--context <data>', 'additional context for the event (JSON-encoded)'
  c.option '--category <category>', 'the category of the page'
  c.action do |args, options|
    Analytics.page({
      user_id: options.user,
      anonymous_id: options.anonymous,
      name: options.name,
      properties: toObject(options.properties),
      context: toObject(options.context),
      category: options.category
       })
    Analytics.flush
  end

end

# identify
command :identify do |c|
  c.description = 'identify a user'
  c.option '--user <id>', String, 'the user id to send the event as'
  c.option '--anonymous <id>', String, 'the anonymous user id to send the event as'
  c.option '--traits <data>', String, 'the user traits to send (JSON-encoded)'
  c.option '--context <data>', 'additional context for the event (JSON-encoded)'
  c.action do |args, options|
    Analytics.identify({
      user_id: options.user,
      anonymous_id: options.anonymous,
      traits: toObject(options.traits),
      context: toObject(options.context)
       })
    Analytics.flush
  end

end

# screen
command :screen do |c|
  c.description = 'track a screen view'
  c.option '--user <id>', String, 'the user id to send the event as'
  c.option '--anonymous <id>', String, 'the anonymous user id to send the event as'
  c.option '--name <name>', String, 'the screen name'
  c.option '--properties <data>', String, 'the event properties to send (JSON-encoded)'
  c.option '--context <data>', 'additional context for the event (JSON-encoded)'
  c.action do |args, options|
    Analytics.identify({
      user_id: options.user,
      anonymous_id: options.anonymous,
      name: option.name,
      traits: toObject(options.traits),
      properties: toObject(option.properties),
      context: toObject(options.context)
       })
    Analytics.flush
  end

end


# group
command :group do |c|
  c.description = 'identify a group of users'
  c.option '--user <id>', String, 'the user id to send the event as'
  c.option '--anonymous <id>', String, 'the anonymous user id to send the event as'
  c.option '--group <id>', String, 'the group id to associate this user with'
  c.option '--traits <data>', String, 'attributes about the group (JSON-encoded)'
  c.option '--context <data>', 'additional context for the event (JSON-encoded)'
  c.action do |args, options|
    Analytics.group({
      user_id: options.user,
      anonymous_id: options.anonymous,
      group_id: options.group,
      traits: toObject(options.traits),
      context: toObject(options.context)
       })
    Analytics.flush
  end

end

# alias
command :alias do |c|
  c.description = 'remap a user to a new id'
  c.option '--user <id>', String, 'the user id to send the event as'
  c.option '--previous <id>', String, 'the previous user id (to add the alias for)'
  c.action do |args, options|
    Analytics.alias({
      user_id: options.user,
      previous_id: options.previous
       })
    Analytics.flush
  end

end

