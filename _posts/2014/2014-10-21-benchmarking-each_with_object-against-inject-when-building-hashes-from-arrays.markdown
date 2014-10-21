---
title: 'Benchmarking each_with_object Against inject when building Hashes from Arrays'
layout: post
category:
  - ruby
---

I read [Better Hash Injection using each_with_object](http://technology.customink.com/blog/2014/10/14/better-hash-injection-using-each-with-object/) with interest.

I'd long known that using Ruby's `Hash#merge!` rather than `Hash#merge` was much faster: merge hash in place in memory, don't copy and assign. I'd never come across `each_with_index` in the wild, _at least and remembered_.

What a fool I've been.

Rather than use code like either of these...

{% highlight ruby %}
array_of_stuff.inject({}) do |result, element|
  result[element.id] = element.value
  result
end

array_of_stuff.inject({}) do |result, element|
  result.merge!(element.id => element.value)
end
{% endhighlight %}

...it's much more idiomatic Ruby to use `each_with_object`.

{% highlight ruby %}
array_of_stuff.each_with_object({}) do |element, result|
  result[element.id] = element.value
end
{% endhighlight %}

I was interested to see how this idiomatic Ruby performed. I put together a little script to test the various ways of generating a Hash from an decent-sized array of _simple_ `Struct`-based objects. I used the [benchmark-ips](https://github.com/evanphx/benchmark-ips) gem.

{% highlight ruby %}
require 'benchmark/ips'

User = Struct.new(:id, :stuff)
a = Array.new(1000) { |i| User.new(i, stuff: rand(1000)) }

Benchmark.ips do |x|
  x.report('assign&return') do
    a.inject({}) { |memo, i| memo[i.id] = i.stuff; memo }
  end
  x.report('merge') do
    a.inject({}) { |memo, i| memo.merge(i.id => i.stuff) }
  end
  x.report('merge!') do
    a.inject({}) { |memo, i| memo.merge!(i.id => i.stuff) }
  end
  x.report('map with tuples') do
    a.map { |i| [i.id, i.stuff] }.to_h
  end
  x.report('each_with_object') do
    a.each_with_object({}) { |i, memo| memo[i.id] = i.stuff }
  end
end
{% endhighlight %}

The results were interesting.

<table>
<tr>
  <th>assign&return</th>
  <td class="numeric">3136.7</td><td class="numeric"><small>(±8.2%) i/s</small></td>
</tr>
<tr>
  <th>merge</th>
  <td class="numeric">5.9</td><td class="numeric"><small>(±0.0%) i/s</small></td>
</tr>
<tr>
  <th>merge!</th>
  <td class="numeric">1168.0</td><td class="numeric"><small>(±28.3%) i/s</small></td>
</tr>
<tr>
  <th>map with tuples</th>
  <td class="numeric">2400.8</td><td class="numeric"><small>(±23.0%) i/s</small></td>
</tr>
<tr>
  <th>each_with_object</th>
  <td class="numeric">3220.8</td><td class="numeric"><small>(±3.3%) i/s</small></td>
</tr>
</table>

Turns out the most idiomatic code is _also_ the fastest. Followed surprisingly closely by the 'do the simplest thing' variant, but not by a huge amount.

PS If you're using `merge` without the `!`... _just don't_.
