Releasing
=========

 1. Verify everything works with `make check build`.
 2. Bump version in [`version.rb`](https://github.com/segmentio/analytics-ruby/blob/master/lib/segment/analytics/version.rb).
 3. Update [`History.md`](https://github.com/segmentio/analytics-ruby/blob/master/History.md).
 4. Commit and tag `git commit -am "Release {version}" && git tag -a {version} -m "Version {version}"`.
 5. Upload to Github with `git push -u origin master && git push --tags`.
The tagged commit will be pushed to RubyGems via Travis.
