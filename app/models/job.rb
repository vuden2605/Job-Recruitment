class Job < ApplicationRecord
  belongs_to :company
  belongs_to :location
  has_many   :job_categories, dependent: :destroy
  has_many   :categories, through: :job_categories

  enum status: { active: 0, expired: 1, hidden: 2 }

  validates :title,      presence: true
  validates :source_url, presence: true, uniqueness: true
  validates :company,    presence: true
  validates :location,   presence: true
end
