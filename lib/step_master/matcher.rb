#!/usr/bin/env ruby

require 'step_master/step_item'
require 'step_master/step_variable'
require 'step_master/possible'

# Provide a simple and easy way to find and auto-complete gherkin steps,
# when writing cucumber features
# See StepMaster for usage details.
module StepMaster

	# This class collects raw steps as strings.
	# 
  # The complete method returns a list of all possible
	# steps that start with a given string (taking into
	# account captures and imbedded regexps).
	# 
	# The is_match? method lets you check if a string exactly
	# matches to a step definition
	#
	class Matcher
		
		STEP_REGEX = /^\s*(Given|Then|When)\s*\(?\s*\/\^?(.*)\/(\w*)\s*\)?\s*(?:do|\{)\s*(\|[^\|]+\|)?/.freeze
		ARG_NAMES_REGEX = /\|(.*)\|/
		ARG_TEXT_REGEX = /\(.*?[^\\]\)[\?\+\*]?/
		NON_CAPTURE_REGEX = /^\(\?\:/
		CHUNK_REGEX = /\S+|\s\??/
		
		attr_reader :match_table
		
		def initialize(match_table = Possible.new )
			@match_table = match_table
		end
		
		# Insert a Ruby Step definition into the Match Table
		#
		# ==== Examples
		#	  matcher << "Given /^this is a step$/ do"
		#
		def <<(value)
			add(value, :format => :rb)
		end
		
		def add(value, options = {})
			
			raise "#{value.inspect} is not a step" unless value =~ STEP_REGEX
			
			full_line = $&
			step_type = $1
			regex = $2.chomp("$")
			regex_options = $3
			args = $4
			
			arg_names = (args =~ ARG_NAMES_REGEX) ? $1.split(/\s*,\s*/) : []
			arg_regexs = extract_captures(regex)
			
			arg_objects = arg_regexs.collect do |x|
				is_non_capture = (x =~ NON_CAPTURE_REGEX) != nil
				StepVariable.new(x, regex_options, (is_non_capture) ? nil : arg_names.shift)
			end
			
			if arg_regexs.length > 0
				regex.split(Regexp.union(arg_regexs.collect { |x| Regexp.new(Regexp.escape(x)) })).collect { |x|
					x.scan(CHUNK_REGEX).collect { |i| StepItem.new(i, regex_options) }
				}.+(Array.new(5)).zip(arg_objects).flatten.compact.unshift(StepItem.new(" ", regex_options)).unshift(StepItem.new(step_type, regex_options))
			else
				regex.scan(CHUNK_REGEX).unshift(" ").unshift(step_type).collect { |i| StepItem.new(i, regex_options) }
			end.inject(@match_table) { |parent, i| parent[i] ||= Possible.new }.terminal!(value, options)					
			
		end
		
		# Returns all possible outcomes of a string.
		#
		# ==== Parameters
		# * +string+ - The string to try to auto complete
		# * +options+ - :easy => true will replace captures with the variable names in the step definition
		#
		# ==== Examples
		#   matcher.complete("Given this")
		#   matcher.complete("Given this", :easy => true)
		#
		def complete(string, options = {})
			possible_strings find_possible(string), options
		end
		
		# Returns true if the string matches exactly to a step definition
		#
		# ==== Examples
		#   matcher << "Given /^this$/ do"
		#   matcher.is_match?("Given this") #=> true
		#   matcher.is_match?("Given that") #=> false
		#
		def is_match?(string)
			find_possible(string).any?{ |x| x.terminal? }
		end
		
		def where_is?(string)
			find_possible(string).select{ |x| x.terminal? }.collect { |x| x.file || x.result }
		end
		
		def terminals(string)
			find_possible(string).select{ |x| x.terminal? }
		end
		
		
private
		def find_possible(input, against = @match_table)
			return against.keys.collect do |x|
				if input =~ x.to_regexp
					new_input = $'
					unless new_input.empty?
						find_possible new_input, against[x]
					else
						against[x]
					end
				end
			end.flatten.compact
		end
		
		def possible_strings(possible, options={}, so_far = [], collection = [])
			if possible.is_a?(Array)
				possible.each { |a| possible_strings(a, options, so_far, collection) }
			else
				possible.each do |k,v|
					str = k.to_s(options)

					here = (so_far + [str])
					
					collection << here.join("") if v.terminal?
					possible_strings(v, options, here, collection)
				end
			end
			collection
		end
		
		def extract_captures(t)
			captures = []
			index = 0
			while true do
				break unless index = t.index(/\(/, index) 
				index += 1
				next if t[index-2,1] == "\\"
				
				close, depth = index - 1, 1
				
				begin
					next_close = t.index(/[^\\]\)/, close)
					next_open = t.index(/[^\\]\(/, close)
					
					raise "Unmatched" unless next_close
					
					if !next_open.nil? and next_open < next_close
						close = next_open + 1
						depth += 1
					else
						close = next_close + 1
						depth -= 1
					end
					
				end while depth > 0
				
				close += $&.length if t[close + 1..-1] =~ /^[\+\*\?]/
				captures << t[index -1..close]
				
				index = close
			end
			captures
		end		
	end
end
