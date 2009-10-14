#!/usr/bin/ruby
$: << File.join(File.dirname(__FILE__), "lib")
require 'step_sensor'

MATCHER = StepSensor::Matcher.new			

(Dir[File.join(File.expand_path("~"), %w[src Clearwave Kiosk KioskMVC  Features features ** *.rb])] +
Dir[File.join(File.expand_path("~"), %w[src Clearwave Common Features ** *.rb])]).each do |f|
	IO.read(f).scan(/^((?:Given|Then|When)[^\r\n]*)/).flatten.each { |step| MATCHER << step }
end.flatten

query = ARGV.join(" ")

MATCHER.complete(query).sort.each do |x|
	$stdout << query
	$stdout << x
	$stdout << "\n"
end

