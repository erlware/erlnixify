require "erlnixify"

Before do
end

After do
end

Given(/^a settings file$/) do
  file = File.dirname(__FILE__) + '/../test_data/settings_config.yml'
  @opts = Erlnixify::Opts.new(["--config", file])
end

When(/^I load that settings file$/) do
  @settings = Erlnixify::Settings.new(@opts)
end

Then(/^the settings should be available in the settings object$/) do
  assert_equal 60, @settings[:startuptimeout]
  assert_equal "/some/place", @settings[:release]
  assert_equal "/some/root/file", @settings[:erlang]
  assert_equal "mynode", @settings[:name]
  assert_equal "sleep 10", @settings[:command]
  assert_equal "testcookie!", @settings[:cookie]
  assert_equal 30, @settings[:checkinterval]
end

Given(/^an options object that contains config values$/) do
  file = File.dirname(__FILE__) + '/../test_data/settings_config.yml'
  @opts = Erlnixify::Opts.new(["--config", file,
                               "--checkinterval", "100",
                               "--startuptimeout", "500",
                               "--cookie", "fubachu"])
end

When(/^a new settings file is loaded up using that options$/) do
  @settings = Erlnixify::Settings.new(@opts)
end

Then(/^the command line options override the file options$/) do
  assert_equal 500, @settings[:startuptimeout]
  assert_equal "/some/place", @settings[:release]
  assert_equal "/some/root/file", @settings[:erlang]
  assert_equal "mynode", @settings[:name]
  assert_equal "sleep 10", @settings[:command]
  assert_equal "fubachu", @settings[:cookie]
  assert_equal 100, @settings[:checkinterval]
end


Given(/^a lack of a config file and command line options$/) do
  @opts = Erlnixify::Opts.new([])
end

When(/^a settings are loaded$/) do
  @settings = Erlnixify::Settings.new(@opts)
end

Then(/^that settings object contains sane defaults$/) do
  assert_equal 60, @settings[:startuptimeout]
  assert_equal ENV["HOME"], @settings[:home]
  assert_equal 30, @settings[:checkinterval]
end
