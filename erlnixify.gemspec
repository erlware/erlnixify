# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'erlnixify/version'

Gem::Specification.new do |spec|
  spec.name          = "erlnixify"
  spec.version       = Erlnixify::VERSION
  spec.authors       = ["Eric Merritt"]
  spec.email         = ["ericbmerritt@gmail.com"]
  spec.description   = %q{Erlnixify's purpose is to rectify a problem in Erlang. At the moment
 the Erlang VM has the problem that it can not react to unix
signals. This renders it impossible to integrate Erlang into a basic
unix environment like init.d or daemontools. This ruby project is
designed to fill that void. It provides a small unix executable whose
responsibility it is to capture normal unix signals and translate them
into something that the erlang vm can understand.
}
  spec.summary       = %q{An executable to help integrate Erlang Releases with unix sytems}
  spec.homepage      = ""
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "reek"
  spec.add_development_dependency "cane"
  spec.add_development_dependency "cucumber", "~> 1.3.1"

  spec.add_dependency "slop", "~> 3.4.4"
end
