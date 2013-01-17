class KeywordStat < ActiveRecord::Base
  attr_accessible :account_group_id, :account_id, :ad_group_id, :campaign_id, :click, :conversion, :cost, :impression, :name, :period, :position, :vendor

  belongs_to :ad_group
  belongs_to :campaign
  belongs_to :account
  belongs_to :account_group
end
