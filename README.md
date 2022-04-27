analytics-ruby
==============

analytics-ruby is a ruby client for [Segment](https://segment.com)

<div align="center">
  <img src="https://user-images.githubusercontent.com/16131737/53616965-fcdeb680-3b99-11e9-934c-53917ac1e563.png"/>
  <p><b><i>You can't fix what you can't measure</i></b></p>
</div>

Analytics helps you measure your users, product, and business. It unlocks insights into your app's funnel, core business metrics, and whether you have product-market fit.

## How to get started
1. **Collect analytics data** from your app(s).
    - The top 200 Segment companies collect data from 5+ source types (web, mobile, server, CRM, etc.).
2. **Send the data to analytics tools** (for example, Google Analytics, Amplitude, Mixpanel).
    - Over 250+ Segment companies send data to eight categories of destinations such as analytics tools, warehouses, email marketing and remarketing systems, session recording, and more.
3. **Explore your data** by creating metrics (for example, new signups, retention cohorts, and revenue generation).
    - The best Segment companies use retention cohorts to measure product market fit. Netflix has 70% paid retention after 12 months, 30% after 7 years.

[Segment](https://segment.com) collects analytics data and allows you to send it to more than 250 apps (such as Google Analytics, Mixpanel, Optimizely, Facebook Ads, Slack, Sentry) just by flipping a switch. You only need one Segment code snippet, and you can turn integrations on and off at will, with no additional code. [Sign up with Segment today](https://app.segment.com/signup).

### Why?
1. **Power all your analytics apps with the same data**. Instead of writing code to integrate all of your tools individually, send data to Segment, once.

2. **Install tracking for the last time**. We're the last integration you'll ever need to write. You only need to instrument Segment once. Reduce all of your tracking code and advertising tags into a single set of API calls.

3. **Send data from anywhere**. Send Segment data from any device, and we'll transform and send it on to any tool.

4. **Query your data in SQL**. Slice, dice, and analyze your data in detail with Segment SQL. We'll transform and load your customer behavioral data directly from your apps into Amazon Redshift, Google BigQuery, or Postgres. Save weeks of engineering time by not having to invent your own data warehouse and ETL pipeline.

    For example, you can capture data on any app:
    ```js
    analytics.track('Order Completed', { price: 99.84 })
    ```
    Then, query the resulting data in SQL:
    ```sql
    select * from app.order_completed
    order by price desc
    ```

### 🚀 Startup Program
<div align="center">
  <a href="https://segment.com/startups"><img src="https://user-images.githubusercontent.com/16131737/53128952-08d3d400-351b-11e9-9730-7da35adda781.png" /></a>
</div>
If you are part of a new startup  (&lt;$5M raised, &lt;2 years since founding), we just launched a new startup program for you. You can get a Segment Team plan  (up to <b>$25,000 value</b> in Segment credits) for free up to 2 years — <a href="https://segment.com/startups/">apply here</a>!

## Install

Into Gemfile from rubygems.org:
```ruby
gem 'analytics-ruby'
```

Into environment gems from rubygems.org:
```
gem install 'analytics-ruby'
```

## Usage

Create an instance of the Analytics object:
```ruby
analytics = Segment::Analytics.new(write_key: 'YOUR_WRITE_KEY')
```

Identify the user for the people section, see more [here](https://segment.com/docs/libraries/ruby/#identify).
```ruby
analytics.identify(user_id: 42,
                   traits: {
                     email: 'name@example.com',
                     first_name: 'Foo',
                     last_name: 'Bar'
                   })
```

Alias an user, see more [here](https://segment.com/docs/libraries/ruby/#alias).
```ruby
analytics.alias(user_id: 41)
```

Track a user event, see more [here](https://segment.com/docs/libraries/ruby/#track).
```ruby
analytics.track(user_id: 42, event: 'Created Account')
```

There are a few calls available, please check the documentation section.

## Documentation

Documentation is available at [segment.com/docs/sources/server/ruby](https://segment.com/docs/sources/server/ruby/)

### Test Queue

You can use the `test: true` option to Segment::Analytics.new to cause all requests to be saved to a test queue until manually reset. All events will process as specified by the configuration, and they will also be stored in a separate queue for inspection during testing.

A test queue can be used as follows:

```ruby
client = Segment::Analytics.new(test: true)

client.test_queue # => #<Segment::Analytics::TestQueue:0x00007f88d454e9a8 @messages={}>

client.track(user_id: 'foo', event: 'bar')

client.test_queue.all
# [
#     {
#            :context => {
#             :library => {
#                    :name => "analytics-ruby",
#                 :version => "2.2.8.pre"
#             }
#         },
#          :messageId => "e9754cc0-1c5e-47e4-832a-203589d279e4",
#          :timestamp => "2021-02-19T13:32:39.547+01:00",
#             :userId => "foo",
#               :type => "track",
#              :event => "bar",
#         :properties => {}
#     }
# ]

client.test_queue.track
# [
#     {
#            :context => {
#             :library => {
#                    :name => "analytics-ruby",
#                 :version => "2.2.8.pre"
#             }
#         },
#          :messageId => "e9754cc0-1c5e-47e4-832a-203589d279e4",
#          :timestamp => "2021-02-19T13:32:39.547+01:00",
#             :userId => "foo",
#               :type => "track",
#              :event => "bar",
#         :properties => {}
#     }
# ]

# Other available methods
client.test_queue.alias # => []
client.test_queue.group # => []
client.test_queue.identify # => []
client.test_queue.page # => []
client.test_queue.screen # => []

client.test_queue.reset!

client.test_queue.all # => []
```

Note: It is recommended to call `reset!` before each test to ensure your test queue is empty. For example, in rspec you may have the following:

```ruby
RSpec.configure do |config|
  config.before do
    Analytics.test_queue.reset!
  end
end
```

And also to stub actions use `stub: true` along with `test: true` so that it doesn't send any real calls during specs.
## License

```
WWWWWW||WWWWWW
 W W W||W W W
      ||
    ( OO )__________
     /  |           \
    /o o|    MIT     \
    \___/||_||__||_|| *
         || ||  || ||
        _||_|| _||_||
       (__|__|(__|__|
```

(The MIT License)

Copyright (c) 2013 Segment Inc. <friends@segment.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
