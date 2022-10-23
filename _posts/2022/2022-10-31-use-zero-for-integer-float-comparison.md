---
title: "Use zero? for comparison of numerics like Integer, Float and BigDecimal"
description: "Other languages don't have this"
layout: article
category: ruby
image:
  base: "2022/use-zero-for-integer-float-comparison"
  alt: "A zero on a sign on the wall"
  credit: "Bernard Hermant"
  source: "https://unsplash.com/photos/rfpSOlH1JlQ"
---

Compared to other similar languages, Ruby often prioritises readability (and joy) when it comes to its syntax and the methods provided in its Standard Library.

An example of this is the syntactic sugar used when comparing a value to zero.

See the documentation of the `.zero?` method on [`Integer`](https://ruby-doc.org/core-3.1.2/Integer.html#zero-3F-method), [`Float`](https://ruby-doc.org/core-3.1.2/Float.html#zero-3F-method), [`Numeric`](https://ruby-doc.org/core-3.1.2/Numeric.html#zero-3F-method) and [`BigDecimal`](https://ruby-doc.org/stdlib-3.1.2/libdoc/bigdecimal/rdoc/BigDecimal.html#zero-3F-method).


## Instead of...

...checking whether a value is equal to zero in a conditional:

```ruby
if number == 0
  :yes
else
  :no
end
```


## Use...

...the built-in `#zero?` method on all numeric types:

```ruby
if number.zero?
  :yes
else
  :no
end
```


## Why?

The Ruby-ish syntax in this case is clearer and less error prone.

It is very easy to type `number = 0` and thus assign a variable in the conditional rather than compare (although you might use tests to protect yourself from this particular error).


## Why not?

The `== 0` syntax is how _many_ other similar languages perform comparison and is deeply ingrained in my fingers. I still struggle to apply this advice even after 15 years of Ruby programming.

You might get some folks pushing back for “performance” reasons.

```ruby
require "benchmark/ips"

Benchmark.ips do |x|
  x.report("1 == 0") { 1 == 0 } #=> false
  x.report("0 == 0") { 0 == 0 } #=> true
  x.report("1.zero?") { 1.zero? } #=> false
  x.report("0.zero?") { 0.zero? } #=> true

  x.report("1.0 == 0") { 1.0 == 0 } #=> false
  x.report("0.0 == 0") { 0.0 == 0 } #=> true
  x.report("1.0.zero?") { 1.0.zero? } #=> false
  x.report("0.0.zero?") { 0.0.zero? } #=> true
end
```

For `Integer`:

<table>
<tr>
  <th>1 == 0</th>
  <td class="text-right">29.049M <small>(± 0.7%)</small> i/s</td>
</tr>
<tr>
  <th>0 == 0</th>
  <td class="text-right">28.972M <small>(± 0.3%)</small> i/s</td>
</tr>
<tr>
  <th>1.zero?</th>
  <td class="text-right">23.009M <small>(± 1.0%)</small> i/s</td>
</tr>
<tr>
  <th>0.zero?</th>
  <td class="text-right">22.860M <small>(± 1.7%)</small> i/s</td>
</tr>
</table>

For `Float`:

<table>
<tr>
  <th>1.0 == 0</th>
  <td class="text-right">18.768M <small>(± 2.0%)</small> i/s</td>
</tr>
<tr>
  <th>0.0 == 0</th>
  <td class="text-right">19.066M <small>(± 0.5%)</small> i/s</td>
</tr>
<tr>
  <th>1.0.zero?</th>
  <td class="text-right">22.784M <small>(± 0.6%)</small> i/s</td>
</tr>
<tr>
  <th>0.0.zero?</th>
  <td class="text-right">22.841M <small>(± 0.8%)</small> i/s</td>
</tr>
</table>

The benchmark shows that for `Integer`s the `==` syntax is faster, but for `Float`s the `.zero?` syntax wins out.

However, the important thing to note is that in all cases you still get millions of executions per second, so in _your_ code you should emphasise the readability over any perceived performance implications!
