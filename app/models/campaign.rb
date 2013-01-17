class Campaign < ActiveRecord::Base
  attr_accessible :account_group_id, :account_id, :name

  has_many :ad_groups
  has_many :domain_stats
  has_many :keyword_stats
  has_many :ad_stats

  belongs_to :account
  belongs_to :account_group
end
