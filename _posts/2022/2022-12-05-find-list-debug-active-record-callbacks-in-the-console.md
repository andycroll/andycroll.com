---
title: "Find out what callbacks are defined on an Active Record model in the console"
description: "Sometimes it's hard to know what is defined where"
layout: article
category: ruby
image:
  base: "2022/find-list-debug-active-record-callbacks-in-the-console"
  alt: "Three old payphones"
  credit: "Pavan Trikutam"
  source: "https://unsplash.com/photos/71CjSSB83Wo"
---

I was recently asked by my [First #RubyFriend](https://firstrubyfriend.org) mentee how to list the callbacks present on an Active Record model. I didn't know.

They were looking at a vast legacy codebase, with some large models defined across multiple files. The models used various gems, custom callbacks, and concerns. It was very hard to parse what behaviours the callbacks were causing.

I found mention of [debugging callbacks in the Rails API documentation](https://api.rubyonrails.org/classes/ActiveRecord/Callbacks.html#module-ActiveRecord::Callbacks-label-Debugging+callbacks) and, after a little digging, built a simple loop you can use to find the callbacks defined on an Active Record model.

## Use...

...a loop in the Rails console.

Open the console.

```shell
bin/rails console
```

Paste this code into the console to see the user-defined callbacks on a model:

```ruby
YourModel.__callbacks.each_with_object(Hash.new([])) do |(k, callbacks), result|
  next if k == :validate # ignore validations
  
  callbacks.each do |c|
    # remove autosaving callbacks from result
    next if c.filter.to_s.include?("autosave")
    next if c.filter.to_s.include?("_ensure_no_duplicate_errors")

    result["#{c.kind}_#{c.name}"] += [c.filter]
  end
end
```

For the `User` object in my application, which uses [the Devise gem](https://github.com/heartcombo/devise) for authentication, the results look like this:

```ruby
=> {
  "before_validation"=>[:downcase_keys, :strip_whitespace, :set_timestamps_for_agreements],
  "after_save"=>[#<Proc:0x00000001133b94d0 /.../gems/money-rails-1.15.0/lib/money-rails/active_record/monetizable.rb:148>],
  "before_save"=>[:ensure_authentication_token],
  "after_create"=>[:skip_reconfirmation_in_callback!],
  "before_create"=>[:generate_confirmation_token],
  "after_update"=>[:send_password_change_notification, :send_email_changed_notification],
  "before_update"=>[:clear_reset_password_token :postpone_email_change_until_confirmation_and_regenerate_confirmation_token],
  "after_commit"=>[:send_on_create_confirmation_instructions, :send_reconfirmation_instructions],
}
```

Here you can see the callbacks inserted into the `User` model based on our configuration of the `devise` gem. These aren't listed in the `app/models/user.rb` file.

You can also see a dynamic `Proc`-based callback inserted by our use of the `money-rails` gem.


## How does this work?

The `#__callbacks` method on a model is [defined as a class method via Active Support](https://github.com/rails/rails/blob/main/activesupport/lib/active_support/callbacks.rb#L68). If accessed directly, like calling `YourModel.__callbacks`, it returns a complex hash structure containing the logic performed by the Active Record instance before or after changing its state.

The code above only pulls out the main method calls.

In the specific code above I’ve presumed the following:

You aren't interested in seeing all of the validations. Code like `validates_presence_of :attribute` creates an entry in the callback chain. We skip displaying these with `next if k == :validate`.

You aren't interested in the callbacks that automatically save the values of associated models where you `have_many :related_models`. Hence `next if c.filter.to_s.include?("autosave")`.


## Why?

When you’re new to a complex application this may be useful as a debugging tool.

I tend to limit my use of callbacks as much as possible due to the ease with which I‘ve confused myself before, but if you’re in a codebase that uses them a lot, this might get you up to speed with the existing behaviour more quickly.


## Why not?

Please don’t use this code in production. It's _only_ for debugging and helping you to understand a new codebase.

I can't think of a reason to use this in application code. Furthermore, the `__` prefix in the method name indicates this is mostly based on Rails’s internal API and is subject to change.