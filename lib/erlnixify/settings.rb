require 'yaml'

module Erlnixify

  # Provides a library for settings to be accessed from accross the
  # system
  class Settings
    attr_accessor :settings
    attr_accessor :options

    STARTUP_TIMEOUT = 60
    CHECK_INTERVAL = 30
    CHECK_TIMEOUT = 30
    CHECK_COMMAND = "erlang statistics [reductions]"
    CHECK_REGEX = "^{\\d+, \\d+}$"

    def initialize(opts)
      @options = opts
      config = @options.options[:config]

      @settings = self.default_settings

      self.load! config if config
      self.merge(@options.options)
      self.post_settings_setup
    end

    def default_settings
      defaults = {release: nil,
        erlang: nil,
        home: ENV["HOME"],
        name: nil,
        fullnode: nil,
        command: nil,
        check: CHECK_COMMAND,
        checkregex: CHECK_REGEX,
        cookiefile: nil,
        cookie: nil,
        startuptimeout: STARTUP_TIMEOUT,
        checkinterval: CHECK_INTERVAL,
        checktimeout: CHECK_TIMEOUT,
        config: nil}
      defaults
    end

    def load!(filename, options = {})
      newsets = YAML::load_file(filename)

      env = options[:env].to_sym if options[:env]

      if env
        newsets = newsets[env] if newsets[env]
      end

      self.merge(newsets)
    end

    def [](key)
      return @settings[key]
    end

    def merge(data)
      @settings = @settings.inject({}) do |newhash, (key, value)|
        symkey = key.to_sym
        data_value = data[symkey]
        data_value = data[key.to_s] unless data_value
        if data_value
          newhash[symkey] = data_value
        else
          newhash[symkey] = value
        end
        newhash
      end
    end

    def post_settings_setup
      @settings[:erlang] = self.find_erlang_root
      @settings[:cookie] = self.find_cookie
      @settings[:erl_interface] = self.find_erl_interface
      @settings[:fullnode] = self.find_full_node
    end

    def find_erlang_root
      if @settings[:erlang]
        @settings[:erlang]
      elsif File.directory? "/usr/local/lib/erlang"
        "/usr/local/lib/erlang"
      elsif File.directory? "/usr/lib/erlang"
        "/usr/lib/erlang"
      end
    end


    def find_cookie
      cookie_file = @settings[:cookiefile]
      if @settings[:cookie]
        @settings[:cookie]
      elsif cookie_file
        if File.exists? cookie_file
          IO.read cookie_file
        else
          raise RuntimeError, "Cookie file does not exist"
        end
      end
    end

    def find_full_node
      if @settings[:fullnode]
        @settings[:fullnode]
      else
        hostname = `hostname -f`.strip
        node = @settings[:name]
        "#{node}@#{hostname}"
      end
    end

    def find_erl_interface
      erlang_root = @settings[:erlang]
      release_root = @settings[:release]
      if erlang_root && (File.directory? erlang_root)
        Dir.glob("#{erlang_root}/lib/erl_interface-*").first
      elsif release_root && (File.directory? release_root)
        Dir.glob("#{release_root}/lib/erl_interface-*").first
      end
    end
  end
end
