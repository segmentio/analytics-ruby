Pre-Releases
============

 1. Verify everything works with `make check build`.
 2. Bump version in
    [`version.rb`](https://github.com/segmentio/analytics-ruby/blob/master/lib/segment/analytics/version.rb).
    This version string should not include a `.pre` suffix, as the same commit will
    be re-tagged when the pre-release is promoted.
 3. Update
    [`History.md`](https://github.com/segmentio/analytics-ruby/blob/master/History.md).
 4. Commit and tag the pre-release. `git commit -am "Release {version.pre}" &&
    git tag -a {version.pre} -m "Version {version.pre}"`.
 5. Upload to Github with `git push -u origin master && git push --tags`.  The
    tagged commit will be pushed to RubyGems via Travis.

Promoting Pre-releases
======================

- Find the tag for the pre-release you want to promote. `git tag --list
  '*.pre'`
- Re-tag this commit without the `.pre` prefix. `git tag -a -m "Version
  {version}" {version} {pre_version}`
- Upload to Github with `git push --tags`. The tagged commit will be pushed to
  RubyGems via Travis.
