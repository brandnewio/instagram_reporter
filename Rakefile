require "bundler/gem_tasks"

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |task|
    #task.patterns = ['lib/**/*.rb']
    # only show the files with failures
    #task.formatters = ['files']
    # don't abort rake on failure
    task.fail_on_error = true
  end
end

