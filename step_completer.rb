#!/usr/bin/ruby
$: << File.join(File.dirname(__FILE__), "lib")
require 'step_master'
require 'yaml'

MATCHER = StepMaster::Matcher.new			

settings = File.exists?("settings.yml") ? YAML.load_file("settings.yml")  : {"step_paths" => ["**/*.rb"] }

settings["step_paths"].collect { |x| Dir[x] }.flatten.uniq.each do |f|
	IO.read(f).scan(/^((?:Given|Then|When)[^\r\n]*)/).flatten.each { |step| MATCHER << step }
end.flatten

query = ARGV.join(" ")

MATCHER.complete(query).sort.each do |x|
	$stdout << query
	$stdout << x
	$stdout << "\n"
end

