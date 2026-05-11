#!/usr/bin/env ruby
# frozen_string_literal: true

# e2e-cli/main.rb
#
# CLI tool for end-to-end testing of the analytics-ruby SDK.
#
# Usage:
#   ruby main.rb --input '<json>'
#
# The --input JSON describes event sequences and SDK configuration.
# Results are written as JSON to stdout; debug info goes to stderr.
# Exits 0 on success, 1 on failure.

$LOAD_PATH.unshift File.join(__dir__, '..', 'lib')

require 'segment/analytics'
require 'json'
require 'time'
require 'uri'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

# Convert a single camelCase key string to snake_case symbol.
def to_snake_case(key)
  key
    .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
    .gsub(/([a-z\d])([A-Z])/, '\1_\2')
    .downcase
    .to_sym
end

# Known camelCase -> snake_case mappings for event attributes.
CAMEL_TO_SNAKE = {
  'userId'      => :user_id,
  'anonymousId' => :anonymous_id,
  'messageId'   => :message_id,
  'groupId'     => :group_id,
  'previousId'  => :previous_id,
  'type'        => :type,
  'event'       => :event,
  'name'        => :name,
  'category'    => :category,
  'traits'      => :traits,
  'properties'  => :properties,
  'context'     => :context,
  'integrations'=> :integrations,
  'timestamp'   => :timestamp,
}.freeze

# Convert a camelCase event hash (string keys) to a snake_case attrs hash
# (symbol keys) suitable for passing to the Ruby SDK.
def convert_event_attrs(event)
  attrs = {}
  event.each do |k, v|
    snake = CAMEL_TO_SNAKE[k] || to_snake_case(k)
    # Parse ISO8601 timestamp strings into Time objects
    if snake == :timestamp && v.is_a?(String)
      v = Time.parse(v) rescue v
    end
    attrs[snake] = v
  end
  attrs
end

# Parse the --input flag from ARGV.
def parse_input_arg(argv)
  idx = argv.index('--input')
  if idx.nil? || argv[idx + 1].nil?
    warn 'Error: --input <json> argument is required'
    exit 1
  end
  argv[idx + 1]
end

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

raw_input = parse_input_arg(ARGV)

begin
  input = JSON.parse(raw_input)
rescue JSON::ParserError => e
  warn "Error: failed to parse --input JSON: #{e.message}"
  exit 1
end

write_key   = input['writeKey']
api_host    = input['apiHost']
sequences   = input['sequences'] || []
config      = input['config'] || {}

flush_at      = config['flushAt']
flush_interval = config['flushInterval']  # ms — not directly supported, ignored
max_retries   = config['maxRetries']
timeout       = config['timeout']         # seconds — not directly supported, ignored

# Parse apiHost URL into host / port / ssl components expected by Transport.
host = nil
port = nil
ssl  = nil

if api_host && !api_host.empty?
  begin
    uri  = URI.parse(api_host)
    host = uri.host
    ssl  = (uri.scheme == 'https')
    port = uri.port || (ssl ? 443 : 80)
  rescue URI::InvalidURIError => e
    warn "Warning: could not parse apiHost '#{api_host}': #{e.message}. Using default host."
  end
end

# Collect errors reported by on_error callback.
errors = []
on_error = proc do |status, error|
  msg = "status=#{status} error=#{error}"
  warn "[analytics-ruby] on_error called: #{msg}"
  errors << msg
end

# Build client options.
client_opts = {
  write_key: write_key,
  on_error:  on_error,
}
client_opts[:host]       = host      if host
client_opts[:port]       = port      if port
client_opts[:ssl]        = ssl       unless ssl.nil?
client_opts[:batch_size] = flush_at  if flush_at
client_opts[:retries]    = max_retries if max_retries

# Work around the Transport initializer using `||=` for :ssl, which causes
# `ssl: false` to be overridden by the default `SSL = true`. Patch before
# the client (and thus Transport) is instantiated.
unless ssl.nil?
  # Work around the `options[:ssl] ||= SSL` line in Transport#initialize which
  # replaces a falsy `ssl: false` with the default `SSL = true`.
  # Strategy: strip :ssl from options before super so ||= has nothing to
  # override, then force-set use_ssl= on the Net::HTTP object after super runs.
  override_ssl = ssl
  Segment::Analytics::Transport.prepend(Module.new do
    define_method(:initialize) do |options = {}|
      super(options.reject { |k, _| k == :ssl })
      @http.use_ssl = override_ssl
    end
  end)
end

warn "[analytics-ruby] Initializing client (host=#{host || 'default'}, batch_size=#{flush_at || 'default'})"

begin
  client = Segment::Analytics::Client.new(client_opts)
rescue ArgumentError => e
  result = { 'success' => false, 'sentBatches' => 0, 'error' => e.message }
  puts JSON.generate(result)
  exit 1
end

sent_events = 0

# Process each sequence.
sequences.each_with_index do |seq, seq_idx|
  delay_ms = seq['delayMs'] || 0
  if delay_ms > 0
    warn "[analytics-ruby] Sequence #{seq_idx}: sleeping #{delay_ms}ms"
    sleep(delay_ms / 1000.0)
  end

  events = seq['events'] || []
  events.each do |event|
    type  = event['type']
    attrs = convert_event_attrs(event.reject { |k, _| k == 'type' })

    warn "[analytics-ruby] Enqueuing #{type} event: #{attrs.inspect}"

    case type
    when 'track'
      client.track(attrs)
    when 'identify'
      client.identify(attrs)
    when 'page'
      client.page(attrs)
    when 'screen'
      client.screen(attrs)
    when 'alias'
      client.alias(attrs)
    when 'group'
      client.group(attrs)
    else
      warn "[analytics-ruby] Warning: unknown event type '#{type}', skipping"
      next
    end

    sent_events += 1
  end
end

warn "[analytics-ruby] Flushing #{sent_events} enqueued event(s)..."
client.flush
warn '[analytics-ruby] Flush complete.'

if errors.empty?
  result = { 'success' => true, 'sentBatches' => 1 }
  puts JSON.generate(result)
  exit 0
else
  result = { 'success' => false, 'sentBatches' => 1, 'error' => errors.first }
  puts JSON.generate(result)
  exit 1
end
