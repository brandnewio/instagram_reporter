def disable_rspec_warning
  old = RSpec::Expectations.configuration.on_potential_false_positives
  begin
    RSpec::Expectations.configuration.on_potential_false_positives = :nothing
    yield
  ensure
    RSpec::Expectations.configuration.on_potential_false_positives = old
  end
end
