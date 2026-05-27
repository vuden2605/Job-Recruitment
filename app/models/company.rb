class Company < ApplicationRecord
  has_many :jobs, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, if: -> { name.present? && slug.blank? }

  def to_param
    slug
  end

  private

  def generate_slug
    self.slug ||= name.parameterize
  end
end
