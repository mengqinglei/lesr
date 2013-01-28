# install in your gem file
gem 'bing_ads_api', :git => 'https://github.com/weboglobin/bing_ads_api.git'

# initialize the client
client = BingAdsApi::Api.new(
        {
          :authentication => {
            :method => 'ClientLogin',
            :developer_token => 'DEVELOPER_TOKEN',
            :user_name => 'USERNAME',
            :password => 'PASSWORD',
            :customer_id => 'customer_id', # may be optional for some requests
            :customer_account_id => 'customer_account_id' # may be optional for some requests
          },
          :service => {:environment => 'PRODUCTION'},
          :library => {:log_level => 'DEBUG'}
        })

# select the service and the API version (:v7 or :v8)
administration_service = client.service(:AdministrationService, :v7)

# send your request
result = administration_service.get_assigned_quota()

# select another service
campaign_service = client.service(:CampaignManagementService, :v7)

# send another request
result = campaign_service.get_campaigns_by_account_id({:account_id => 00000})

# create a campaign
# result2 = campaign_service.add_campaigns({:account_id => 00000,
#                                         :campaigns => {:campaign => [{:budget_type => "DailyBudgetWithMaximumMonthlySpend",
#                                                                       :conversion_tracking_enabled => false,
#                                                                       :daily_budget => 5,
#                                                                       :daylight_saving => false,
#                                                                       :description => "A perfect new campaign",
#                                                                       :monthly_budget => 50,
#                                                                       :name => "perfectcampaign",
#                                                                       :time_zone => "BrusselsCopenhagenMadridParis"}]
#                                                       }
#                                         })
