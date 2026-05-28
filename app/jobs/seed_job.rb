class SeedJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.minutes, attempts: 2

  def perform(count: 50, clear: false)
    Rails.logger.info("[SeedJob] Starting — count=#{count}, clear=#{clear}")

    result = FakeDataSeeder.call(count:, clear:)

    Rails.logger.info("[SeedJob] Completed — #{result}")
  end
end
