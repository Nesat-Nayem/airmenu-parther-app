#!/usr/bin/env ruby
require 'json'

INTL_PATH = 'lib/l10n/intl_en.arb'
SEARCH_PATH = 'lib/modules/**/intl_en.arb'

# Clear existing file content
File.truncate(INTL_PATH, 0)

output_hash = { "@@locale": "en" }

# Loop through each feature intl_en file and add to hash
featureFiles = Dir.glob(SEARCH_PATH)
featureFiles.each do |file|
    puts "Parsing #{file}"
    open_file = File.open file
    data = JSON.load open_file
    keys = data.keys
    keys.each do |key|
        next if key.start_with?("@@")
        if output_hash.key? key
            abort "ABORTING #{key} ALREADY EXISTS - DUPLICATE IN #{file}"
        else
            puts "Adding #{key} IN #{file}"
            output_hash[key] = data[key]
        end
    end
    open_file.close
end

File.write(INTL_PATH, JSON.pretty_generate(output_hash))