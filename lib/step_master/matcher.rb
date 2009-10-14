require 'step_master/step_item'
require 'step_master/step_variable'
require 'step_master/possible'

module StepMaster
	class Matcher
		
		STEP_REGEX = /^\s*(Given|Then|When)\s*\(?\s*\/\^?(.*)\/(\w*)\s*\)?\s*(?:do|\{)\s*(\|[^\|]+\|)?/.freeze
		ARG_NAMES_REGEX = /\|(.*)\|/
		ARG_TEXT_REGEX = /\(.*?[^\\]\)\??/
		NON_CAPTURE_REGEX = /\(\?\:/
		CHUNK_REGEX = /\S+|\s\??/
		
		attr_reader :match_table
		
		def initialize
			@match_table = Possible.new
		end
		
		def <<(value)
			raise "#{value.inspect} is not a step" unless value =~ STEP_REGEX
			
			full_line = $&
			step_type = $1
			regex = $2.chomp("$")
			regex_options = $3
			args = $4
			
			arg_names = (args =~ ARG_NAMES_REGEX) ? $1.split(/\s*,\s*/) : []
			arg_regexs = regex.chomp("$").scan(ARG_TEXT_REGEX)
			
			arg_objects = arg_regexs.collect do |x|
				is_non_capture = (x =~ NON_CAPTURE_REGEX) != nil
				StepVariable.new(x, regex_options, (is_non_capture) ? nil : arg_names.shift)
			end
			
			
			elements = if arg_regexs.length > 0
				regex.split(Regexp.union(arg_regexs.collect { |x|
					Regexp.new(Regexp.escape(x))
				})).collect { |x|
					x.scan(CHUNK_REGEX).collect { |i| StepItem.new(i, regex_options) }
				}.zip(arg_objects).flatten.compact.unshift(StepItem.new(" ", regex_options)).unshift(StepItem.new(step_type, regex_options))
			else
				regex.scan(CHUNK_REGEX).unshift(" ").unshift(step_type).collect { |i| StepItem.new(i, regex_options) }
			end
						
			elements.inject(@match_table) { |parent, i| parent[i] ||= Possible.new }.terminal!(full_line)			
		end
		
		def complete(string, options = {})
			possible_strings find_possible(string), options
		end
		
		def match?(string)
			find_possible(string).any?{ |x| x.terminal? }
		end
		
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
	end
end
