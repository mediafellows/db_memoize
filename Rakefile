require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task 'db:test:create' do
  project_root = File.expand_path("../../", __FILE__)

  db_password = YAML.load_file("#{project_root}/config/database.yml")['password']
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
