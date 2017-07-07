#!/usr/bin/env ruby

ARGV.each do |filename|
  html = File.open(filename, 'r:cp932:UTF-8') { |io| io.read }
  html.scan(%r[<img.*?src="(.*?)".*?>]) do |image_file|
    puts(image_file)
  end
end

