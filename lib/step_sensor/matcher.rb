module StepSensor
	
	class Possible < ::Hash
		def terminal!(result)
			@terminal = result
		end
		
		def terminal?
			!@terminal.nil?
		end
		
		def result
			@terminal
		end
		
		def inspect
			super << "#{terminal? ? "["+result+"]" : "="}"
		end
	end
	
	class StepItem
		attr_reader :text
		
		def initialize(text)
			@text = text
		end
		
		def to_regex
			@regex = Regexp.new(text)
		end
		
		def to_s
			text
		end
		
		def inspect
			"<#{self.class} text=#{text.inspect}>"
		end		
	end
	
	class StepVariable < StepItem
		attr_reader :name
		def initialize(text, name)
			@text = text
			@name = name
		end	
		
		def to_s(type = :normal)
			type == :normal ? super() : "<" << name << ">"
		end
		
		def inspect
			"<#{self.class} text=#{text.inspect} name=#{name.inspect}>"
		end
	end
	
	
	class Matcher
		
		STEP_REGEX = /^\s*(Given|Then|When)\s*\(?\s*\/\^?(.*)\/\s*\)?\s*(?:do|\{)\s*(\|[^\|]+\|)?/
		
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
			
			arg_names = (args =~ /\|(.*)\|/) ? $1.split(',') : []
			arg_regexs = regex.chomp("$").scan(/\S*\(.*?[^\\]\)\S*/)
			
			arg_objects = arg_regexs.zip(arg_names).collect { |x| StepVariable.new(*x) }
			
			elements = if arg_regexs.length > 0
				regex.split(Regexp.union(arg_regexs.collect { |x|
					Regexp.new(Regexp.escape(x))
				})).collect { |x|
					x.split
				}.zip(arg_objects).flatten.compact.unshift(step_type)	
			else
				regex.split.unshift(step_type)
			end
			
			p elements
			
			catalog elements, arg_names, full_line
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
				matches = against.keys.select{ |x| Regexp.new(x.to_s).match(i) }
				case matches.length
					when 0 then return Possible.new
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
				str = if options[:easy] and k.is_a? StepVariable
					k.to_s(:name)
				else
					k.to_s
				end
				
				here = (so_far + [str])
				
				collection << here.join(" ") if v.terminal?
				possible_strings(v, options, here, collection) if v.length > 0
			end
			collection
		end

		def catalog(items, args, result)
			items.inject(@match_table) { |parent, i| parent[i] ||= Possible.new }.terminal!(result)
		end
	end
end
