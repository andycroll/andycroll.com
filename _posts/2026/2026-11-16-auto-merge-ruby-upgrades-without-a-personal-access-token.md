---
title: "Auto-merge Ruby Upgrades without a Personal Access Token"
description: "A weekly GitHub Actions workflow that bumps .ruby-version, approves its own CI run, and merges itself."
layout: article
category: ruby
date: 2026-11-16 02:00
image:
  base: "2026/auto-merge-ruby-upgrades-without-a-personal-access-token"
  alt: "A robotic arm placing a red gem onto a conveyor belt"
---

Ruby patch releases ship quietly. Nobody pings you, and "bump Ruby" never makes it onto anyone's plan. In my apps, Dependabot keeps the gems moving but `.ruby-version` stays wherever I left it.

A scheduled workflow can open the upgrade pull request for you, and auto-merge can land it once CI passes. The hard part has always been getting CI to run on a pull request a bot opened.

## Instead of…

…a personal access token, so the bot's pull request triggers CI:

{% raw %}
```yaml
- uses: actions/checkout@v7
  with:
    token: ${{ secrets.AUTO_UPDATE_RUBY_TOKEN }}
```
{% endraw %}

This was my first version, back in June. The scheduled job then failed every day for four days. First with `Input required and not supplied: token`, because I'd never set the secret. Then with `fatal: could not read Username for 'https://github.com'`, because the fine-grained token didn't have the repository in its access list.

## Use…

…the default `GITHUB_TOKEN`, then approve the pull request's CI run and turn on auto-merge:

{% raw %}
```yaml
name: Update Ruby

on:
  schedule:
    - cron: "0 6 * * 1" # Mondays 06:00 UTC
  workflow_dispatch:

permissions:
  actions: write # to approve the CI run
  contents: write
  pull-requests: write

jobs:
  update-ruby:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7

      - name: Find the newest Ruby setup-ruby can install
        id: detect
        run: |
          current=$(tr -d '[:space:]' < .ruby-version)
          latest=$(curl -fsSL https://raw.githubusercontent.com/ruby/setup-ruby/v1/ruby-builder-versions.json \
            | jq -r '.ruby[]' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)
          echo "current=$current" >> "$GITHUB_OUTPUT"
          echo "latest=$latest" >> "$GITHUB_OUTPUT"
          newest=$(printf '%s\n%s\n' "$current" "$latest" | sort -V | tail -1)
          if [ "$newest" = "$latest" ] && [ "$latest" != "$current" ]; then
            echo "update=true" >> "$GITHUB_OUTPUT"
          fi

      - name: Bump .ruby-version
        if: steps.detect.outputs.update == 'true'
        env:
          LATEST: ${{ steps.detect.outputs.latest }}
        run: echo "$LATEST" > .ruby-version

      - uses: ruby/setup-ruby@v1
        if: steps.detect.outputs.update == 'true'

      - name: Update Gemfile.lock
        if: steps.detect.outputs.update == 'true'
        run: |
          bundle config set --local frozen false
          bundle install

      - name: Open pull request
        id: pr
        if: steps.detect.outputs.update == 'true'
        uses: peter-evans/create-pull-request@v8
        with:
          branch: automation/update-ruby
          add-paths: |
            .ruby-version
            Gemfile.lock
          commit-message: "Bump Ruby to ${{ steps.detect.outputs.latest }}"
          title: "Bump Ruby ${{ steps.detect.outputs.current }} → ${{ steps.detect.outputs.latest }}"

      - name: Approve CI and enable auto-merge
        if: steps.pr.outputs.pull-request-operation == 'created' || steps.pr.outputs.pull-request-operation == 'updated'
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          HEAD_SHA: ${{ steps.pr.outputs.pull-request-head-sha }}
          PR_NUMBER: ${{ steps.pr.outputs.pull-request-number }}
        run: |
          run_id=""
          for _ in $(seq 1 30); do
            run_id=$(gh run list --workflow ci.yml --event pull_request --commit "$HEAD_SHA" \
              --json databaseId --jq '.[0].databaseId // empty')
            [ -n "$run_id" ] && break
            sleep 10
          done
          if [ -z "$run_id" ]; then
            echo "::error::No pull_request CI run appeared for $HEAD_SHA."
            exit 1
          fi
          if [ "$(gh run view "$run_id" --json conclusion --jq .conclusion)" = "action_required" ]; then
            gh api -X POST "repos/$GITHUB_REPOSITORY/actions/runs/$run_id/approve"
          fi
          gh pr merge "$PR_NUMBER" --auto --merge
```
{% endraw %}

Change `ci.yml` to the file name of your test workflow. The [full version that runs this site](https://github.com/andycroll/andycroll.com/blob/main/.github/workflows/update-ruby.yml) also builds the site on the new Ruby before opening the pull request.

## Why?

For years, a pull request opened with `GITHUB_TOKEN` didn't trigger any workflows at all. GitHub [changed that in June 2026](https://github.blog/changelog/2026-06-11-bot-created-pull-requests-can-run-workflows-if-approved/). Now the pull request gets its `pull_request` runs, but they wait in an "approval required" state until someone with write access approves them.

Approving a run needs `actions: write`, which `GITHUB_TOKEN` can have, so the workflow approves its own run. It worked on this site's repository without any extra secret.

Before I added this, my workflow started CI with `gh workflow run ci.yml --ref automation/update-ruby` instead. That run passed, but GitHub didn't attach it to the pull request, so the required `build` check never turned up. The Ruby 4.0.9 pull request sat blocked for two weeks.

The loop is there because the CI run appears a few seconds after the pull request does.

Three repository settings need to be on, or the workflow fails partway:

- **Settings → Actions → General → Allow GitHub Actions to create and approve pull requests**, so it can open the pull request.
- **Settings → General → Allow auto-merge**, so `gh pr merge --auto` works.
- A branch rule on `main` that requires your CI check. Auto-merge waits for required checks. Without one, it has nothing to wait for.

## Why not?

GitHub holds these runs as a safety measure, so generated code doesn't automatically run workflows that might have access to your secrets. Approving them is only reasonable when your own workflow wrote the change. Here that change is one line in `.ruby-version` plus the lockfile. Don't copy the approval step into a workflow that builds its changes from outside input.

Auto-merge trusts your tests. Building this site is enough for a blog. For an app, the required check needs to be your real test suite.

This workflow takes the newest stable Ruby, minor and major versions included. To stay on patch releases, filter `latest` to versions that start with your current `MAJOR.MINOR.`.

A merge made with `GITHUB_TOKEN` doesn't trigger `push` workflows on `main`. If you deploy on push, a merged Ruby bump waits for your next deploy. This site deploys on a daily schedule, so it goes out overnight.

If you'd rather the CI run started without an approval step, GitHub suggests a GitHub App installation token or a personal access token. If you use a personal access token and it isn't working, check it with:

```bash
curl -s -o /dev/null -w '%{http_code}\n' \
  -H "Authorization: Bearer $TOKEN" https://api.github.com/repos/OWNER/REPO
```

A `200` means the token can see the repository. A `401` means the token itself is wrong or expired. A `404` means the token works but can't see the repository, usually because the repository isn't in its access list.
