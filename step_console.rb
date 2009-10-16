#!/usr/bin/ruby
$: << File.join(File.dirname(__FILE__), "lib")
require 'step_master'
require 'readline'
require 'yaml'

settings = File.exists?("settings.yml") ? YAML.load_file("settings.yml")  : {"step_paths" => ["**/*.rb"] }

stty_save = `stty -g`.chomp
trap('INT') { puts; system('stty', stty_save); exit }

OPTS = {:easy => false}

MATCHER = StepMaster::Matcher.new			

Readline.completer_word_break_characters = '' 
Readline.completion_append_character = ''
Readline.completion_proc = proc { |s| MATCHER.complete(s, :easy => true).collect { |x| s + x } }

settings["step_paths"].collect { |x| Dir[x] }.flatten.uniq.each do |f|
	IO.readlines(f).each_with_index do |str, line|
		MATCHER << str.chomp + " # " + File.basename(f) + ":" + (line + 1).to_s if str =~ /^(Given|Then|When)/
	end
end


while(str = Readline.readline('> ', true))
	break if str[/exit/i]
	OPTS[:easy] = !OPTS[:easy] if str == "easy"
	puts (loc = MATCHER.where_is?(str)).empty? ? "Not Found" : loc.join("\n")
end
