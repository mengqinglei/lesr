class Upload < ActiveRecord::Base
  attr_accessible :data, :upload_type, :processed_at
end
