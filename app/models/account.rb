class Account < ActiveRecord::Base
  attr_accessible :name, :vendor, :account_group_id

  belongs_to :account_group
  has_many :campaigns
  has_many :ad_groups
  has_many :ads
  has_many :keyword_stats
  has_many :domain_stats
  has_many :ad_stats

  default_scope order("name ASC")
  scope :google, where(vendor: "Google")
  scope :bing, where(vendor: "Bing")
  scope :unlinked, where(account_group_id: nil).google

  after_save :update_account_group_for_sub_models

  def self.for_group_select(account_group, vendor)
    where(account_group_id: [nil, account_group.id]).where(vendor: vendor).order("id ASC").collect{|x| [x.name, x.id]}
  end

  def update_account_group_for_sub_models
    id = self.account_group_id
    self.campaigns.update_all(account_group_id: id)
    self.ad_groups.update_all(account_group_id: id)
    self.ads.update_all(account_group_id: id)
    self.ad_stats.update_all(account_group_id: id)
    self.keyword_stats.update_all(account_group_id: id)
    self.domain_stats.update_all(account_group_id: id)
  end
end
