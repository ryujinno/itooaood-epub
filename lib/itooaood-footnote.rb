#!/usr/bin/env ruby

xhtml = File.open(ARGV[0], 'r:UTF-8') { |io| io.read }

# Footnote
xhtml.gsub!(%r[<a(.*?)href="(#Ref.*?)"(.*?)>(.*?)</a>]) do |anchor_tag|
  prefix = $1
  uri = $2
  postfix = $3
  body = $4
  %Q[<a epub:type="noteref" class="noteref"#{prefix}href="#{uri}"#{postfix}>#{body}</a>]
end

xhtml.gsub!(%r[<li><a href="name=(.*?)">(.*?)</a></li>]) do |anchor_tag|
  name = $1
  body = $2
  %Q[<li>#{body}<aside epub:type="footnote" id="#{name}"><p>#{body}</p></aside></li>]
end

puts(xhtml)

