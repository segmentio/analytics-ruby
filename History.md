2.0.3 / 2014-06-04
==================
* fix: undefined method `is_requesting?' for nil:NilClass when calling flush (#51)

2.0.2 / 2014-05-30
==================
* fix: formatting ios dates
* fix: respond_to? implementation
* add: able to stub requests by setting STUB env var

2.0.1 / 2014-05-15
==================
* add: namespace under Segment::Analytics
* add: can create multiple instances with creator method (rather than
    having a singleton)
* add: logging with Logger instance or Rails.logger if available
* add: able to stub requests so they just log and don't hit the server
* fix: worker continues running across forked processes
* fix: removed usage of ActiveSupport methods since its not a dependency
* fix: sending data that matches segment's new api spec

(there is no v2.0.0)

1.1.0 / 2014-04-17
==================
* adding .initialized? by [@lumberj](https://github.com/lumberj)

1.0.0 / 2014-03-12
==================
* removing faraday dependency

0.6.0 / 2014-02-19
==================
* adding .group(), .page(), and .screen() calls
* relaxing faraday dependency, fixes #31

0.5.4 / 2013-12-31
==================
* Add `requestId` fields to all requests for tracing.

0.5.3 / 2013-12-31
==================
* Allow the consumer thread to shut down so it won't remain live in hot deploy scenarios. This fixes the jruby memory leak by [@nirvdrum](https://github.com/nirvdrum)

0.5.2 / 2013-12-02
==================
* adding `sleep` backoff between connection retries

0.5.1 / 2013-11-22
==================
* adding retries for connection hangups

0.5.0 / 2013-10-03
==================
* Removing global Analytics constant in favor of adding it to our config. NOTE: If you are upgrading from a previous version and want to continue using the `Analytics` namespace, you'll have to add `Analytics = AnalyticsRuby` to your config. Otherwise you WILL NOT be sending analytics data. See the [setup docs for more info](https://segment.io/libraries/ruby)

0.4.0 / 2013-08-30
==================
* Adding support and tests for 1.8.7

0.3.4 / 2013-08-26
==================
* Pass `Time` values as iso8601 timestamp strings

0.3.3 / 2013-08-02
==================
* Allow init/track/identify/alias to accept strings as keys. by [@shipstar](https://github.com/shipstar)

0.3.2 / 2013-05-28
==================
* Adding faraday timeout by [@yanchenyun](https://github.com/yangchenyun)

0.3.1 / 2013-04-29
==================
* Adding check for properties to be a Hash

0.3.0 / 2013-04-05
==================
* Adding alias call

0.2.0 / 2013-03-21
==================
* Adding flush method

0.1.4 / 2013-03-19
==================
* Adding ClassMethods for more extensibility by [arronmabrey](https://github.com/arronmabrey)

0.1.3 / 2013-03-19
==================
* Fixing user_id.to_s semantics, reported by [arronmabrey](https://github.com/arronmabrey)
* Reduced faraday requirements by [arronmabrey](https://github.com/arronmabrey)

0.1.2 / 2013-03-11
==================
* Fixing thrown exception on non-initialized tracks thanks to [sbellity](https://github.com/sbellity)

0.1.1 / 2013-02-11
==================
* Updating dependencies
* Adding actual support for MultiJson 1.0

0.1.0 / 2013-01-22
==================
* Updated docs to point at segment.io

0.0.5 / 2013-01-21
==================
* Renaming of all the files for proper bundling usage

0.0.4 / 2013-01-17
==================
* Updated readme and install instruction courtesy of [@zeke](https://github.com/zeke)
* Removed typhoeus and reverted to default adapter
* Removing session_id in favor of a single user_id

0.0.3 / 2013-01-16
==================
* Rakefile and renaming courtesy of [@kiennt](https://github.com/kiennt)
* Updated tests with mocks
