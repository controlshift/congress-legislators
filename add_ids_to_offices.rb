#!/usr/bin/env ruby

require 'yaml'

legislators = YAML.load_file('legislators-district-offices.yaml')

legislators_out = []

legislators.each do |legislator|
  # If the legislator has no offices, can skip processing
  unless legislator.has_key?('offices')
    legislators_out << legislator
    next
  end

  # Add an 'id' key to every office
  bioguide_id = legislator['id']['bioguide']
  highest_count_by_locality = {}
  offices_out = []

  legislator['offices'].each do |office|
    locality_slug = office['city'].downcase.gsub(/[ -.']/, '_')
    office_id = "#{bioguide_id}-#{locality_slug}"

    if highest_count_by_locality.has_key?(locality_slug)
      office_id = "#{office_id}-#{highest_count_by_locality[locality_slug] + 1}"
      highest_count_by_locality[locality_slug] += 1
    else
      highest_count_by_locality[locality_slug] = 0
    end

    office['id'] = office_id

    offices_out << office
  end

  legislator['offices'] = offices_out
  legislators_out << legislator
end

# Write the file back out
File.open('legislators-district-offices.yaml', 'w') do |fh|
  fh.write(YAML.dump(legislators_out))
end
