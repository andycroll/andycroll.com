---
title: "Upgrade Ruby Automatically"
description: "A weekly GitHub Action that bumps your Ruby version, gets CI to run, and merges itself"
layout: article
category: ruby
date: 2026-11-16 02:00
image:
  base: "2026/upgrade-ruby-automatically"
  alt: "A robotic arm placing a red gem onto a conveyor belt"
---

Ruby patch releases drift. You don't get pinged when one ships, and "go bump Ruby" never makes it onto anyone's plan.

So I have a GitHub Action do it. Once a week it checks for a newer Ruby, opens a pull request bumping `.ruby-version` and `Gemfile.lock`, and merges it once CI passes. The full workflow is on [railstemplates.org](https://railstemplates.org/update-ruby).

## The interesting step

Getting CI to run on a pull request a bot opened has always been the awkward part. This is the step that sorts it:

{% raw %}
```yaml
permissions:
  actions: write # to approve the CI run
  contents: write
  pull-requests: write

# ...

      - name: Open pull request
        id: pr
        uses: peter-evans/create-pull-request@v8
        # ...

      - name: Approve CI and enable auto-merge
        if: steps.pr.outputs.pull-request-operation == 'created' || steps.pr.outputs.pull-request-operation == 'updated'
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          HEAD_SHA: ${{ steps.pr.outputs.pull-request-head-sha }}
          PR_NUMBER: ${{ steps.pr.outputs.pull-request-number }}
        run: |
          for _ in $(seq 1 30); do
            run_id=$(gh run list --workflow ci.yml --event pull_request --commit "$HEAD_SHA" \
              --json databaseId --jq '.[0].databaseId // empty')
            [ -n "$run_id" ] && break
            sleep 10
          done
          if [ "$(gh run view "$run_id" --json conclusion --jq .conclusion)" = "action_required" ]; then
            gh api -X POST "repos/$GITHUB_REPOSITORY/actions/runs/$run_id/approve"
          fi
          gh pr merge "$PR_NUMBER" --auto --merge
```
{% endraw %}

`ci.yml` is the file name a new Rails app generates. Change it if yours is different. The loop is there because the CI run turns up a few seconds after the pull request does.

You'll also need **Allow GitHub Actions to create and approve pull requests** (Settings → Actions → General), **Allow auto-merge** (Settings → General), and a rule on `main` that requires your CI check. Auto-merge waits for required checks, so without one it merges straight away.

## How I got here

The first version of this, on one of my apps, used a fine-grained personal access token. Back then a pull request opened with the default `GITHUB_TOKEN` didn't trigger any workflows at all. No CI meant nothing for auto-merge to wait for.

The token was the fiddly bit. The scheduled job failed three days running with `Input required and not supplied: token`, because I'd never set the secret. Then it failed a fourth day with `fatal: could not read Username for 'https://github.com'`, because the token didn't have the repository in its access list.

I filed that away as a blog post idea on 2 June. Nine days later GitHub [changed the rules](https://github.blog/changelog/2026-06-11-bot-created-pull-requests-can-run-workflows-if-approved/). Pull requests opened by `github-actions[bot]` now get their CI runs, but each one waits for someone with write access to approve it.

The version I put on this site didn't know about that. It kicked off CI separately with `gh workflow run`, and that run passed, but it never counted as the pull request's required check. The Ruby 4.0.9 pull request sat there, blocked, for two weeks before I noticed.

Approving a run needs `actions: write`, which `GITHUB_TOKEN` can have. So the workflow approves its own run, and there's no personal access token to create, scope or remember to renew.

## Why not?

GitHub holds these runs on purpose, so that code a bot generated can't run workflows with access to your secrets until a human has looked. I'm happy skipping that here because my own workflow wrote the change: one line in `.ruby-version` and the lockfile. I wouldn't copy the approve step into anything that builds its changes from outside input.

Auto-merge is only as good as your tests. For this blog, "the site builds and the links work" is plenty. For an app, make sure the required check is your real test suite.

It proposes the newest stable Ruby, minor and major versions included, not just patches. Worth knowing before you let it merge on its own.

A merge made with `GITHUB_TOKEN` doesn't trigger `push` workflows on `main` either. This site deploys on a daily schedule, so the bump goes out overnight. If you deploy on push, it'll wait for your next deploy.
