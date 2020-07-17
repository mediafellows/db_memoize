require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task 'db:test:create' do
  db_password = ''

  if ENV['GITHUB_WORKFLOW']
    db_password = 'postgres'
  end

  Rake.sh "PGPASSWORD=#{db_password} dropdb db_memoize_test -h localhost -U postgres -w || true"
  Rake.sh "PGPASSWORD=#{db_password} createdb db_memoize_test -h localhost -U postgres -w"
end

task :default => %w(db:test:create spec)

desc "release a new development gem version"
task :release do
  sh "scripts/release.rb"
end

desc "release a new stable gem version"
task "release:stable" do
  sh "BRANCH=stable scripts/release.rb"
end
