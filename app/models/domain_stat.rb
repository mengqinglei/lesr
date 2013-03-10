class DomainStat < ActiveRecord::Base
  attr_accessible :account_group_id, :account_id, :ad_group_id, :campaign_id, :click, :conversion, :cost, :impression, :name, :period, :type, :upload_id

  belongs_to :ad_group
  belongs_to :campaign
  belongs_to :account
  belongs_to :account_group

  def self.content_targeting_data(account_group_id, month)
    lines = where(account_group_id: account_group_id, period: month).select("name, sum(conversion) as conversion, sum(impression) as impression, sum(click) as click, sum(cost) as cost").group("name").order("impression DESC").map do |x|
      cpc = 0 if x.click == 0
      cps = 0 if x.conversion == 0
      [x.name,
       x.click,
       x.impression,
       (100 * x.click.to_f/x.impression).round(2),
       cpc || x.cost.to_f/x.click,
       x.cost,
       x.conversion,
       cps || x.cost.to_f/x.conversion]
    end

    sum = where(account_group_id: account_group_id, period: month).select("sum(conversion) as conversion, sum(impression) as impression, sum(click) as click, sum(cost) as cost").first
    cpc = 0 if sum.click == 0
    cps = 0 if sum.conversion ==0
    y = [
      sum.click,
      sum.impression,
      (100* sum.click.to_i/sum.impression.to_f).round(2),
      cpc|| sum.cost.to_i.to_f/sum.click.to_i,
      sum.cost,
      sum.conversion,
      cps || sum.cost.to_i.to_f/sum.conversion.to_i]

    [lines, y]
  end
end
