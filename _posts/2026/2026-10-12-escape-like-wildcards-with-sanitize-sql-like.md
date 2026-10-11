---
title: "Escape LIKE Wildcards with sanitize_sql_like"
description: "Escape % and _ in search terms so users get the results they looked for."
layout: article
category: ruby
date: 2026-10-12 09:00
image:
  base: "2026/escape-like-wildcards-with-sanitize-sql-like"
  alt: "A hand in a blue rubber glove holding a spray bottle"
  credit: "Towfiqu barbhuiya"
  source: "https://unsplash.com/photos/hand-in-glove-holding-spray-bottle-ho-p7qLBewk"
---

When you add a search box backed by a `LIKE` or `ILIKE` query, user input can change the pattern. A search for `100%` returns every row containing `100`. A bare `%` returns the whole table. Active Record's [`sanitize_sql_like`](https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql_like) fixes this.

## Instead of…

…dropping the user's term straight into the pattern:

```ruby
class Article < ApplicationRecord
  scope :containing_text, ->(query) {
    where("articles.title ILIKE :q", q: "%#{query}%")
  }
end
```

```ruby
Article.containing_text("100%")        # also matches "100 days of Rails"
Article.containing_text("snake_case")  # also matches "snake-case vs kebab-case"
Article.containing_text("%")           # matches everything
```

## Use…

…`sanitize_sql_like` around the term, before you wrap it in your own wildcards:

```ruby
class Article < ApplicationRecord
  scope :containing_text, ->(query) {
    where("articles.title ILIKE :q", q: "%#{sanitize_sql_like(query.to_s)}%")
  }
end
```

```ruby
Article.containing_text("100%")        # "Reaching 100% coverage", not "100 days of Rails"
Article.containing_text("snake_case")  # "Why snake_case wins", not "snake-case vs kebab-case"
Article.containing_text("%")           # titles with a literal %, not everything
```

## Why?

`LIKE` has three special characters: `%` matches any run of characters, `_` matches exactly one, and `\` escapes the other two. A bind parameter protects the SQL statement, but it passes these characters through untouched.

`sanitize_sql_like` puts a backslash in front of each `%`, `_` and `\`, so they match literally:

```ruby
Article.sanitize_sql_like("100%")        #=> "100\\%"
Article.sanitize_sql_like("snake_case")  #=> "snake\\_case"
Article.sanitize_sql_like("c:\\tmp")     #=> "c:\\\\tmp"
```

Postgres and MySQL use `\` as the escape character by default. SQLite has no default, so add an `ESCAPE` clause and pass the same character to `sanitize_sql_like`:

```ruby
where("articles.title LIKE :q ESCAPE '!'", q: "%#{sanitize_sql_like(query.to_s, "!")}%")
```

Call `.to_s` on the input. `sanitize_sql_like` calls string methods on its argument, so it raises `NoMethodError` on `nil`. A blank search then becomes `%%` and matches every row. To return no results instead:

```ruby
scope :containing_text, ->(query) {
  return none if query.blank?

  where("articles.title ILIKE :q", q: "%#{sanitize_sql_like(query)}%")
}
```

Escape the term *before* adding your own wildcards. `"%#{sanitize_sql_like(query)}%"` keeps the outer `%` as wildcards and escapes the inner ones. `sanitize_sql_like("%#{query}%")` escapes your wildcards too, so it only finds titles that contain a literal `%` either side of the term.

This method has been public API since Rails 5.2. Use it alongside the bind parameters from [not interpolating strings into Active Record](/ruby/really-really-really-do-not-interpolate-strings-into-active-record-methods/). Search your app for `LIKE` and `ILIKE` to find the queries that need it.

## Why not?

If no user input reaches the pattern, you don't need it. A hardcoded `where("path LIKE 'admin/%'")` is fine.

Some tools let users type `%` on purpose, such as an internal admin search. Escaping breaks that. Tell users in the UI whether wildcards work.

A leading `%` stops the database using a normal index, so every search scans the whole table. On Postgres, a `pg_trgm` GIN index on the column can help.

`sanitize_sql_like` is for `LIKE` and `ILIKE` only. Postgres full-text search with `to_tsquery` has its own syntax to sanitize, and `pg_search` handles that for you.

## Alternative SQLite escaping

Arel's `matches` can also write the `ESCAPE` clause for you:

```ruby
where(arel_table[:title].matches("%#{sanitize_sql_like(query.to_s)}%", "\\"))
```
