class AdGroup < ActiveRecord::Base
  attr_accessible :account_group_id, :account_id, :campaign_id, :name

  has_many :domain_stats
  has_many :keyword_stats
  has_many :ad_stats
  has_many :ads

  belongs_to :campaign
  belongs_to :account
  belongs_to :account_group
end
