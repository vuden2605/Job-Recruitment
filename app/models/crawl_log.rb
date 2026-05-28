class CrawlLog < ApplicationRecord
  enum status: { pending: 0, running: 1, success: 2, failed: 3 }

  validates :status, presence: true
end
