

Given(/^a valid configuration$/) do
  hostname = `hostname -f`.strip
  @opts = Erlnixify::Opts.new(["--cookie", "fubachu",
                               "--startuptimeout", "10",
                               "--checkinterval", "10",
                               "--name", "foo",
                               "--command", "erl -noshell -setcookie fubachu -name foo@#{hostname}"
                              ])
  @settings = Erlnixify::Settings.new(@opts)
end

Then(/^no errors or problems occur$/) do
  assert @node.is_running?
  @node.halt_nicely
  sleep @settings[:startuptimeout]
  assert (not @node.is_running?)
end

Given(/^the erlang node is started$/) do
  @node = Erlnixify::Node.new @settings
  Thread.new do
    begin
      @node.start
    rescue Erlnixify::NodeError => node_error
      @node_start_error = node_error
    rescue Exception => e
      assert_fail "Other exception should not occur #{e.message}"
    end
  end
  sleep (@settings[:startuptimeout] + 30)
end

When(/^the node is brought up$/) do
  assert @node.is_running?
end

Given(/^a valid configuration with invalid command$/) do
  hostname = `hostname -f`.strip
  @opts = Erlnixify::Opts.new(["--cookie", "fubachu",
                               "--startuptimeout", "10",
                               "--checkinterval", "10",
                               "--name", "foo",
                               "--command", "this should fail"
                              ])
  @settings = Erlnixify::Settings.new(@opts)
end

When(/^the node fails$/) do
  assert @node_start_error != nil, "An NodeError was expected to be thrown"
  assert @node.is_running? == false, "Node is still running"
end

Then(/^an exception occures$/) do
  assert @node_start_error != nil, "An NodeError was expected to be thrown"
end

Given(/^a valid configuration with invalid check command$/) do
  hostname = `hostname -f`.strip
  @opts = Erlnixify::Opts.new(["--cookie", "fubachu",
                               "--startuptimeout", "10",
                               "--checkinterval", "10",
                               "--name", "foo",
                               "--command", "erl -noshell -setcookie fubachu -name foo@#{hostname}",
                               "--check", "invalid check",

                              ])
  @settings = Erlnixify::Settings.new(@opts)
end

When(/^the check fails$/) do
  assert @node_start_error.message == "Node check failed"
end


When(/^the erlang node is halted$/) do
  assert false == @node.is_running?, "The node is running when it should not be"
end

Given(/^a valid configuration with a long running check comamnd$/) do
  check_time = 60 * 1000 # 60 seconds in milliseconds
  hostname = `hostname -f`.strip
  @opts = Erlnixify::Opts.new(["--cookie", "fubachu",
                               "--startuptimeout", "10",
                               "--checkinterval", "10",
                               "--name", "foo",
                               "--command", "erl -noshell -setcookie fubachu -name foo@#{hostname}",
                               "--check", "timer sleep [#{check_time}]",

                              ])
  @settings = Erlnixify::Settings.new(@opts)
end

When(/^the check command times out$/) do
  sleep 60 # should be a enough given the timeout

  assert @node_start_error.message == "Check command timeout occurred", "Timeout did not occur"
end

When(/^a term signal is recieved$/) do
  begin
    Process.kill("TERM", $$)
    assert_fail "Did not recieve error"
  rescue Erlnixify::NodeError => e
    assert e.message == "SIGTERM recieved, shutting down"
  end
end
