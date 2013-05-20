require 'logger'
require 'erlnixify/exceptions'

module Erlnixify
  COMMAND_WRAPPER = "%{erl_interface}/bin/erl_call -n %{fullnode} \
-c '%{cookie}' -a '%{cmd}'"

  SHUTDOWN_COMMAND = "init stop"

  BRUTAL_SHUTDOWN_COMMAND = "erlang halt 127"

  # The process class owns the Running erlang process. It knows how to
  # query it if its active, and kill it if something goes long. This
  # class is the guts of erlnixify
  class Node
    def initialize(settings)
      @settings = settings
      @command = @settings[:command] % settings.settings
      @check_command = self.interpolate_cmd(@settings[:check])
      @halt_command = self.interpolate_cmd(SHUTDOWN_COMMAND)
      @brutal_halt_command = self.interpolate_cmd(BRUTAL_SHUTDOWN_COMMAND)
      @checkregex = Regexp.new @settings[:checkregex]

      @log = Logger.new(STDOUT)
      @log.level = Logger::DEBUG

      Signal.trap("TERM") do
        self.halt_nicely
        raise NodeError, "SIGTERM recieved, shutting down"
      end

      Signal.trap("INT") do
        self.halt_nicely
        raise NodeError, "SIGINT recieved, shutting down"
      end

      at_exit { self.external_kill }
    end

    def start
      @log.debug "starting process"
      env = {}
      env["HOME"] = @settings[:home] if @settings[:home]

      begin
        @log.debug "spawning command '#{@command}' with #{env}"
        @pid = Process.spawn(env, @command)
      rescue Errno::ENOENT
        @log.debug "Invalid command provided, raising error"
        raise NodeError, "Command does not exist"
      end

      @log.debug "waiting for #{@settings[:startuptimeout]} seconds for startup"
      sleep @settings[:startuptimeout]
      self.monitor
    end

    def monitor
      @log.debug "starting monitor of Pid #{@pid}"
      loop do
        if is_running?
          self.check
          sleep @settings[:checkinterval]
        else
          raise NodeError, "Node not running"
        end
        break if @stop
        @log.debug "Node responded correctly, continuing check"
      end
    end

    def check
      begin
        Timeout.timeout(@settings[:checktimeout]) do
          self.raw_check
        end
      rescue Timeout::Error
        self.halt_nicely
        raise NodeError, "Check command timeout occurred"
      end
    end

    def raw_check
      @log.debug "Checking the status of Pid #{@pid}"
      @log.debug "#{@check_command} =~ #{@checkregex}"
      result = `#{@check_command}`
      @log.debug "got #{result}"
      if not (result =~ @checkregex)
        @log.debug "Check failed, halting system"
        self.halt_nicely
        raise NodeError, "Node check failed"
      end
    end

    def is_running?
      @log.debug "Checking if Pid (#{@pid}) is running"
      if @pid
        begin
          Process.getpgid(@pid)
          true
        rescue Errno::ESRCH
          false
        end
      else
        false
      end
    end

    def halt_nicely
      `#{@halt_command}`
      sleep @settings[:checkinterval]
      if self.is_running?
        self.halt_brutally
      end
    end

    def halt_brutally
      `#{@brutal_halt_command}`
      sleep @settings[:checkinterval]
      if self.is_running?
        self.external_kill
      end
    end

    def external_kill
      Process.kill("KILL", @pid) if @pid
    end

    def interpolate_cmd(cmd)
      local_settings = @settings.settings.clone
      local_settings[:cmd] = cmd % local_settings
      COMMAND_WRAPPER % local_settings
    end
  end
end
