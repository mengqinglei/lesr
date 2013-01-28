require 'soap/wsdlDriver'
require 'soap/header/simplehandler'

NS_SHARED = "https://adcenter.microsoft.com/v8"

# This is a helper class that is used
# to construct the request header.
class RequestHeader < SOAP::Header::SimpleHandler
    def initialize (element, value)
        super(XSD::QName.new(NS_SHARED, element))
            @element = element
            @value   = value
    end

    def on_simple_outbound
        @value
    end
end

def GetCampaignsByAccountIdLib(
    username,
    password,
    devToken,
    customerId,
    accountId)

    # Create the WSDL driver reference to access the Web service.
    wsdl = SOAP::WSDLDriverFactory.new("https://api.sandbox.bingads.microsoft.com/Api/Advertiser/v8/CampaignManagement/CampaignManagementService.svc?wsdl")
    
    service = wsdl.create_rpc_driver
    
    # For SOAP debugging information,
    # uncomment the following statement.
    # service.wiredump_dev = STDERR

    # Set the request header information.
    service.headerhandler << RequestHeader.new('CustomerAccountId',
        "#{accountId}")
    service.headerhandler << RequestHeader.new('CustomerId',
        "#{customerId}")
    service.headerhandler << RequestHeader.new('DeveloperToken',
        "#{devToken}")
    service.headerhandler << RequestHeader.new('UserName',
        "#{username}")
    service.headerhandler << RequestHeader.new('Password',
        "#{password}")

    # Create a string literal that contains the SOAP request body.
    getcampaignsbyaccountidrequest = %{
        <GetCampaignsByAccountIdRequest xmlns="https://adcenter.microsoft.com/v8">
          <AccountId>#{accountId}</AccountId>
        </GetCampaignsByAccountIdRequest>
    }

    begin
        # Convert the string literal that contains
        # the SOAP request body to an XML document.
        request = REXML::Document.new(getcampaignsbyaccountidrequest)
        
        response = service.GetCampaignsByAccountId(request)
      

    # Exception handling.
    rescue SOAP::FaultError => fault
        detail = fault.detail
        print "detail\n" + detail.to_s
        print "fault.detail\n" + fault.detail.to_s
        
        if detail.respond_to?('adApiFaultDetail')

            # Get the AdApiFaultDetail object.
            adApiErrors = detail.adApiFaultDetail.errors

            if !adApiErrors.respond_to?('each')
                adApiErrors = [adApiErrors]
            end

            adApiErrors.each do |error|
                print "Ad API error" \
                    " '#{error.message}' (#{error.code}) encountered.\n"
            end

        # Capture API exceptions.
        elsif detail.respond_to?('apiFaultDetail')
            operationErrors = detail.apiFaultDetail.operationErrors

            if !operationErrors.respond_to?('each')
                operationErrors = [operationErrors]
            end

            operationErrors.each do |opError|
                print "Operation error" \
                    " '#{opError.message}' (#{opError.code}) encountered.\n"
            end

        # Capture any generic SOAP exceptions.
        else
            print "Generic SOAP fault" \
                " '#{detail}' encountered.\n"
        end

    # Capture exceptions on the client that are unrelated to
    # the Bing Ads API. An example would be an 
    # out-of-memory condition on the client.
    rescue Exception => e
        puts "Error '#{e.exception.message}' encountered."
    end
end

begin
    GetCampaignsByAccountIdLib(
    "API_SmartSEM",
    "Pa55w0rd",
    "0571D0GH7Z4W9",
    7001410,
    0433022)
end
