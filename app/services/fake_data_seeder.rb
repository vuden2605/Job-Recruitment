class FakeDataSeeder
  TITLE_SUFFIXES = ['', ' Senior', ' Junior', ' (Urgent)'].freeze

  def self.call(count: 50)
    new(count:).call
  end

  def initialize(count:)
    @count = count
  end

  def call
    @crawl_log = CrawlLog.create!(
      status:       :running,
      started_at:   Time.current,
      triggered_by: self.class.name
    )

    validate_master_data!
    bulk_seed_jobs

    finish_success
    summary
  rescue StandardError => e
    finish_with_error(e)
    raise
  end

  private

  def fake_data
    @fake_data ||= YAML.load_file(
      Rails.root.join('config/data/fake_data.yml')
    )
  end

  def location_ids
    @location_ids ||= Location.pluck(:id)
  end

  def categories
    @categories ||= Category.select(:id, :name).to_a
  end

  def validate_master_data!
    raise 'Locations are empty. Run: rails db:seed:master_data' if location_ids.empty?
    raise 'Categories are empty. Run: rails db:seed:master_data' if categories.empty?
  end

  def bulk_seed_jobs
    @companies = preload_companies
    jobs      = build_jobs(@companies)

    ActiveRecord::Base.transaction do
      Job.import!(jobs)
      attach_categories_bulk(Job.last(@count))
      @crawl_log.update!(jobs_created: jobs.size)
    end
  end

  def preload_companies
    names    = Array.new(@count) { random_company_name }
    existing = Company.where(name: names.uniq).index_by(&:name)

    new_names     = names.uniq - existing.keys
    new_companies = new_names.map { |name| Company.create!(name: name) }

    existing.merge(new_companies.index_by(&:name))
  end

  def build_jobs(companies_by_name)
    Array.new(@count) do
      title   = random_title
      company = companies_by_name.values.sample

      Job.new(
        title:        title,
        company:      company,
        location_id:  location_ids.sample,
        salary:       fake_data['salary_ranges'].sample,
        description:  fake_description(title),
        requirements: fake_requirements,
        source_url:   fake_source_url(title),
        source_id:    SecureRandom.hex(4),
        posted_date:  rand(30).days.ago.to_date,
        expired_date: rand(15..60).days.from_now.to_date,
        status:       :active,
        job_type:     fake_data['job_types'].sample
      )
    end
  end

  def attach_categories_bulk(jobs)
    job_categories = jobs.flat_map do |job|
      categories.sample(rand(1..3)).map do |cat|
        JobCategory.new(job:, category: cat)
      end
    end

    JobCategory.import!(job_categories)
  end

  def random_company_name
    [
      fake_data['company_prefixes'].sample,
      fake_data['company_names'].sample,
      fake_data['company_suffixes'].sample
    ].join(' ')
  end

  def random_title
    base   = fake_data['job_titles'].sample
    suffix = TITLE_SUFFIXES.sample
    "#{base}#{suffix}"
  end

  def fake_description(title)
    template = fake_data['description_templates'].sample
    category = categories.sample.name
    format(template, title, category)
  end

  def fake_requirements
    template = fake_data['requirement_templates'].sample
    format(template, rand(1..5))
  end

  def fake_source_url(title)
    slug = title.downcase
                .gsub(/[àáạảãâầấậẩẫăằắặẳẵ]/, 'a')
                .gsub(/[èéẹẻẽêềếệểễ]/, 'e')
                .gsub(/[ìíịỉĩ]/, 'i')
                .gsub(/[òóọỏõôồốộổỗơờớợởỡ]/, 'o')
                .gsub(/[ùúụủũưừứựửữ]/, 'u')
                .gsub(/[ỳýỵỷỹ]/, 'y')
                .gsub(/đ/, 'd')
                .gsub(/[^a-z0-9\s-]/, '')
                .gsub(/\s+/, '-')
                .squeeze('-')
                .strip

    "https://www.careerlink.vn/tim-viec-lam/#{slug}/#{rand(1_000_000..9_999_999)}"
  end

  def finish_success
    @crawl_log.update!(
      status:      :success,
      finished_at: Time.current
    )
  end

  def finish_with_error(error)
    @crawl_log&.update!(
      status:        :failed,
      finished_at:   Time.current,
      error_message: "#{error.class}: #{error.message}\n#{error.backtrace&.first(5)&.join("\n")}"
    )
  end

  def summary
    result = {
      jobs:       @crawl_log.jobs_created,
      crawl_log:  @crawl_log.id
    }
    Rails.logger.info("[FakeDataSeeder] Done — #{result}")
    result
  end
end
