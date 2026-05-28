namespace :db do
  namespace :seed do
    desc 'Seed all master data (locations + categories)'
    task master_data: ['db:seed:master_data:locations', 'db:seed:master_data:categories']

    namespace :master_data do
      desc 'Seed locations from config/data/locations.yml'
      task locations: :environment do
        data = YAML.load_file(Rails.root.join('config/data/locations.yml'))['locations']

        counts = data.each_with_object(created: 0, skipped: 0) do |name, tally|
          if Location.find_or_create_by!(name:).previously_new_record?
            tally[:created] += 1
          else
            tally[:skipped] += 1
          end
        end

        puts "[seed:locations] created=#{counts[:created]} skipped=#{counts[:skipped]}"
      end

      desc 'Seed categories from config/data/categories.yml'
      task categories: :environment do
        data = YAML.load_file(Rails.root.join('config/data/categories.yml'))['categories']

        counts = data.each_with_object(created: 0, skipped: 0) do |name, tally|
          if Category.find_or_create_by!(name:).previously_new_record?
            tally[:created] += 1
          else
            tally[:skipped] += 1
          end
        end

        puts "[seed:categories] created=#{counts[:created]} skipped=#{counts[:skipped]}"
      end
    end
  end
end
