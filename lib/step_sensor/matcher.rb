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
	
	class Matcher
		
		STEP_REGEX = /^\s*(Given|Then|When)\s*\(?\s*\/\^?(.*)\/\s*\)?\s*(?:do|\{)\s*(\|[^\|]+\|)?/
		
		attr_reader :match_table
		
		def initialize
			@match_table = Possible.new
		end
		
		
		def <<(value)
			raise "#{value.inspect} is not a step" unless value =~ STEP_REGEX
			catalog $2.chomp("$").split.unshift($1), $&
		end
		
		def complete(string)
			possible_strings match(string)
		end
		
		def include?(string)
			return true
		end
			
	private

		def match(input, against = @match_table, matched = [])
			items = input.is_a?(String) ? input.split : input
			while(i = items.shift)
				matches = against.keys.select{ |x| Regexp.new(x).match(i) }
				case matches.length
					when 0 then return nil
					when 1 then 
						matched << matches.first
						against = against[matches.first]
					else
						return matches.collect { |child_set| match2(items.dup, against[child_set], matched + [child_set]) }
				end
			end
			return against
		end
		
		def possible_strings(hash, so_far = [], collection = [])
			return [] unless hash
			hash.each do |k,v|
				collection << (so_far + [k]).join(" ") if v.terminal?
				possible_strings(v, so_far + [k], collection) if v.length > 0
			end
			collection
		end

		def catalog(items, result)
			parent = nil
			items.inject(@match_table) { |parent, i| parent[i] ||= Possible.new }.terminal!(result)
		end
	end
end
