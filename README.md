analytics-ruby
==============

[![Build Status](https://travis-ci.org/segmentio/analytics-ruby.png?branch=master)](https://travis-ci.org/segmentio/analytics-ruby)

analytics-ruby is a ruby client for [Segment](https://segment.com)

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

## Testing

You can use the `stub` option to Segment::Analytics.new to cause all requests to be stubbed, making it easier to test with this library.

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


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/segmentio/analytics-ruby/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

