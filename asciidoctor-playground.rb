#!/usr/bin/env ruby

require 'asciidoctor'

base_dir = ARGV[0]

def output_file_name(input_file_name)
    return File.basename(input_file_name, '.*') + '.html'
end

def convert_directory(base_dir)
    Dir.glob base_dir + '/docs/**/*.adoc' do |doc|
        Asciidoctor.convert_file doc, base_dir: base_dir, mkdirs: true, to_dir: 'output'
    end
end

def create_index_files(base_dir)
    topics = Hash.new
    Dir.glob base_dir + '/docs/**/*.adoc' do |doc|
        asciidoctor_document = Asciidoctor.load_file doc
        this_topics = asciidoctor_document.attributes['topics'].split(", ")
        this_topics.each do |t|
            if topics[t].nil?
                topics[t] = []
            end
            topics[t] << output_file_name(doc)
        end

    end

    meta_index = <<END
= Index

END

    def asciidoc_link(ref, text)
        "link:#{ref}[#{text}]"
    end

    # create index files
    topics.each do |t, docs|
        meta_index += "#{asciidoc_link(t + '-index.html', t)}\n\n"
        index = <<END
== Index of #{t}

END
        docs.each do |doc|
            index += "#{asciidoc_link(doc, File.basename(doc, '.*'))}\n\n"
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
end

convert_directory(base_dir)
create_index_files(base_dir)
