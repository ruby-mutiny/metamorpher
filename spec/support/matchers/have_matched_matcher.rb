require "rspec/expectations"

RSpec::Matchers.define :have_matched do |expected_root|
  match do |actual|
    actual.matches? && (expected_root.nil? || actual.root == expected_root)
  end

  failure_message_for_should do |actual|
    if actual.matches?
      "expected a match against '#{expected_root.inspect}', " \
      "but got a match against '#{actual.root.inspect}'"
    else
      "expected a match, but got none"
    end
  end

  failure_message_for_should_not do |actual|
    if actual.matches?
      "expected no match, but got a match against #{actual.root.inspect}"
    end
  end
end
