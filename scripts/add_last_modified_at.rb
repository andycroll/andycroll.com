#!/usr/bin/env ruby
# frozen_string_literal: true

# One-off script to add last_modified_at to post front matter
# based on git commit history.
#
# Usage: ruby scripts/add_last_modified_at.rb
#
# Only adds last_modified_at if the BODY content (not front matter)
# was modified after the publication date.

require "shellwords"
require "time"
require "yaml"

POSTS_DIR = File.expand_path("../_posts", __dir__)

def extract_body(content)
  return "" unless content.start_with?("---")

  parts = content.split("---", 3)
  return "" if parts.length < 3

  parts[2].strip
end

def git_commits(filepath)
  # Get all commit hashes and dates for this file (most recent first)
  result = `git log --follow --format="%H %ai" -- #{Shellwords.escape(filepath)} 2>/dev/null`.strip
  return [] if result.empty?

  result.lines.map do |line|
    hash, *date_parts = line.strip.split
    { hash: hash, date: Time.parse(date_parts.join(" ")) }
  end
end

def git_file_content(filepath, commit_hash)
  # Get file content at a specific commit
  # git show requires path relative to repo root
  relative_path = filepath.sub("#{Dir.pwd}/", "")
  `git show #{commit_hash}:#{Shellwords.escape(relative_path)} 2>/dev/null`
end

def find_last_body_modification(filepath)
  commits = git_commits(filepath)
  return nil if commits.length < 2

  # Compare each commit to the next older one to find body changes
  # commits[0] is most recent, commits[-1] is oldest
  commits.each_cons(2) do |newer, older|
    newer_content = git_file_content(filepath, newer[:hash])
    older_content = git_file_content(filepath, older[:hash])

    newer_body = extract_body(newer_content)
    older_body = extract_body(older_content)

    # If body changed between these commits, newer commit is when it changed
    if newer_body != older_body
      return newer[:date]
    end
  end

  # No body changes found - body is same since first commit
  nil
end

def parse_front_matter(content)
  return nil unless content.start_with?("---")

  parts = content.split("---", 3)
  return nil if parts.length < 3

  yaml = YAML.safe_load(parts[1], permitted_classes: [Time, Date])
  [yaml, parts[1], parts[2]]
end

def extract_date_from_filename(filepath)
  basename = File.basename(filepath)
  if basename =~ /^(\d{4})-(\d{2})-(\d{2})/
    Time.new($1.to_i, $2.to_i, $3.to_i)
  end
end

def to_time(value)
  case value
  when Time
    value
  when Date
    value.to_time
  when String
    Time.parse(value)
  else
    nil
  end
end

def format_date(time)
  time.strftime("%Y-%m-%d")
end

def same_day?(time1, time2)
  time1.year == time2.year && time1.month == time2.month && time1.day == time2.day
end

posts = Dir.glob(File.join(POSTS_DIR, "**/*.md"))
updated_count = 0
skipped_count = 0

posts.each do |filepath|
  content = File.read(filepath)
  parsed = parse_front_matter(content)

  unless parsed
    puts "SKIP (no front matter): #{filepath}"
    skipped_count += 1
    next
  end

  yaml, yaml_raw, body = parsed

  # Get publication date from front matter or filename
  pub_date = to_time(yaml["date"]) || extract_date_from_filename(filepath)

  unless pub_date
    puts "SKIP (no date): #{filepath}"
    skipped_count += 1
    next
  end

  # Skip if already has last_modified_at
  if yaml["last_modified_at"]
    puts "SKIP (already has last_modified_at): #{filepath}"
    skipped_count += 1
    next
  end

  # Find when body content was last modified
  body_modified = find_last_body_modification(filepath)

  unless body_modified
    puts "SKIP (no body changes): #{File.basename(filepath)}"
    skipped_count += 1
    next
  end

  # Only add if body modification is after publication date
  if body_modified <= pub_date
    puts "SKIP (not after pub date): #{File.basename(filepath)}"
    skipped_count += 1
    next
  end

  # Add last_modified_at to front matter
  if yaml_raw =~ /^date:/m
    new_yaml = yaml_raw.gsub(/^(date:.*)$/m, "\\1\nlast_modified_at: #{format_date(body_modified)}")
  else
    new_yaml = yaml_raw.rstrip + "\nlast_modified_at: #{format_date(body_modified)}"
  end

  # Ensure yaml ends with newline before closing ---
  new_yaml = new_yaml.rstrip + "\n"

  new_content = "---#{new_yaml}---#{body}"
  File.write(filepath, new_content)

  puts "UPDATED: #{File.basename(filepath)} -> #{format_date(body_modified)}"
  updated_count += 1
end

puts "\nDone! Updated #{updated_count} posts, skipped #{skipped_count}"
