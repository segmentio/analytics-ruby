# analytics-ruby e2e-cli

A small CLI tool for end-to-end testing of the [analytics-ruby](https://github.com/segmentio/analytics-ruby) SDK. It accepts a JSON description of event sequences and SDK configuration, sends those events through the real SDK, and reports the outcome as JSON on stdout.

## Requirements

- Ruby 2.6+
- No extra gems beyond `analytics-ruby` itself (the script adds `../lib` to `$LOAD_PATH` automatically)

## Usage

```bash
ruby main.rb --input '<json>'
```

### Example

```bash
ruby main.rb --input '{
  "writeKey": "YOUR_WRITE_KEY",
  "apiHost": "https://api.segment.io",
  "sequences": [
    {
      "delayMs": 0,
      "events": [
        {"type": "track", "event": "Test Event", "userId": "user-1", "properties": {"foo": "bar"}},
        {"type": "identify", "userId": "user-1", "traits": {"name": "Alice"}},
        {"type": "page", "userId": "user-1", "name": "Home", "category": "Nav"},
        {"type": "screen", "userId": "user-1", "name": "Main"},
        {"type": "alias", "userId": "new-id", "previousId": "user-1"},
        {"type": "group", "userId": "user-1", "groupId": "group-1", "traits": {"plan": "pro"}}
      ]
    }
  ],
  "config": {
    "flushAt": 15,
    "flushInterval": 1000,
    "maxRetries": 3,
    "timeout": 10
  }
}'
```

## Input JSON format

| Field | Type | Description |
|-------|------|-------------|
| `writeKey` | string | Segment write key |
| `apiHost` | string | Full API base URL (e.g. `https://api.segment.io`) |
| `sequences` | array | List of event sequences (processed in order) |
| `sequences[].delayMs` | number | Milliseconds to sleep before processing this sequence |
| `sequences[].events` | array | List of events to send |
| `config.flushAt` | number | Max events per batch (`batch_size`) |
| `config.flushInterval` | number | Flush interval in ms (informational, not applied) |
| `config.maxRetries` | number | Number of HTTP retries on failure |
| `config.timeout` | number | HTTP timeout in seconds (informational, not applied) |

### Supported event types

All event keys use camelCase in the JSON input; they are converted to snake_case before being passed to the SDK.

| type | Required keys | Optional keys |
|------|--------------|---------------|
| `track` | `userId` or `anonymousId`, `event` | `properties`, `context`, `integrations`, `messageId`, `timestamp` |
| `identify` | `userId` or `anonymousId` | `traits`, `context`, `integrations`, `messageId`, `timestamp` |
| `page` | `userId` or `anonymousId` | `name`, `category`, `properties`, `context`, `integrations`, `messageId`, `timestamp` |
| `screen` | `userId` or `anonymousId` | `name`, `properties`, `context`, `integrations`, `messageId`, `timestamp` |
| `alias` | `userId`, `previousId` | `context`, `integrations`, `messageId`, `timestamp` |
| `group` | `userId` or `anonymousId`, `groupId` | `traits`, `context`, `integrations`, `messageId`, `timestamp` |

## Output JSON format

On success (exit code 0):

```json
{"success": true, "sentBatches": 1}
```

On failure (exit code 1):

```json
{"success": false, "sentBatches": 1, "error": "status=400 error=Invalid write key"}
```

Debug information (event enqueue/flush progress) is written to **stderr** and does not affect the stdout JSON output.

## Running the full E2E test suite

```bash
./run-e2e.sh
```

This requires the [sdk-e2e-tests](https://github.com/segmentio/sdk-e2e-tests) repository to be checked out alongside the SDK root (i.e. at `../../sdk-e2e-tests` relative to this directory). Override with:

```bash
E2E_TESTS_DIR=/path/to/sdk-e2e-tests ./run-e2e.sh
```

Extra arguments are forwarded to `run-tests.sh`:

```bash
./run-e2e.sh --suite basic
```

## How it works

1. The script adds `../lib` to `$LOAD_PATH` so no gem installation is needed.
2. `apiHost` is parsed with `URI` to extract hostname, port, and SSL flag, which are passed to the SDK's `Transport` layer.
3. Each event's camelCase keys are converted to snake_case symbols before calling the corresponding SDK method (`track`, `identify`, etc.).
4. `timestamp` values are parsed from ISO8601 strings into `Time` objects.
5. After all events are enqueued, `client.flush` blocks until all batches have been sent.
6. Any errors reported via the `on_error` callback cause a failure result.
