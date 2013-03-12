class DatasController < ApplicationController
  def new
  end

  def create
    auto_domain_data_file = params[:automatic_domain_data]
    managed_domain_data_file = params[:managed_domain_data]
    keyword_data_file = params[:keyword_data]
    ad_data_file = params[:ad_data]
    bing_keyword_data_file = params[:bing_keyword_data]

    if auto_domain_data_file
      GoogleDomainDataImporter.create upload_id: Upload.create(data: auto_domain_data_file.read, upload_type: "AutomaticDomainStat").id
    end

    if managed_domain_data_file
      GoogleDomainDataImporter.create upload_id: Upload.create(data: managed_domain_data_file.read, upload_type: "ManagedDomainStat").id
    end

    if keyword_data_file
      GoogleKeywordDataImporter.create upload_id: Upload.create(data: keyword_data_file.read, upload_type: "KeywordStat").id
    end

    if ad_data_file
      GoogleAdDataImporter.create upload_id: Upload.create(data: ad_data_file.read, upload_type: "AdStat").id
    end

    if bing_keyword_data_file
      BingKeywordDataImporter.create upload_id: Upload.create(data: bing_keyword_data_file.read, upload_type: "KeywordStat").id
    end


    flash[:success] = "Data processing is being triggered. It can take up to 20 minutes. Please check back later."
    redirect_to :back
  end
end
