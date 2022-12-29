#!/usr/bin/env ruby

Dir.chdir(File.expand_path("..", __FILE__))

load "../bin/vp"

$0 = "vp"
vp = VP.new
template = File.read("README.template.md")

vp_usage = vp.usage.lines[2..].join("").chomp()
find_duplicates_usage = vp.find_duplicates_usage.chomp()

usage = "```\n#{vp_usage}\n```"
find_duplicates_usage = "```\n#{find_duplicates_usage}\n```"

template.sub!("`USAGE_BLOCK`", usage)
template.sub!("`FIND_DUPLICATES_USAGE_BLOCK`", find_duplicates_usage)

puts(template)
