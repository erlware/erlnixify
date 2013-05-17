require "erlnixify/version"
require "erlnixify/opts"
require "erlnixify/settings"
require "erlnixify/node"

module Erlnixify

  def main(args)
    @opts = Opts.new(args)

    if opts.version?
      puts Erlnixify::VERSION
      exit 0
    end

    @settings = Settings.new(opts)
    @process = Process.new(@settings)
    begin
      @process.start
    rescue Erlnixify::NodeError
      exit 127
    end
  end
end
