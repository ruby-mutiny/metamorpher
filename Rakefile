require "bundler/gem_tasks"
require "rspec/core/rake_task"

task default: ["test:unit", "style:check"]

namespace :test do
  RSpec::Core::RakeTask.new(:unit)
end

namespace :style do
  require "rubocop/rake_task"

  desc "Run RuboCop on the lib directory"
  Rubocop::RakeTask.new(:check) do |task|
    task.options = ["--auto-correct"]
  end
end
