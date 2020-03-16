# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
require_relative 'config/application'

Rails.application.load_tasks
if Rails.env.test? || Rails.env.development?
  require 'rspec/core/rake_task'

  task :js_tests do
    sh 'yarn test'
  end

  task :rubocop do
    sh 'rubocop --fail-level convention'
  end

  task :rubycritic do
    sh 'rubycritic'
  end

  task :eslint do
    sh 'yarn run eslint'
  end

  # from https://github.com/thoughtbot/factory_bot/blob/master/GETTING_STARTED.md#linting-factories
  desc 'Verify that all FactoryBot factories are valid'
  task factory_bot_lint: :environment do
    if Rails.env.test?
      conn = ActiveRecord::Base.connection
      conn.transaction do
        FactoryBot.lint
        raise ActiveRecord::Rollback
      end
    else
      system("bundle exec rake factory_bot_lint RAILS_ENV='test'")
      fail if $?.exitstatus.nonzero?
    end
  end

  task :yarn_audit do
    sh 'yarn audit'
  end

  task :bundler_audit do
    sh 'bundle audit --update'
  end

  task default: [
    :spec,
    :js_tests,
    :rubocop,
    :rubycritic,
    :eslint,
    :factory_bot_lint,
    :yarn_audit,
    :bundler_audit
  ]
  task ci: [:default]
end
