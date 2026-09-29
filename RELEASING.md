Releasing
=========

Publishing happens in CI through RubyGems Trusted Publishing (OIDC). No API key is
stored anywhere — `deploy.yml` exchanges the GitHub OIDC token for a push-scoped
RubyGems key that expires in 15 minutes.

1. Bump `VERSION` in [`lib/segment/analytics/version.rb`](lib/segment/analytics/version.rb).
2. In [`History.md`](History.md), change the `Unreleased` heading to `X.Y.Z / YYYY-MM-DD`.
3. `git commit -am "Release X.Y.Z."`
4. Open a PR and merge it to `master`.
5. Tag the merged commit — no `v` prefix:

   ```
   git tag X.Y.Z && git push origin X.Y.Z
   ```

6. Create a **GitHub Release** for that tag. `deploy.yml` triggers on
   `release: published`; pushing the tag by itself does not start it.
7. Approve the `production` environment when the publish job requests review.

The workflow verifies the tag against `version.rb`, builds the gem, and pushes it.

> **Note:** the trusted publisher on rubygems.org is registered against repository
> `segmentio/analytics-ruby`, workflow `deploy.yml` and environment `production`. All
> three must match the workflow or the OIDC exchange fails.
