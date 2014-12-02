require "bundler/gem_tasks"
require "rspec/core/rake_task"

task default: ["test:unit", "test:integration", "style:check"]

namespace :test do
  RSpec::Core::RakeTask.new(:unit) do |task|
    task.pattern = "./spec/unit{,/*/**}/*_spec.rb"
  end

  RSpec::Core::RakeTask.new(:integration) do |task|
    task.pattern = "./spec/integration{,/*/**}/*_spec.rb"
  end
end

namespace :style do
  require "rubocop/rake_task"

  desc "Run RuboCop on the lib directory"
  RuboCop::RakeTask.new(:check) do |task|
    task.options = ["--auto-correct"]
  end
end
