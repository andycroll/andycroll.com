---
title: "Compress Your Images"
description: "Using a set-and-forget GitHub Action"
layout: article
category: ruby
date: 2024-06-05 01:00
image:
  base: "2024/compress-your-images-using-github-actions"
  alt: "Sheep squeezed into a small pen"
  credit: "Davide Ragusa"
  source: "https://unsplash.com/photos/herd-of-sheep-in-grayscale-photo-cDwZ40Lj9eo"
---

Images typically form a large proportion of the total download size of pages in your Rails application.

Given that many image formats (both lossy and lossless) can be compressed further without any visual regression, it makes sense to optimize them up until that point.

## Create a Github Action

Add the following to your repository:

```yml
# .github/workflows/compress-images.yml

name: Optimize Images

on:
  pull_request:
    paths:
      - "**.jpg"
      - "**.jpeg"
      - "**.png"
      - "**.webp"

jobs:
  build:
    if: github.event.pull_request.head.repo.full_name == github.repository

    name: calibreapp/image-actions
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Compress Images
        uses: calibreapp/image-actions@main
        with:
          githubToken: ${% raw %}{{{% endraw %} secrets.GITHUB_TOKEN }}
```

## Why?

Smaller images mean faster downloads for your users. This is a great set-and-forget tool from the lovely folks at [Calibre](https://calibreapp.com). You might be surprised how much bandwidth you save.

This works for any repository, not just Rails applications. I use it on the [Jekyll](https://jekyllrb.com) site you’re currently reading.

## Why not?

Maybe you dislike free performance improvements for your users?

I kid.

A bit.

There’s still some human intervention needed to make a good initial format decision for your imagery. You‘ll want to use the correct file type for the image e.g. JPGs or WEBP offer better compression for photographic images.

The best solution to make your image downloads less of a burden for your users is to resize—reducing the dimensions of the files—and serve multiple sizes using [responsive imagery](https://developer.mozilla.org/en-US/docs/Learn/HTML/Multimedia_and_embedding/Responsive_images) with a `<picture>` element, a `srcset` attribute on an `<img>` tag, or a combination of both.

Note that this is only for image assets included in your application or site. Any user-uploaded images will need resizing and compressing using an alternative technique. I’ve had a great experience with [imgproxy](https://imgproxy.net) at CoverageBook.
