---
title: 'Benchmarking each_with_object Against inject when building Hashes from Arrays'
layout: post
category:
  - ruby
---

I read [Better Hash Injection using each_with_object](http://technology.customink.com/blog/2014/10/14/better-hash-injection-using-each-with-object/) with interest.

I'd long known that using Ruby's `Hash#merge!` rather than `Hash#merge` was much faster: merge hash in place in memory, don't copy and assign. I'd never come across `each_with_index` in the wild, _at least and remembered_.

What a fool I've been.

Rather than use code like...

{% highlight ruby %}
array_of_stuff.inject({}) do |result, element|
  result.merge!(element.id => element.value)
end
{% endhighlight %}

It's much more idiomatic Ruby to use `each_with_object`.

{% highlight ruby %}
array_of_stuff.each_with_object({}) do |element, result|
  result[element.id] = element.value
end
{% endhighlight %}

I was interested to see how this idiomatic Ruby performed. I put together a little script to test the various ways of generating a Hash from an array of _simple_ `Struct`-based objects.

The code creates a simple `Hash` from a thousand element `Array` of `User` objects. And does it 100 times.

{% highlight ruby %}
require 'benchmark'

User = Struct.new(:id, :count)
a = Array.new(1000) { |i| User.new(i, count: rand(1000)) }
n = 100

Benchmark.bmbm do |x|
  x.report('assign&return') do
    n.times do
      a.inject({}) { |memo, i| memo[i.id] = i.count; memo }
    end
  end
  x.report('merge') do
    n.times do
      a.inject({}) { |memo, i| memo.merge(i.id => i.count) }
    end
  end
  x.report('merge!') do
    n.times do
      a.inject({}) { |memo, i| memo.merge!(i.id => i.count) }
    end
  end
  x.report('each_with_object') do
    n.times do
      a.each_with_object({}) { |i, memo| memo[i.id] = i.count }
    end
  end
end
{% endhighlight %}

The results were interesting (rounded to three decimal places).

<table>
<thead>
<tr>
  <th></th>
  <th class="numeric notonphone">user</th>
  <th class="numeric notonphone">system</th>
  <th class="numeric notonphone">total</th>
  <th class="numeric">real</th>
</tr>
</thead>
<tbody>
<tr>
  <th>assign&return</th>
  <td class="numeric notonphone">0.030</td>
  <td class="numeric notonphone">0.000</td>
  <td class="numeric notonphone">0.030</td>
  <th class="numeric">(0.029)</th>
</tr>
<tr>
  <th>merge</th>
  <td class="numeric notonphone">21.800</td>
  <td class="numeric notonphone">0.950</td>
  <td class="numeric notonphone">22.750</td>
  <th class="numeric">(22.771)</th>
</tr>
<tr>
  <th>merge!</th>
  <td class="numeric notonphone">0.070</td>
  <td class="numeric notonphone">0.000</td>
  <td class="numeric notonphone">0.070</td>
  <th class="numeric">(0.062)</th>
</tr>
<tr>
  <th>each_with_object</th>
  <td class="numeric notonphone">0.040</td>
  <td class="numeric notonphone">0.000</td>
  <td class="numeric notonphone">0.040</td>
  <th class="numeric">(0.035)</th>
</tr>
</tbody>
</table>

Turns out the 'ugliest' code is the fastest: `inject` then assign a new key to an existing hash and return the hash from the block. It's marginally faster than the `each_with_index` variant, but not by a huge amount.

Although if you're using `merge` without the `!`... _just don't_.
