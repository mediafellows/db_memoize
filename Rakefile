require "rspec/core/rake_task"
require 'yaml'

RSpec::Core::RakeTask.new(:spec)

desc 'Create test DB needed to run rspec'
task 'db:test:create' do
  project_root = File.expand_path("../", __FILE__)
  db_config = YAML.load_file("#{project_root}/config/database.yml")

  db_host = db_config['host']
  db_name = db_config['database']
  db_user = db_config['username']
  db_password = db_config['password']

  Rake.sh "PGPASSWORD=#{db_password} dropdb #{db_name} -h #{db_host} -U #{db_user} -w || true"
  Rake.sh "PGPASSWORD=#{db_password} createdb #{db_name} -h #{db_host} -U #{db_user} -w"
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
