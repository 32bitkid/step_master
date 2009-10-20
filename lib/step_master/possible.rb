module StepMaster
	class Possible < ::Hash
		EMPTY = Possible.new		
		
		attr_reader :file_path, :line_number
		
		def terminal!(result, options = {})
			@terminal = true
			@result = result
			@file_path = options[:file_path].freeze
			@line_number = options[:line_number].freeze
		end
		
		def terminal?
			@terminal
		end
		
		def result
			@result
		end
		
		def file
			if @file_path
				[@file_path, @line_number].compact.join(":")
			end
		end
	end
end