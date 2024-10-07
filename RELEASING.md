We automatically push tags to Rubygems via CI.

Release
============

- Make sure you're on the latest `master`
- Bump the version in [`version.rb`](lib/segment/analytics/version.rb)
- Update [`History.md`](History.md)
- Commit these changes. `git commit -am "Release x.y.z."`
- Tag the release. `git tag -a -m "Version x.y.z" x.y.z`
- `git push -u origin master && git push --tags
- Run the publish action on Github

