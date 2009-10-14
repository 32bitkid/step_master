module StepMaster
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
			super << ((terminal? )? "["+result+"]" : "")
		end
	end
end