module StepMaster
	class StepItem
		attr_reader :text, :options
		
		def initialize(text, opts)
			@text = text.freeze
			@options = 0
			@options |= (opts.match(/i/) ? Regexp::IGNORECASE : 0)
		end
		
		def to_regexp
			@regex = Regexp.new("^" << text, options).freeze
		end
		
		def to_s(options = {})
			text
		end
		
		def inspect
			text.inspect
		end		
		
		def eql?(o)
			o.is_a?(StepItem) && self.text.eql?(o.text)
		end
		
		def hash
			text.hash
		end		
	end
end