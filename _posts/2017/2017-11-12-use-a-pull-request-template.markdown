---
title: 'Use a pull request template'
description: 'It helps you answer what, why & how.'
layout: article
category: ruby
image:
  base: '2017/use-a-pull-request-template'
  alt: 'Man pulling rope'
  credit: 'Stijn Swinnen'
  source: 'https://unsplash.com/photos/Q8FHN3qSq2w'
---

If you're submitting work for review, pull requests are a great way to group related changes and discuss approaches and improvements. The audience for a pull request can be your immediate co-workers, other interested parties or even your future self.

It should describe the ‘what’, ‘why’ and high-level ‘how’ of the changes in your branch. It is important the description is detailed and sets the context for the changes you have made .

Github offers the ability to define pull request templates. See [GitHub’s documentation on pull request templates](https://help.github.com/articles/creating-a-pull-request-template-for-your-repository/).

## Instead of…

…writing one line. Or listing a bunch of commits. Or making it up each time.

## Use…

…a template.

### Add `.github/PULL_REQUEST_TEMPLATE.md`

```md
#### What does this PR do?

[TrelloCard/Issue/Story](LINK_TO_STORY)

##### Why are we doing this? Any context or related work?

#### A good place to start?

#### Manual testing steps?

#### Screenshots

---

#### Migrations

#### Deployment instructions

#### New ENV variables
```

Each time anyone opens a pull request the description box is pre-filled with the markdown from this file.


## But why?

Anything you do over and over works more efficiently if you have a repeatable process to systemise it. Having a template is a solid way to help you write useful pull request descriptions, it helps you pause and answer the questions posed by the default headings in the template.

It may well be that some pull requests don’t need all of the sections, but you can always just delete the irrelevant parts. Using this template _will_ mean you’ve thought about the information in each section, even it was only to say “nah, don’t need it”.

Adding a pull request template is often one of my first additions when I join a project.


## Why not?

This feels like a no-brainer to me, it doesn't stop you deleting the pre-filled description and writing your own. I've never regretted it.
