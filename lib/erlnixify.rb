require "erlnixify/version"
require "erlnixify/opts"
require "erlnixify/settings"
require "erlnixify/node"

module Erlnixify

  # The main entry point for erlnixify
  class Main
    def self.main(args)
      @opts = Erlnixify::Opts.new(args)

      if @opts.opts.version?
        puts Erlnixify::VERSION
        exit 0
      end

      if not @opts.opts.command?
        puts "missing command option, this is required"
        puts @opts.opts.help
        exit 1
      end

      if not @opts.opts.name?
        puts "missing name option"
        puts @opts.opts.help
        exit 1
      end

      if not (@opts.opts.cookie? || @opts.opts.cookiefile?)
        puts "missing both cookie and cookiefile options, at least one is required"
        puts @opts.opts.help
        exit 1
      end

      @settings = Erlnixify::Settings.new(@opts)
      @process = Erlnixify::Node.new(@settings)
      begin
        @process.start
      rescue Erlnixify::NodeError
        exit 127
      end
    end
  end
end
