#!/usr/bin/env ruby

all_html = <<HTML
<html>
<head>
<meta http-requiv="Content-Type" content="text/html; charset=utf-8">
<meta name="author" content="青木淳">
<title>オブジェクト指向システム分析設計入門</title>
</head>
<body>
HTML

ITOOAOOD_URI = ARGV.shift
ITOOAOOD_DIRNAME = File.dirname(ITOOAOOD_URI)
ITOOAOOD_FILENAME = File.basename(ITOOAOOD_URI)

ARGV.each do |filename|
  html = File.open(filename, 'r:cp932:UTF-8') { |io| io.read }

  match = filename.match(%r[chapter(\d+)/])
  if match
    chapter_number = match[1]
  end

  # CR+LF -> LF
  html.gsub!(/\r\n/, "\n")

  # Header
  html.sub!(%r[^.*?<body>]m, '')

  # No menu
  html.sub!(%r[<div id="menu">.*?</div>]m, '')

  # Chapeter
  html.sub!(%r[<hr>.*?<h1>(.*?)</h1>]m, '<h1 class="chapter">\1</h1>')
  html.sub!(%r[<hr>.*?<h2>(.*?)</h2>]m, '<h1 class="chapter">\1</h1>')

  # Link
  html.gsub!(%r[<a(.*?)href="(.*?)"(.*?)>(.*?)</a>]) do |anchor_tag|
    prefix = $1
    uri = $2
    postfix = $3
    body = $4
    if uri[0..2] == '../'
      uri = "#{ITOOAOOD_DIRNAME}/#{uri}"
      %Q[<a#{prefix}href="#{uri}"#{postfix}>#{body}</a>]
    elsif uri[0..6] == 'chapter'
      #if uri.match(/\#/)
      #  uri.gsub!(/.*\#/,'#')
      #else
      #  link_chapter_number = uri.match(%r[chapter(\d+)/])[1]
      #  uri = "##{link_chapter_number}"
      #end
      body
    elsif uri[0..3] == '#Ref'
      uri = "#{uri[0..3]}#{chapter_number}-#{uri[4..-1]}"
      %Q[<a#{prefix}href="#{uri}"#{postfix}>#{body}</a>]
    else
      %Q[<a#{prefix}href="#{uri}"#{postfix}>#{body}</a>]
    end
  end

  # Anchor
  html.gsub!(%r[<li>(.*?)<a name="Ref(.*?)">(.*?)</a>(.*?)]) do |anchor_tag|
    name = $2
    body = "#{$1} #{$3} #{$4}"
    if name.empty?
      name = "Ref#{chapter_number}"
    else
      name = "Ref#{chapter_number}-#{name}"
    end
    %Q[<li><a href="name=#{name}">#{body}</a></li>\n]
  end

  html.gsub!(%r[(<li><a href="name=Ref.*?">)(.*?)(</a></li>)$(.*?)(?=<li>|</ol>)]m) do |anchor_tag|
    tag_open = $1
    body = $2.strip + $4.strip
    tag_close = $3
    %Q[#{tag_open}#{body}#{tag_close}\n]
  end

  # Image
  html.gsub!(%r[<img(.*?)src="(.*?)"(.*?)>]) do |image_tag|
    prefix = $1
    uri = $2
    postfix = $3
    if uri.match('/')
      uri = File.basename(uri)
    end
    %Q[<img#{prefix}src="#{uri}"#{postfix}>]
  end

  # Footer
  html.sub!(%r[</body>.*]m, '')

  all_html << html
end

all_html << '</body></html>'

puts(all_html)

