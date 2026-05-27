class JobCategory < ApplicationRecord
  belongs_to :job
  belongs_to :category

  validates :job_id, presence: true
  validates :category_id, presence: true, uniqueness: { scope: :job_id }
end
