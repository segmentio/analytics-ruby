analytics-ruby
==============

analytics-ruby is a ruby client for [Segment.io](https://segment.io).

### Ruby Analytics Made Simple

[Segment.io](https://segment.io) is the cleanest, simplest API for recording analytics data.

Setting up a new analytics solution can be a real pain. The APIs from each analytics provider are slightly different in odd ways, code gets messy, and developers waste a bunch of time fiddling with long-abandoned client libraries. We want to save you that pain and give you an clean, efficient, extensible analytics setup.

[Segment.io](https://segment.io) wraps all those APIs in one beautiful, simple API. Then we route your analytics data wherever you want, whether it's Google Analytics, Mixpanel, Customer io, Chartbeat, or any of our other integrations. After you set up Segment.io you can swap or add analytics providers at any time with a single click. You won't need to touch code or push to production. You'll save valuable development time so that you can focus on what really matters: your product.

```ruby
gem "analytics-ruby"; require "analytics"
Analytics.init "secrettoken"
analytics.track(user_id: "ilya@segment.io", 
             event: "Played a Song")
```

and turn on integrations with just one click at [Segment.io](https://segment.io).

![](http://i.imgur.com/YnBWI.png)

More on integrations [here](#integrations).

### High Performance

This client uses an internal queue to efficiently send your events in aggregate, rather than making an HTTP
request every time. It is also non-blocking and asynchronous, meaning it makes batch requests on another thread. This allows your code to call `analytics.track` or `analytics.identify` without incurring a large performance cost on the calling thread. Because of this, analytics-ruby is safe to use in your high scale web server controllers, or in your backend services
without worrying that it will make too many HTTP requests and slow down the program. You also no longer need to use a message queue to have analytics.

[Feedback is very welcome!](mailto:friends@segment.io)

## Quick-start

If you haven't yet, get an API secret [here](https://segment.io).

#### Install
```bash
gem install analytics-ruby
```

#### Initialize the client

You can create separate analytics-ruby clients, but the easiest and recommended way is to just use the module:

```ruby
gem 'analytics-ruby'; require 'analytics'
Analytics.init 'secrettoken'
```

#### Identify a User

Whenever a user triggers an event, you’ll want to track it.

```ruby
Analytics.identify(session_id: 'ajsk2jdj29fj298', 
        user_id: 'ilya@segment.io', 
        traits: { subscription_plan: "Free",
                friends: 30 })
```

**session_id** (String) is a unique id associated with an anonymous user **before** they are logged in. Even if the user
is logged in, you can still send us the **session_id** or you can just use `nil`.

**user_id** (String) is the user's id **after** they are logged in. It's the same id as which you would recognize a signed-in user in your system. Note: you must provide either a `session_id` or a `user_id`.

**traits** (Hash) is a Hash with keys like `subscriptionPlan` or `favoriteGenre`. This argument is optional, but highly recommended—you’ll find these properties extremely useful later.

**timestamp** (Time, optional) is a Time object representing when the identify took place. If the event just happened, don't bother adding a time and we'll use the server's time. If you are importing data from the past, make sure you provide this argument.

#### Track an Action

Whenever a user triggers an event on your site, you’ll want to track it so that you can analyze and segment by those events later.

```ruby
Analytics.track(session_id: 'skdj2jj2dj2j3i5', 
                          user_id: 'calvin@segment.io', 
                          event: 'Made a Comment', 
                          properties: {
                             thatAided: "No-One",
                             comment:   "its 4AM!" })
```


**session_id** (String) is a unique id associated with an anonymous user **before** they are logged in. Even if the user
is logged in, you can still send us the **session_id** or you can just use `nil`.

**user_id** (String) is the user's id **after** they are logged in. It's the same id as which you would recognize a signed-in user in your system. Note: you must provide either a `session_id` or a `user_id`.

**event** (String) describes what this user just did. It's a human readable description like "Played a Song", "Printed a Report" or "Updated Status".

**properties** (Hash) is a hash with items that describe the event in more detail. This argument is optional, but highly recommended—you’ll find these properties extremely useful later.

**timestamp** (Time, optional) is a Time object representing when the identify took place. If the event just happened, leave it `nil` and we'll use the server's time. If you are importing data from the past, make sure you provide this argument.

That's it, just two functions!

## Integrations

There are two main modes of analytics integration: client-side and server-side. You can use just one, or both.

#### Client-side vs. Server-side

* **Client-side analytics** - (via [analytics.js](https://github.com/segmentio/analytics.js)) works by loading in other integrations
in the browser.

* **Server-side analytics** - (via [analytics-node](https://github.com/segmentio/analytics-node), [analytics-python](https://github.com/segmentio/analytics-python) and other server-side libraries) works
by sending the analytics request to [Segment.io](https://segment.io). Our servers then route the message to your desired integrations.

Some analytics services have REST APIs while others only support client-side integrations.

You can learn which integrations are supported server-side vs. client-side on your [project's integrations]((https://segment.io) page.

## Advanced

#### Batching Behavior

By default, the client will flush:

1. the first time it gets a message
1. whenever messages are queued and there is no outstanding request

The queue consumer runs in a different thread for each client to avoid blocking your webserver process. However, the consumer makes only a single outbound request at a time to avoid saturating your server's resources. If multiple messages are in the queue, they are sent together in a batch call.

#### Importing Historical Data

You can import historical data by adding the timestamp argument (of type
Time) to the identify / track calls. Note: if you are tracking
things that are happening now, we prefer that you leave the timestamp out and
let our servers timestamp your requests.

#### License

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

Copyright (c) 2012 Segment.io Inc. <friends@segment.io>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.