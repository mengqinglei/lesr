class KeywordStat < ActiveRecord::Base
  attr_accessible :account_group_id, :account_id, :ad_group_id, :campaign_id, :click, :conversion, :cost, :impression, :name, :period, :position, :vendor

  belongs_to :ad_group
  belongs_to :campaign
  belongs_to :account
  belongs_to :account_group

  scope :google, where(vendor: "Google")
  scope :bing, where(vendor: "Bing")

  def self.overall_stats(account_group_id, month, vendor)
    month = Date.parse(month) if month.is_a? String
    v = where(account_group_id: account_group_id, period: month, vendor: vendor).sum(:click)
    s = where(account_group_id: account_group_id, period: month, vendor: vendor).sum(:conversion)
    c = where(account_group_id: account_group_id, period: month, vendor: vendor).sum(:cost)
    cpc = c.to_f/v
    cps = c.to_f/s

    last_month = month - 1.month
    lv = where(account_group_id: account_group_id, period: last_month, vendor: vendor).sum(:click)
    ls = where(account_group_id: account_group_id, period: last_month, vendor: vendor).sum(:conversion)
    lc = where(account_group_id: account_group_id, period: last_month, vendor: vendor).sum(:cost)
    lcpc = lv == 0 ? 0 : lc.to_f/lv
    lcps = lv ==0 ? 0 : lc.to_f/ls

    {v: [v,lv,compare(v,lv)],
     s: [s,ls,compare(s,ls)],
     c: [c,lc,compare(c,lc)],
     cpc: [cpc,lcpc,compare(cpc,lcpc)],
     cps: [cps,lcps,compare(cps,lcps)]}

  end

  def self.top_keywords(account_group_id, month, vendor)
     lines = KeywordStat.where(account_group_id: account_group_id, period: month, vendor: vendor).select("name, sum(conversion) as conversion, sum(impression) as impression, sum(click) as click, sum(cost) as cost, avg(position) as position").group("name").order("impression DESC").limit(50).map do |x|
      cpc = 0 if x.click == 0
      cps = 0 if x.conversion == 0
      [x.name, x.click, x.impression, (100 * x.click.to_f/x.impression).round(2), cpc || x.cost.to_f/x.click,x.cost,x.position, x.conversion, cps || x.cost.to_f/x.conversion]
    end

    sum = KeywordStat.where(account_group_id: account_group_id, period: month, vendor: vendor).select("sum(conversion) as conversion, sum(impression) as impression, sum(click) as click, sum(cost) as cost, avg(position) as position").first
    cpc = 0 if sum.click == 0
    cps = 0 if sum.conversion ==0
    y = [sum.click, sum.impression, (100* sum.click.to_f/sum.impression).round(2),
      cpc|| sum.cost/sum.click, sum.cost, sum.position.round(2), sum.conversion,
      cps || sum.cost/sum.conversion] rescue [0,0,0,0,0,0,0,0,0,0,0,0,0]
    [lines, y]

  end

  def self.summary_data_over_time(account_group_id, month)
    base_data = KeywordStat.where(account_group_id: account_group_id, period: month)

    base_data.select("period as date, sum(cost) as cost, sum(click) as click, sum(impression) as impression, sum(conversion) as conversion").group("period").order("date").map do |x|
      {
       year: x.date.split("-")[0],
       month: Date::MONTHNAMES[x.date.split("-")[1].to_i],
       cost: x.cost,
       click: x.click,
       impression: x.impression,
       cpc: x.cost.to_f/x.click.to_i,
       conversion: x.conversion,
       cps: x.cost.to_f/x.conversion.to_i

      }

    end
  end

  private

  def self.compare(a, b)
    result = (100 * a/b - 100).to_i
    if result > 5
      "#{result}% higher than"
    elsif result < - 5
      "#{-result}% lower than"
    else
      "Almost the same as"
    end
  rescue
    ""
  end

end
