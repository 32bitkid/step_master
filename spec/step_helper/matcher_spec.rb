require File.join(File.dirname(__FILE__), "..", "spec_helper")

module StepSensor
	
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
		
		describe "#match?" do
			
			describe "with a terminal and longer step" do
				before :each do
					@matcher << "Given /^I want pie$/ do"
					@matcher << "Given /^I want pie in the morning$/ do"
				end
							
				it "should match to 'I want pie'" do
					@matcher.match?("Given I want pie").should be_true
				end
				
				it "should not match to 'I want pie in" do
					@matcher.match?("Given I want pie in").should be_false
				end

				it "should match to 'I want pie in the morning" do
					@matcher.match?("Given I want pie in the morning").should be_true
				end			
			end
			
			describe "with a simple regex variable" do
				before :each do
					@matcher << 'Given /^I want (\w{3})$/ do |something|'
				end	
				
				it "should match \"Given I want pie\"" do
					@matcher.match?("Given I want pie").should be_true
				end					
				
				it "should not match \"Given I want !@@\"" do
					@matcher.match?("Given I want !@@").should be_false
				end	
			end
			
			describe "with regex with quotes around it" do
				before :each do
					@matcher << 'Given /^I want "([^\"]*)"$/ do |something|'
				end	
				
				it "should match \"Given I want \"pie\"\"" do
					@matcher.match?("Given I want \"pie\"").should be_true
				end
				
				it "should match \"Given I want \"123\"\"" do
					@matcher.match?("Given I want \"!@@\"").should be_true
				end			
			end				
		end
		
		
		describe "#complete" do
			it "accepts a string" do
				@matcher.complete("Given")
			end
			
			it "should be able to match a simple step" do
				@matcher << VALID_STEP
				@matcher.complete("Given").should eql(["nothing"])
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
					@matcher.complete("Given").should include("this")
				end
				
				it "should return 'that' when search for 'Given'" do
					@matcher.complete("Given").should include("that")
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
					@matcher.complete("Given").should include("I want pie")
				end
				
				it "should include 'I want cake' when searched for 'Given'" do
					@matcher.complete("Given").should include("I want cake")
				end				
				
				it "should include 'I can swim' when searched for 'Given'" do
					@matcher.complete("Given").should include("I can swim")
				end
				
				it "should return 2 results when search for 'Given I want'" do
					@matcher.complete("Given I want").should have(2).results
				end
				
				it "should include 'pie' when searched for 'Given'" do
					@matcher.complete("Given I want").should include("pie")
				end
				
				it "should include 'cake' when searched for 'Given'" do
					@matcher.complete("Given I want").should include("cake")
				end						
				
				it "should return 1 result when search for 'Given I can'" do
					@matcher.complete("Given I can").should have(1).results
				end												
				
				it "should include 'swim' when searched for 'Given'" do
					@matcher.complete("Given I can").should include("swim")
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
					@matcher.complete("Given").should include("I want pie")
				end
				
				it "should include 'I want pie in the morning'" do
					@matcher.complete("Given").should include("I want pie in the morning")
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
					m.should include("I want <something>")
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
					m.should include("I want \"<something>\"")
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
					m.should include("I want \"<food>\" in the \"<time_of_day>\"")
				end		 
				
			end
			
			
			
		end		
	end
end
