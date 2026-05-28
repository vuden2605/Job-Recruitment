# frozen_string_literal: true

# Generates realistic fake job data for development/testing.
# Usage:
#   FakeDataSeeder.call                 # seed 50 jobs (default)
#   FakeDataSeeder.call(count: 20)      # seed 20 jobs
#   FakeDataSeeder.call(clear: true)    # wipe existing data first

class FakeDataSeeder
  # ── Master data pools ──────────────────────────────────────────────

  def locations_data
    YAML.load_file(Rails.root.join('config/data/locations.yml'))['locations']
  end

  def categories_data
    YAML.load_file(Rails.root.join('config/data/categories.yml'))['categories']
  end

  COMPANY_SUFFIXES = [
    'Việt Nam', 'VN', 'Asia', 'Global', 'Group', 'Corporation', 'Solutions'
  ].freeze

  COMPANY_PREFIXES = [
    'Công ty TNHH', 'Công ty Cổ phần', 'Tập đoàn', 'Công ty TNHH MTV'
  ].freeze

  COMPANY_NAMES = [
    'Tech Innovations', 'Digital Works', 'Smart Solutions', 'Future Systems',
    'Alpha Technology', 'Viet Finance', 'Sky Logistics', 'Green Energy',
    'Blue Ocean Media', 'Prime Consulting', 'Golden Gate Trading',
    'Sunrise Manufacturing', 'Pacific Services', 'Red Dragon Holdings'
  ].freeze

  JOB_TITLES = [
    'Nhân Viên Kế Toán', 'Lập Trình Viên Backend', 'Lập Trình Viên Frontend',
    'Kỹ Sư DevOps', 'Nhân Viên Kinh Doanh', 'Chuyên Viên Marketing',
    'Nhân Viên Nhân Sự', 'Kế Toán Trưởng', 'Giám Sát Bán Hàng',
    'Nhân Viên Xuất Nhập Khẩu', 'Kỹ Sư Phần Mềm', 'Product Manager',
    'Business Analyst', 'Data Analyst', 'UX/UI Designer',
    'Chuyên Viên Tuyển Dụng', 'Trưởng Phòng Kỹ Thuật',
    'Nhân Viên Hành Chính', 'Chuyên Viên Tài Chính', 'QA Engineer'
  ].freeze

  SALARY_RANGES = [
    'Thương lượng', 'Cạnh tranh',
    '5 triệu - 8 triệu', '7 triệu - 10 triệu', '8 triệu - 12 triệu',
    '10 triệu - 15 triệu', '12 triệu - 18 triệu', '15 triệu - 25 triệu',
    '20 triệu - 35 triệu', 'Trên 30 triệu'
  ].freeze

  JOB_TYPES = ['Toàn thời gian', 'Bán thời gian', 'Remote', 'Hybrid'].freeze

  DESCRIPTION_TEMPLATES = [
    'Chúng tôi đang tìm kiếm ứng viên năng động cho vị trí %s. ' \
    'Bạn sẽ làm việc trong môi trường chuyên nghiệp, có cơ hội học hỏi và phát triển. ' \
    'Công ty cung cấp chế độ đãi ngộ cạnh tranh và môi trường làm việc thân thiện.',

    'Công ty chúng tôi đang mở rộng đội ngũ và cần tuyển %s tài năng. ' \
    'Đây là cơ hội tuyệt vời để phát triển sự nghiệp trong lĩnh vực %s. ' \
    'Ứng viên sẽ được hưởng nhiều phúc lợi hấp dẫn.',

    'Vị trí %s sẽ chịu trách nhiệm triển khai và phát triển các dự án quan trọng. ' \
    'Bạn sẽ làm việc trực tiếp với đội ngũ chuyên nghiệp và có kinh nghiệm. ' \
    'Môi trường làm việc năng động, sáng tạo và nhiều cơ hội thăng tiến.'
  ].freeze

  REQUIREMENT_TEMPLATES = [
    "- Tốt nghiệp Đại học chuyên ngành liên quan\n" \
    "- Kinh nghiệm %d năm ở vị trí tương đương\n" \
    "- Kỹ năng giao tiếp tốt, làm việc nhóm hiệu quả\n" \
    "- Có khả năng làm việc dưới áp lực cao\n" \
    '- Tiếng Anh giao tiếp được là lợi thế',

    "- Có ít nhất %d năm kinh nghiệm làm việc trong lĩnh vực liên quan\n" \
    "- Tư duy phân tích tốt, chú ý đến chi tiết\n" \
    "- Kỹ năng sử dụng MS Office thành thạo\n" \
    "- Trung thực, trách nhiệm và chăm chỉ\n" \
    '- Ưu tiên ứng viên có kinh nghiệm tại công ty nước ngoài'
  ].freeze

  # ── Entry point ────────────────────────────────────────────────────

  def self.call(count: 50, clear: false)
    new(count:, clear:).call
  end

  def initialize(count:, clear:)
    @count      = count
    @clear      = clear
    @jobs_created = 0
    @jobs_skipped = 0
  end

  def call
    @crawl_log = CrawlLog.create!(
      status:       :running,
      started_at:   Time.current,
      triggered_by: self.class.name
    )

    clear_data! if @clear
    seed_master_data
    seed_jobs

    finish_success
    summary
  rescue StandardError => e
    finish_with_error(e)
    raise
  end

  private

  # ── Seed helpers ───────────────────────────────────────────────────

  def seed_master_data
    locations_data.each  { |name| Location.find_or_create_by!(name:) }
    categories_data.each { |name| Category.find_or_create_by!(name:) }
  end

  def seed_jobs
    @count.times { create_fake_job }
  end

  def create_fake_job
    company  = find_or_create_company
    location = Location.order('RAND()').first
    title    = random_title

    job = Job.find_or_initialize_by(
      source_url: fake_source_url(title)
    )

    job.assign_attributes(
      title:        title,
      company:      company,
      location:     location,
      salary:       SALARY_RANGES.sample,
      description:  fake_description(title),
      requirements: fake_requirements,
      source_id:    SecureRandom.hex(4),
      posted_date:  rand(30).days.ago.to_date,
      expired_date: rand(15..60).days.from_now.to_date,
      status:       :active,
      job_type:     JOB_TYPES.sample
    )

    if job.save
      attach_random_categories(job)
      @jobs_created += 1
      @crawl_log.increment!(:jobs_created)
    else
      @jobs_skipped += 1
      @crawl_log.increment!(:jobs_skipped)
    end

    job
  end

  def find_or_create_company
    name = "#{COMPANY_PREFIXES.sample} #{COMPANY_NAMES.sample} #{COMPANY_SUFFIXES.sample}"
    Company.find_or_create_by!(name:)
  end

  def attach_random_categories(job)
    categories = Category.order('RAND()').limit(rand(1..3))
    categories.each do |cat|
      JobCategory.find_or_create_by!(job:, category: cat)
    end
  end

  # ── Fake field generators ──────────────────────────────────────────

  def random_title
    base = JOB_TITLES.sample
    suffixes = ['', ' (Urgent)', ' - Lương Cao', ' (HCM)', ' (HN)', ' Senior', ' Junior']
    "#{base}#{suffixes.sample}"
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

    id = rand(1_000_000..9_999_999)
    "https://www.careerlink.vn/tim-viec-lam/#{slug}/#{id}"
  end

  def fake_description(title)
    category = categories_data.sample
    template = DESCRIPTION_TEMPLATES.sample
    format(template, title, category)
  end

  def fake_requirements
    template = REQUIREMENT_TEMPLATES.sample
    format(template, rand(1..5))
  end

  # ── Cleanup & summary ──────────────────────────────────────────────

  def clear_data!
    [JobCategory, Job, Company, Location, Category].each(&:delete_all)
    Rails.logger.info('[FakeDataSeeder] Cleared all existing data')
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
      jobs:       Job.count,
      companies:  Company.count,
      locations:  Location.count,
      categories: Category.count,
      crawl_log:  @crawl_log.id
    }
    Rails.logger.info("[FakeDataSeeder] Done — #{result}")
    result
  end
end
