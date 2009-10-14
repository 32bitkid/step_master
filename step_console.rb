#!/usr/bin/ruby
$: << File.join(File.dirname(__FILE__), "lib")
require 'step_sensor'
require 'readline'

stty_save = `stty -g`.chomp
trap('INT') { puts; system('stty', stty_save); exit }

OPTS = {:easy => false}

MATCHER = StepSensor::Matcher.new			

Readline.completer_word_break_characters = '' 
Readline.completion_append_character = ''
Readline.completion_proc = proc { |s| MATCHER.complete(s, :easy => true).collect { |x| s + x } }

(Dir[File.join(File.expand_path("~"), %w[src Clearwave Kiosk KioskMVC  Features features ** *.rb])] +
Dir[File.join(File.expand_path("~"), %w[src Clearwave Common Features ** *.rb])]).each do |f|
	IO.read(f).scan(/^((?:Given|Then|When)[^\r\n]*)/).flatten.each { |step| MATCHER << step }
end.flatten

while(str = Readline.readline('> ', true))
	break if str[/exit/i]
	OPTS[:easy] = !OPTS[:easy] if str == "easy"
	puts MATCHER.match?(str) ? "Found" : "Not Found"
end
