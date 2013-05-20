require "bundler/gem_tasks"
require "reek/rake/task"
require 'cucumber'
require 'cucumber/rake/task'

task :default => :quality

Reek::Rake::Task.new do |t|
  t.fail_on_error = true
  t.reek_opts = "-c ./reek.yml"
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "features --format pretty"
end

task :console do
  exec 'irb -I lib -r startingscript.rb'
end

task :quality => [:reek, :features] do
end
