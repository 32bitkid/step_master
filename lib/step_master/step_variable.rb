require 'step_master/step_item'

module StepMaster
	class StepVariable < StepItem
		ARG_TEXT_REGEX = /\(.*?[^\\]\)/
		
		attr_reader :name
		
		def initialize(text, options, name)
			super(text, options)
			@name = name.freeze
			
			raise "#{@text.inspect} is not a variable!" unless @text =~ ARG_TEXT_REGEX
			@easy = @name.nil? ? @text : $` + "<" + @name + ">" + $'
				
			@easy.freeze
		end	
		
		def to_s(options = {})
			options[:easy] ? @easy  : super()
		end
		
		def inspect
			"#{text.inspect}:#{name.inspect}"
		end
	end
end