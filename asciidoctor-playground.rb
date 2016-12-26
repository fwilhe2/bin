#!/usr/bin/env ruby

require 'asciidoctor'

topics = Hash.new

base_dir = ARGV[0]

Dir.glob base_dir + '/docs/**/*.adoc' do |doc|
    Asciidoctor.convert_file doc, base_dir: base_dir, mkdirs: true, to_dir: 'output'

    # collect topics to create index files later
    asciidoctor_document = Asciidoctor.load_file doc
    this_topics = asciidoctor_document.attributes['topics'].split(", ")
    this_topics.each do |t|
        if topics[t].nil?
            topics[t] = []
        end
        topics[t] << File.basename(doc, '.adoc') + '.html'
    end

end

meta_index = <<END
= Index

END

# create index files
topics.each do |t, docs|
    meta_index += "link:#{t}-index.html[#{t}]\n\n"
    index = <<END
== Index of #{t}

END
    docs.each do |doc|
        index += "link:#{doc}[#{doc}]\n\n"
    end
    html = Asciidoctor.convert index, header_footer: true
    File.open(base_dir + '/output/' + t + '-index.html', 'w') do |f|
        f.write(html)
    end

end
html = Asciidoctor.convert meta_index, header_footer: true
File.open(base_dir + '/output/index.html', 'w') do |f|
    f.write(html)
end

