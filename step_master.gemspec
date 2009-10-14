# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{step_master}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jim Holmes"]
  s.date = %q{2009-10-14}
  s.description = %q{Provide a simple and easy way to find and auto-complete gherkin steps, when writing cucumber features}
  s.email = ["32bitkid@gmail.com"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt", "PostInstall.txt"]
  s.files = ["History.txt", "Manifest.txt", "PostInstall.txt", "README.rdoc", "Rakefile", "lib/step_master.rb", "lib/step_master/matcher.rb", "lib/step_master/possible.rb", "lib/step_master/step_item.rb", "lib/step_master/step_variable.rb", "spec/spec_helper.rb", "spec/step_helper/matcher_spec.rb", "test/test_step_master.rb", "test/test_helper.rb"]
  s.homepage = %q{http://github.com/32bitkid/step_master}
  s.post_install_message = %q{PostInstall.txt}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{step_master}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{Provide a simple and easy way to find and auto-complete gherkin steps, when writing cucumber features}
  s.test_files = ["test/test_step_master.rb", "test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<hoe>, [">= 2.3.3"])
    else
      s.add_dependency(%q<hoe>, [">= 2.3.3"])
    end
  else
    s.add_dependency(%q<hoe>, [">= 2.3.3"])
  end
end
