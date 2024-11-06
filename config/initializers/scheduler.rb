require 'rufus-scheduler'

# Only run the scheduler in development or when the app is specifically configured to
if Rails.env.development? || ENV['ENABLE_RUFUS_SCHEDULER'] == 'true'
  scheduler = Rufus::Scheduler.singleton

  # Schedule the task to run every week
  scheduler.cron '0 2 * * 0' do
    Rails.logger.info "Running weekly box office update for the current year"
    Rake::Task['box_office:update_current_year_data'].invoke
    Rails.logger.info "Finished running weekly box office update for the current year"
  end
end
