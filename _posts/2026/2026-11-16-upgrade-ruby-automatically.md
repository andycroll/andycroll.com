---
title: "Upgrade Ruby Automatically"
description: "A set-and-forget GitHub Action that gets you onto new Ruby versions the week they ship"
layout: article
category: ruby
date: 2026-11-16 02:00
image:
  base: "2026/upgrade-ruby-automatically"
  alt: "A robotic arm placing a red gem onto a conveyor belt"
---

New Ruby releases bring security fixes, bug fixes and performance improvements. The sooner you're on them, the sooner you get those, and the smaller each upgrade is.

But nobody pings you when a new Ruby ships, and "bump Ruby" rarely makes it onto anyone's plan. So I have GitHub do it.

## Create a GitHub Action

The full workflow is on [railstemplates.org](https://railstemplates.org/update-ruby). Once a week it checks for the newest Ruby that `ruby/setup-ruby` can install, bumps `.ruby-version` and `Gemfile.lock`, and opens a pull request.

The step that makes it quick is the last one. It gets CI running on the bot's pull request and lets it merge itself:

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

Change `ci.yml` to your test workflow's file name.

Then switch on **Allow GitHub Actions to create and approve pull requests** (Settings → Actions → General) and **Allow auto-merge** (Settings → General), and require your CI check on `main`. Without a required check, auto-merge has nothing to wait for.

## Why?

Small upgrades are easy upgrades. A patch release that lands the week it ships is a one-line change your tests have already checked. Six months of drift is a job someone has to plan.

Since June, GitHub holds CI on pull requests opened by `github-actions[bot]` until someone approves it. Without the approve step, my Ruby 4.0.9 pull request sat blocked for two weeks, which rather defeats the point. With it, the default `GITHUB_TOKEN` is enough. No personal access token to create, scope or remember to renew.

It runs on the site you're reading.

## Why not?

Auto-merge is only as good as your tests. For this blog, "the site builds and the links work" is plenty. For an app, make sure the required check is your real test suite.

The workflow approves its own CI run, skipping a check GitHub added on purpose. That's fine here because the workflow wrote the change itself. Don't copy the approve step into anything that builds its changes from outside input.

It proposes minor versions too, not just patches. New Ruby versions traditionally ship on Christmas Day, so expect a pull request soon after. If you'd rather review those yourself, filter the version check to your current `MAJOR.MINOR`.

A merge made with `GITHUB_TOKEN` doesn't trigger `push` workflows on `main`. If you deploy on push, the new Ruby waits for your next deploy.
