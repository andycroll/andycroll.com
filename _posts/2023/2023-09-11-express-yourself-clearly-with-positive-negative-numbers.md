---
title: "Express yourself clearly with positive? and negative? for numbers"
description: "Syntactical sugar to avoid comparison operators"
layout: article
category: ruby
image:
  base: "2023/express-yourself-clearly-with-positive-negative-numbers"
  alt: "The architecture of Birmingham, UK"
  credit: "Mike Hindle"
  source: "https://unsplash.com/photos/ow87XYsaY6Q"

---

Ruby, in contrast to other languages, often provides multiple ways to accomplish simple programming tasks. In pursuit of developer happiness, the Standard Library offers the opportunity to make your code appear more like English.

In this case we’ll look at comparing numbers, I’ve previously discussed my preference for a similar comparator, `zero?`, in a [previous article](/ruby/use-zero-for-integer-float-comparison).


## Instead of…

…using comparison operators:

```ruby
if number > 0
  # do a thing
end

if number < 0
  # do a thing
end
```

## Use…

…ruby’s convenience methods on `Numeric`, and its subclasses, to express yourself more clearly:

```ruby
if number.positive?
  # do a thing
end

if number.negative?
  # do a thing
end
```


## Why?

I find the “more English” version to be clearer and easier to reason about when I return to it in the future. I still, after a twenty year programming career, require a moment of concentration while I unpack the orientation of the angle bracket and how it relates to the numbers and variables.

This approach to convenience methods also, for me, is one of the most delightful things about Ruby. It’s one of the reasons it provokes smiles when I write it.


## Why not?

Some folks find this style to be too different from other languages and claim that they’ve never struggled to remember whether `<` is “less than” or “greater than’.

You might get push back for “performance” reasons.

```ruby
require "benchmark/ips"

Benchmark.ips do |x|
  x.report("1 > 0") { 1 > 0 } #=> true
  x.report("0 > 0") { 0 > 0 } #=> false
  x.report("-1 > 0") { -1 > 0 } #=> false
  x.report("1.positive?") { 1.positive? } #=> true
  x.report("0.positive?") { 0.positive? } #=> false
  x.report("-1.positive?") { 0.positive? } #=> false

  x.report("1.0 > 0") { 1 > 0 } #=> true
  x.report("0.0 > 0") { 0 > 0 } #=> false
  x.report("-1.0 > 0") { -1 > 0 } #=> false
  x.report("1.0.positive?") { 1.positive? } #=> true
  x.report("0.0.positive?") { 0.positive? } #=> false
  x.report("-1.0.positive?") { 0.positive? } #=> false
end
```

For `Integer`:

<table>
<tr>
  <th>1 > 0</th>
  <td class="text-right">31.644M <small>(± 0.1%)</small> i/s</td>
</tr>
<tr>
  <th>0 > 0</th>
  <td class="text-right">31.625M <small>(± 0.2%)</small> i/s</td>
</tr>
<tr>
  <th>-1 > 0</th>
  <td class="text-right">30.919M <small>(± 0.1%)</small> i/s</td>
</tr>
<tr>
  <th>1.positive?</th>
  <td class="text-right">22.602M <small>(± 0.2%)</small> i/s</td>
</tr>
<tr>
  <th>0.positive?</th>
  <td class="text-right">22.621M <small>(± 0.2%)</small> i/s</td>
</tr>
<tr>
  <th>-1.0.positive?</th>
  <td class="text-right">22.676M <small>(± 0.1%)</small> i/s</td>
</tr>
</table>

For `Float`:

<table>
<tr>
  <th>1.0 > 0</th>
  <td class="text-right">31.442M <small>(± 0.2%)</small> i/s</td>
</tr>
<tr>
  <th>0.0 > 0</th>
  <td class="text-right">31.178M <small>(± 0.1%)</small> i/s</td>
</tr>
<tr>
  <th>-1.0 > 0</th>
  <td class="text-right">30.861M <small>(± 0.2%)</small> i/s</td>
</tr>
<tr>
  <th>1.0.positive?</th>
  <td class="text-right">22.707M <small>(± 0.1%)</small> i/s</td>
</tr>
<tr>
  <th>0.0.positive?</th>
  <td class="text-right">22.576M <small>(± 0.1%)</small> i/s</td>
</tr>
<tr>
  <th>-1.0.positive?</th>
  <td class="text-right">22.654M <small>(± 0.1%)</small> i/s</td>
</tr>
</table>

The benchmark shows that both for `Integer` and `Float`s the _non-sugared_ syntax wins out.

However, the important thing to note is that in all cases I was achieving tens of millions of executions per second on my laptop. For anything other than the most extreme performance requirements opt for the more readable version. And if performance _truly_ matters beyond this scale, then you likely have bigger issues!