class Agency < ActiveRecord::Base
  attr_accessible :name

  has_many :account_groups

  attr_accessible :logo

  has_attached_file :logo, :styles => {
    :medium => "300x300>",
    :footer => "150x50>"
  },
    :default_url => "/logos/:style/missing.png"
end
