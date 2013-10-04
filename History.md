0.5.0 / 2013-10-03
==================

* Removing global Analytics alias in favor of adding it to our config

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