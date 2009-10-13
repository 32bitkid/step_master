require 'pp'

module StepSensor
	
	class Possible < ::Hash
		EMPTY = Possible.new		
		
		def terminal!(result)
			@terminal = result.freeze
		end
		
		def terminal?
			!@terminal.nil?
		end
		
		def result
			@terminal
		end
		
		def inspect
			super << terminal? ? "["+result+"]" : ""
		end
	end
	
	class StepItem
		attr_reader :text
		
		def initialize(text)
			@text = text.freeze
		end
		
		def to_regexp
			@regex = Regexp.new(text).freeze
		end
		
		def to_s(options = {})
			text
		end
		
		def inspect
			"<#{self.class} text=#{text.inspect}>"
		end		
		
		def eql?(o)
			o.is_a?(StepItem) && self.text == o.text
		end
		
		def hash
			text.hash
		end
		
	end
	
	class StepVariable < StepItem
		ARG_TEXT_REGEX = /\(.*?[^\\]\)/
		
		attr_reader :name
		
		def initialize(text, name)
			super(text)
			@name = name.freeze
			
			raise "#{@text.inspect} is not a variable!" unless @text =~ ARG_TEXT_REGEX
			@easy = $` + "<" + @name + ">" + $'
			@easy.freeze
		end	
		
		def to_s(options = {})
			options[:easy] ? @easy  : super()
		end
		
		def inspect
			"<#{self.class} text=#{text.inspect} name=#{name.inspect}>"
		end
	end
	
	
	class Matcher
		
		STEP_REGEX = /^\s*(Given|Then|When)\s*\(?\s*\/\^?(.*)\/\s*\)?\s*(?:do|\{)\s*(\|[^\|]+\|)?/.freeze
		ARG_NAMES_REGEX = /\|(.*)\|/
		ARG_TEXT_REGEX = /\S*\(.*?[^\\]\)\S*/
		
		attr_reader :match_table
		
		def initialize
			@match_table = Possible.new
		end
		
		def <<(value)
			raise "#{value.inspect} is not a step" unless value =~ STEP_REGEX
			
			full_line = $&
			step_type = $1
			regex = $2.chomp("$")
			args = $3
			
			arg_names = (args =~ ARG_NAMES_REGEX) ? $1.split(',') : []
			arg_regexs = regex.chomp("$").scan(ARG_TEXT_REGEX)
			
			arg_objects = arg_regexs.zip(arg_names).collect { |x| StepVariable.new(*x) }
			
			elements = if arg_regexs.length > 0
				regex.split(Regexp.union(arg_regexs.collect { |x|
					Regexp.new(Regexp.escape(x))
				})).collect { |x|
					x.split.collect { |i| StepItem.new(i) }
				}.zip(arg_objects).flatten.compact.unshift(StepItem.new(step_type))	
			else
				regex.split.unshift(step_type).collect { |i| StepItem.new(i) }
			end
			
			elements.inject(@match_table) { |parent, i| parent[i] ||= Possible.new }.terminal!(full_line)			
		end
		
		def complete(string, options = {})
			possible_strings find_possible(string), options
		end
		
		def match?(string)
			return find_possible(string).terminal?
		end
			
	private

		def find_possible(input, against = @match_table, matched = [])
			items = input.is_a?(String) ? input.split : input
			while(i = items.shift)
				matches = against.keys.select{ |x| x.to_regexp.match(i) }
				case matches.length
					when 0 then return Possible::EMPTY
					when 1 then 
						matched << matches.first
						against = against[matches.first]
					else
						return matches.collect { |child_set| find_possible(items.dup, against[child_set], matched + [child_set]) }
				end
			end
			return against
		end
		
		def possible_strings(hash, options={}, so_far = [], collection = [])
			hash.each do |k,v|
				str = k.to_s(options)

				here = (so_far + [str])
				
				collection << here.join(" ") if v.terminal?
				possible_strings(v, options, here, collection)
			end
			collection
		end
	end
end
