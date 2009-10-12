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
		
		describe "#match" do
			it "accepts a string" do
				@matcher.complete("Given")
			end
			
			it "should be able to match a simple step" do
				@matcher << VALID_STEP
				@matcher.complete("Given").should eql(["nothing"])
			end
			
			describe "two simple steps given" do
				before(:each) do 
					@matcher << "Given /^this$/ do"
					@matcher << "Given /^that$/ do"					
				end
				
				it "should return results when search for 'Given'" do
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
			
			describe "simple branching steps" do
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
			
			describe "a terminal and longer step" do
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
			
			describe "simple regex variables" do
				before :each do
					@matcher << 'Given /^I want \w{3}$/ do |something|'
				end	
				
				it "should auto complete" do
					@matcher.complete("Given").should have(1).result
				end
				
				it "should include \"Given I want pie\"" do
					@matcher.should include("Given I want pie")
				end
				
				it "should not include \"Given I want 123\"" do
					@matcher.should_not include("Given I want !@@")
				end				
				
				
			end
			
		end		
	end
end
