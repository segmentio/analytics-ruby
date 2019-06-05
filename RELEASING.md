We automatically push tags to Rubygems via CI.

Pre-releases
============

- Make sure you're on the latest `master`
- Bump the version in [`version.rb`](lib/segment/analytics/version.rb)
- Update [`History.md`](History.md)
- Commit these changes. `git commit -am "Release x.y.z.pre"`
- Tag the pre-release. `git tag -a -m "Version x.y.z.pre" x.y.z.pre`
- `git push -u origin master && git push --tags`. The tagged commit will be
  pushed to RubyGems via Travis


Promoting pre-releases
======================

- Find the tag for the pre-release you want to promote. Use `git tag --list
  '*.pre'` to list all pre-release tags
- Checkout that tag. `git checkout tags/x.y.z.pre`
- Update the version in [`version.rb`](lib/segment/analytics/version.rb) to not
  include the `.pre` suffix
- Commit these changes. `git commit -am "Promote x.y.z.pre"`
- Tag the release. `git tag -a -m "Version x.y.z" x.y.z`
- `git push -u origin master && git push --tags`. The tagged commit will be
  pushed to RubyGems via Travis
- On `master`, add an entry to [`History.md`](History.md) under `x.y.z` that
  says 'Promoted pre-release to stable'
