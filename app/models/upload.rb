class Upload < ActiveRecord::Base
  attr_accessible :data, :upload_type, :processed_at

  def self.get_day date_string
    month = date_string.match(/Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec/i).to_s
    year = date_string.match(/20\d\d/).to_s
    Date.parse("#{month} 1, #{year}")
  end
end
