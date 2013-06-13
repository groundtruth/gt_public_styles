#!/usr/bin/env ruby

require "fileutils"

if ARGV.count < 1
    puts "Usage: rewrap.rb first_file [second_file ...]"
    exit 1
end

ARGV.each do |filename|

    raw_text = File.readlines(filename).join("")
    raise "Already rewrapped '#{filename}'!" if raw_text.match(/<NamedLayer>/)

    inner_text = raw_text.
                    sub(/<\?xml[^\?]*\?>/, '').
                    sub(/<sld:UserStyle[^>]*>/, '<sld:UserStyle>')

    workspace_name = filename.split("/").last.split("-").first
    layer_name = filename.split("/").last.split("-").last.sub(/\.sld$/,"")
    
    rewrapped_text = <<-EOS
<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:sld="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" xmlns:gml="http://www.opengis.net/gml">
    <NamedLayer>
        <Name>#{workspace_name}:#{layer_name}</Name>
        #{ inner_text }
    </NamedLayer>
</StyledLayerDescriptor>
    EOS

    FileUtils.cp(filename, "#{filename}.backup")
    File.open(filename, 'w') { |f| f.write(rewrapped_text) }

    puts "Rewrapped #{filename}"

end
