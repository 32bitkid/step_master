require File.join(File.dirname(__FILE__), "..", "spec_helper")

module StepMaster
	
	VALID_STEP = "Given /^nothing$/ do"
	
	describe Matcher do
		before(:each) do
			@matcher = Matcher.new			
		end
		
		describe "#<<" do
			it "accepts a string" do
				@matcher << VALID_STEP
			end
			
			it "not throw an exception when it recieves a valid step" do
				lambda {
					@matcher << VALID_STEP
				}.should_not raise_error(Exception)
			end		
			
			it "should not like a step it can't parse" do
				lambda {
					@matcher << "This is not a step"
				}.should raise_error(%q["This is not a step" is not a step])
			end
		end
		

		
		describe "#add()" do
			it "accepts a string" do
				@matcher.add(VALID_STEP)
			end
			
			it "should not like a step it can't parse" do
				lambda {
					@matcher.add "This is not a step"
				}.should raise_error(%q["This is not a step" is not a step])
			end			
			
			describe "accepts optional paramters" do
				it "should accept :file_path with just a file name" do
					@matcher.add(VALID_STEP, :file_path => "step.rb")
				end
				
				it "should accept :file_path an entire path" do
					@matcher.add(VALID_STEP, :file_path => "/src/project/step.rb")
				end
				
				it "should accept :file_path and :line_number" do
					@matcher.add(VALID_STEP, :file_path => "/src/project/step.rb", :line_number => 6)
				end
				
				it "should accept :format" do
					@matcher.add(VALID_STEP, :format => :rb)
				end				
			end
			
		end
				
		
		describe "#is_match?" do
			
			describe "with a terminal and longer step" do
				before :each do
					@matcher << "Given /^I want pie$/ do"
					@matcher << "Given /^I want pie in the morning$/ do"
				end
							
				it "should match to 'I want pie'" do
					@matcher.is_match?("Given I want pie").should be_true
				end
				
				it "should not match to 'I want pie in" do
					@matcher.is_match?("Given I want pie in").should be_false
				end

				it "should match to 'I want pie in the morning" do
					@matcher.is_match?("Given I want pie in the morning").should be_true
				end			
			end
			
			describe "with a simple regex variable" do
				before :each do
					@matcher << 'Given /^I want (\w{3})$/ do |something|'
				end	
				
				it "should match \"Given I want pie\"" do
					@matcher.is_match?("Given I want pie").should be_true
				end					
				
				it "should not match \"Given I want !@@\"" do
					@matcher.is_match?("Given I want !@@").should be_false
				end	
			end
			
			describe "with regex with quotes around it" do
				before :each do
					@matcher << 'Given /^I want "([^\"]*)"$/ do |something|'
				end	
				
				it "should match \"Given I want \"pie\"\"" do
					@matcher.is_match?("Given I want \"pie\"").should be_true
				end
				
				it "should match \"Given I want \"123\"\"" do
					@matcher.is_match?("Given I want \"!@@\"").should be_true
				end			
			end	

			describe "with step with a comment" do
				before :each do
					@matcher << %q~Given /^this$/i do |name| # This is a comment~
				end
				
				it "should correctly match" do
					@matcher.is_match?("Given this").should be_true
				end
			end
			
			describe "with a weird self-repeating step" do
				it "should correctly match" do
					@matcher << %q[Given /^I have a scheduled encounter ((?:\d+\s(?:weeks?|days?|minutes?|hours?|seconds|)(?:,\s?|\s?and\s?| ))+)(from now|ago)$/ do |time, from_now_or_ago| ]
					@matcher.is_match?("Given I have a scheduled encounter 3 weeks from now").should be_true
				end
				
				it "should correctly match with repeat" do
					@matcher << %q[Given /^I have a scheduled encounter ((?:\d+\s(?:weeks?|days?|minutes?|hours?|seconds|)(?:,\s?|\s?and\s?| ))+)(from now|ago)$/ do |time, from_now_or_ago| ]
					@matcher.is_match?("Given I have a scheduled encounter 3 weeks and 5 minutes from now").should be_true
				end				
				
			end
		end
		
		
		describe "#complete" do
			it "accepts a string" do
				@matcher.complete("Given")
			end
			
			it "should be able to match a simple step" do
				@matcher << VALID_STEP
				@matcher.complete("Given").should include(" nothing")
			end
			
			describe "with two simple steps given" do
				before(:each) do 
					@matcher << "Given /^this$/ do"
					@matcher << "Given /^that$/ do"					
				end
				
				it "should return 2 results when search for 'Given'" do
					@matcher.complete("Given").should have(2).results
				end
				
				it "should return 'this' when search for 'Given'" do
					@matcher.complete("Given").should include(" this")
				end
				
				it "should return 'that' when search for 'Given'" do
					@matcher.complete("Given").should include(" that")
				end
				
				it "should return no results when search for 'Given this'" do
					@matcher.complete("Given this").should have(0).results
				end
			end
			
			describe "with some simple branching steps" do
				before(:each) do
					@matcher << "Given /^I want pie$/ do"
					@matcher << "Given /^I want cake$/ do"		
					@matcher << "Given /^I can swim$/ do"		
				end
				
				it "should return 3 results when search for 'Given'" do
					@matcher.complete("Given").should have(3).results
				end
				
				it "should include 'I want pie' when searched for 'Given'" do
					@matcher.complete("Given").should include(" I want pie")
				end
				
				it "should include 'I want cake' when searched for 'Given'" do
					@matcher.complete("Given").should include(" I want cake")
				end				
				
				it "should include 'I can swim' when searched for 'Given'" do
					@matcher.complete("Given").should include(" I can swim")
				end
				
				it "should return 2 results when search for 'Given I want'" do
					@matcher.complete("Given I want").should have(2).results
				end
				
				it "should include 'pie' when searched for 'Given'" do
					@matcher.complete("Given I want").should include(" pie")
				end
				
				it "should include 'cake' when searched for 'Given'" do
					@matcher.complete("Given I want").should include(" cake")
				end						
				
				it "should return 1 result when search for 'Given I can'" do
					@matcher.complete("Given I can").should have(1).results
				end												
				
				it "should include 'swim' when searched for 'Given'" do
					@matcher.complete("Given I can").should include(" swim")
				end				
			end
			
			describe "with a terminal and longer step" do
				before :each do
					@matcher << "Given /^I want pie$/ do"
					@matcher << "Given /^I want pie in the morning$/ do"
				end
				
				it "should include 2 results when I search for 'Given'" do
					@matcher.complete('Given').should have(2).results
				end
				
				it "should include 'I want pie'" do
					@matcher.complete("Given").should include(" I want pie")
				end
				
				it "should include 'I want pie in the morning'" do
					@matcher.complete("Given").should include(" I want pie in the morning")
				end
			end
			
			describe "with a simple regex variable" do
				before :each do
					@matcher << 'Given /^I want (\w{3})$/ do |something|'
				end	
				
				it "should auto complete" do
					@matcher.complete("Given").should have(1).result
				end
				
				it "should complete with variables names " do
					m = @matcher.complete("Given", :easy => true)
					m.should have(1).result
					m.should include(" I want <something>")
				end				
			end
			
			describe "with regex with quotes around it" do
				before :each do
					@matcher << 'Given /^I want "([^\"]*)"$/ do |something|'
				end	
				
				it "should auto complete" do
					@matcher.complete("Given").should have(1).result
				end
				
				it "should complete with variables names " do
					m = @matcher.complete("Given", :easy => true)
					m.should have(1).result
					m.should include(" I want \"<something>\"")
				end				
			end

			describe "with more complex capture that could include spaces" do
				before :each do
					@matcher << 'Given /^I want "([^\"]*)" for dinner$/ do |something|'
				end	
				
				it "should handle more than one word inside quotes" do
					@matcher.complete("Given I want \"steak and potatoes\"").should have(1).result
				end
			end
			
			describe "with multiple arguments" do
				before :each do
					@matcher << 'Given /^I want "([^\"]*)" in the "([^\"]*)"$/ do |food, time_of_day|'
				end		
				
				it "should complete with variables names " do
					m = @matcher.complete("Given", :easy => true)
					m.should have(1).result
					m.should include(" I want \"<food>\" in the \"<time_of_day>\"")
				end		 
			end
			
			describe "with non captures" do
				
				it "should correctly match one variables name" do
					@matcher << %q[Given /^I want "(?:[^\"]*)" in the "([^\"]*)"$/ do |time_of_day|]
					m = @matcher.complete("Given", :easy => true)
					m.should have(1).result
					m.should include(%q[ I want "(?:[^\"]*)" in the "<time_of_day>"])
				end		 
				
				it "should correctly match two variables name" do
					@matcher << %q[Given /^I (\w{4}) "(?:[^\"]*)" in the "([^\"]*)"$/ do |type, time_of_day|]
					m = @matcher.complete("Given", :easy => true)
					m.should have(1).result
					m.should include(%q[ I <type> "(?:[^\"]*)" in the "<time_of_day>"])
				end		 
				
			end	

			describe "with an optional space" do
				before :each do
					@matcher << %q~Given /^(?:a )?provider ?location (?:named |called )?"([^\"]*)" exists$/i do |name|~
				end
				
				it "should correctly auto-complete" do 
					@matcher.complete("Given provider location").should have(1).result
					@matcher.complete("Given a provider location").should have(1).result
					@matcher.complete("Given providerlocation").should have(1).result
				end
			end
			
			describe "with an case insensitive switch" do
				before :each do
					@matcher << %q~Given /^(?:a )?provider ?location (?:named |called )?"([^\"]*)" exists$/i do |name|~
				end
				
				it "should correctly auto-complete" do 
					@matcher.complete("Given provider location").should have(1).result
					@matcher.complete("Given a Provider Location").should have(1).result
					@matcher.complete("Given ProviderLocation").should have(1).result
				end
			end
			
			describe "with an case insensitive switch" do
				before :each do
					@matcher << %q~Given /^(?:a )?provider ?location (?:named |called )?"([^\"]*)" exists$/i do |name|~
				end
				
				it "should correctly auto-complete" do 
					@matcher.complete("Given provider location").should have(1).result
					@matcher.complete("Given a Provider Location").should have(1).result
					@matcher.complete("Given ProviderLocation").should have(1).result
				end
			end
			
			
			
			describe "with step with a comment" do
				before :each do
					@matcher << %q~Given /^this$/i do |name| # This is a comment~
				end
				
				it "should correctly auto-complete" do 
					@matcher.complete("Given").should have(1).result
				end
			end	
			
		end		
		
		describe "#where_is?" do 
			describe "with step with a comment" do
				before :each do
					@matcher << %q~Given /^this$/i do # This is a comment~
				end
				
				it "should return the original line with where_is?" do
					@matcher.where_is?("Given this").should include(%q~Given /^this$/i do # This is a comment~)
				end
			end
			
			describe "with step with a file path" do
				before :each do
					@matcher.add(%q~Given /^this$/i do~, :file_path => "/src/test.rb")
				end
				
				it "should return the original line with where_is?" do
					@matcher.where_is?("Given this").should include(%q~/src/test.rb~)
				end
			end
			
			describe "with step with a file path and line_number" do
				before :each do
					@matcher.add(%q~Given /^this$/i do ~, :file_path => "/src/test.rb", :line_number => 6)
				end
				
				it "should return the original line with where_is?" do
					@matcher.where_is?("Given this").should include(%q~/src/test.rb:6~)
				end
			end			
			
		end
		
	end
	
	describe Matcher do
		describe "swith a pre-parsed match table" do
			
			before :each do
				p = Possible.new
				p[si = StepItem.new("Given")] = Possible.new
				p[si][si2 = StepItem.new(" ")] = Possible.new()
				(p[si][si2][StepItem.new("this")] = Possible.new()).terminal!("Given this")
				
				@matcher = Matcher.new(p)
			end
			
			it "should be able to perform a simple match" do
				@matcher.is_match?("Given this").should be_true
			end
		end
		
	end
	
end
