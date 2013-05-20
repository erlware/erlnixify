require 'slop'

module Erlnixify

  # The Opts class provides options parsing support for erlnixify. It
  # is similar to settings with the exception that it is designed to
  # get its values from the command line.
  #
  class Opts

    attr_reader :options

    def initialize(args)
      opts = Slop.parse(args) do

        banner = "Usage: erlnixify [options]"

        on :b, :release=, 'Release Root Directory'
        on :e, :erlang=, 'Erlang Root Directory'
        on :o, :home=, "The home directory to explicitly set"
        on :n, :name=, "The short name of the node to be managed"
        on :fullnode=, "The fully qualified node name"
        on :m, :command=, "The command to run to start the release"
        on :k, :check=, "The command to check if the release is active"
        on :r, :checkregex=, "The regex that must match to the output of check command"
        on :x, :cookiefile=, "A file that contains the erlang cookie, not needed if cookie is set"
        on :i, :cookie=, "The cookie itself, not needed if cookie-file is set"
        on(:t, :startuptimeout=,
            "The amount of time to let the system startup in seconds",
            as: Integer)
        on(:a, :checkinterval=,
            "How often erlnixify should check to see if the system is still running",
            as: Integer)
        on(:w, :checktimeout=,
           "The longest time a check can run, defaults to 30 seconds",
           as: Integer)
        on :c, :config=, "A file that contains the YAML based config for this system"
        on :v, :version, "Show the Version"
      end

      @options = opts.to_hash
    end
  end

end
