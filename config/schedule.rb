set :environment, ENV.fetch('RAILS_ENV', 'development')
set :output,      { error: 'log/cron_error.log', standard: 'log/cron.log' }

# Load rbenv environment cho cron
env :PATH, '/home/rail/.rbenv/shims:/home/rail/.rbenv/bin:/usr/local/bin:/usr/bin:/bin'
set :bundle_command, '/home/rail/.rbenv/shims/bundle exec'
set :job_template, "bash -l -c ':job'"

every 1.day, at: '00:00 am' do
  runner 'SeedJob.perform_now(count: 5)'
end
