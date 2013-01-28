# For release code, use the following SOAP::Lite statement.
#use SOAP::Lite ( +maptype => {} );
# For debugging code, use the following SOAP::Lite statement.
use SOAP::Lite ( +trace => all, maptype => {} );

use LWP::Simple;
use File::Basename;
use strict;

eval
{
    my $username = "username";
    my $password = "password";
    my $devToken = "devtoken";
    my $appToken = "apptoken";
    my $customerAccountId = "customerid";
    my $customerId = "customerid";
    my $accountId = 123456;
    my $zipFile = "c:\\temp\\KeywordPerformanceReport.zip";
    
    # Use either the sandbox or the production URI.
    # This example is for the sandbox URI.
    my $URI = "https://api.sandbox.bingads.microsoft.com/api/advertiser/v8";
    # The following commented-out line contains the production URI.
    #my $URI = "https://adcenterapi.microsoft.com/api/advertiser/V8";
    
    # The Bing Ads API namespace.
    my $xmlns = "https://adcenter.microsoft.com/v8";
    
    # The proxy for the reporting Web service.
    my $reportingProxy = $URI."/Reporting/ReportingService.svc?wsdl";
    
    # The common data-type namespace.
    my $namespaceArrays =
        "http://schemas.microsoft.com/2003/10/Serialization/Arrays";
    
    # The service operation that will be called.
    my $action = 'SubmitGenerateReport';
    
    # The Web service.
    my $reportingService = SOAP::Lite->new(
        uri => $URI, 
        proxy => $reportingProxy, 
        on_action => ( sub { return $action } ));
    $reportingService->autotype(0);
    $reportingService->multirefinplace(1);
    $reportingService->readable(1);
    
    my $ReportRequest = CreateKeywordPerformanceReportRequest(
        'My Keyword Report',
        $accountId);
    
    my $reportRequestId;
    
    # Assemble the service operation parameters.
    my @header = CreateV8Header(
        $username,
        $password,
        $devToken,
        $appToken,
        $customerAccountId,
        $customerId);
    
    my @params =
    (
        @header,
        $ReportRequest
    );
    
    # Make the API call.
    my $methodQueueReport = SOAP::Data->name
    (
        $action."Request"
    )->attr({xmlns => $xmlns});
    
    my $response = $reportingService->call(
        $methodQueueReport => @params);
    
    # Check for errors.
    if ($response->fault) 
    {
        print "$action failed.\n";
        
        # Display the fault code and the fault string.
        print $response->faultcode, " ", $response->faultstring, "\n";
        
        # Display any ApiFault faults.
        if($response->match("//ApiFaultDetail"))
        {
            # Display the tracking ID.
            my $trackingId = $response->valueof("
                //ApiFaultDetail/TrackingId");
            print "TrackingId: $trackingId\n";
            
            # Display operation errors.
            my @operationErrors = $response->valueof(
                "//ApiFaultDetail/OperationErrors/OperationError");
            foreach my $operationError (@operationErrors)
            {
                print 
                    "Operation error ($operationError->{Code}) encountered.";
                print "$operationError->{Message}\n";        
            }
        }
        
        # Display any AdApiFault faults.
        elsif($response->match("//AdApiFaultDetail"))
        {
            # Display the tracking ID.
            my $trackingId = $response->valueof(
                "//AdApiFaultDetail/TrackingId");
            print "TrackingId: $trackingId\n";
            
            # Display operation errors.
            my @adApiErrors = $response->valueof(
                "//AdApiFaultDetail/Errors/AdApiError");
            foreach my $adApiError (@adApiErrors)
            {
                print "Ad API error ($adApiError->{Code}) encountered. ";
                print "$adApiError->{Message}\n";        
            }
        }
    }
    else
    {
        print "Successful call to $action.\n";
    
        # Display the tracking ID.
        my $trackingId = $response->valueof(
            '//ApiCallTrackingData/TrackingId');
        print "TrackingId: $trackingId\n";
        
        my $reportId = $response->valueof('//ReportRequestId');
        $reportRequestId = $reportId;
        
        RetrieveReport($reportId, $zipFile);
    }
    
    sub CreateV8Header
    {
        # Method parameters.
        my (
            $username,
            $password,
            $devtoken,
            $apptoken,
            $customeraccountid,
            $customerid) = @_;
        
        # Initialize the application token.
        my $AppToken = SOAP::Header->name
        (
            "ApplicationToken"=>$apptoken
        )->attr({xmlns => $xmlns});
        
        # Initialize the developer token.
        my $DevToken =SOAP::Header->name
        (
            "DeveloperToken"=>$devtoken
        )->attr({xmlns => $xmlns});
        
        # Initialize the user name.
        my $UserName =SOAP::Header->name
        (
            "UserName"=>$username
        )->attr({xmlns => $xmlns});
        
        # Initialize the password.
        my $Password =SOAP::Header->name
        (
            "Password"=>$password
        )->attr({xmlns => $xmlns});
        
        # Initialize the customer account ID.
        my $CustomerAccountId =SOAP::Header->name
        (
            "CustomerAccountId"=>$customeraccountid
        )->attr({xmlns => $xmlns});
        
        # Initialize the customer ID.
        my $CustomerId =SOAP::Header->name
        (
            "CustomerId"=>$customerid
        )->attr({xmlns => $xmlns});
        
        # Assemble the header parameters.
        my @headerParams =
        (
            $AppToken,
            $CustomerAccountId,
            $CustomerId,
            $DevToken,
            $Password,
            $UserName, 
        );
        
        return @headerParams;
    }

    
    # This subroutine creates the keyword performance report request.
    # Some of the data is passed in to the subroutine, but the majority
    # of it is hard-coded.
    sub CreateKeywordPerformanceReportRequest
    {
        my ($nameOfReport, $accountForReport) = @_;
        
        # Request an XML report.
        my $format = SOAP::Data->name("Format" => "Xml");
    
        # Use the English language.
        my $language = SOAP::Data->name("Language" => "English");
        
        # Specify the report name.
        my $reportName = SOAP::Data->name(
            "ReportName" => $nameOfReport);
        
        # Allow partial data to be returned.
        my $returnOnlyCompleteData = SOAP::Data->name(
            "ReturnOnlyCompleteData" => "false");
        
        # Specify the report aggregation.
        my $aggregation = SOAP::Data->name("Aggregation" => "Monthly");
        
        # Specify the time frame of the report. For this example, it is
        # the last six months.
        my $time = SOAP::Data->name("Time" => \SOAP::Data->value
        (
            #SOAP::Data->name("CustomDateRangeEnd" => ""),
            #SOAP::Data->name("CustomDateRangeStart" => ""),
            #SOAP::Data->name("CustomDates" => ""),
            SOAP::Data->name("PredefinedTime" => "LastSixMonths")
        ));
        
        # Specify the account that the report is for.
        my $accountIds = SOAP::Data->name("AccountIds" =>
            \SOAP::Data->value
        (
            SOAP::Data->name("long")->value(
                $accountForReport)->uri($namespaceArrays)
        ));
        
        my $scope = SOAP::Data->name("Scope" =>
            \SOAP::Data->value($accountIds));
    
        # Specify the columns that will be in the report.
        my $columns = SOAP::Data->name("Columns" => \SOAP::Data->value
        (
            SOAP::Data->name(
                "KeywordPerformanceReportColumn" => "AccountName"),
            SOAP::Data->name(
                "KeywordPerformanceReportColumn" => "CampaignName"),
            SOAP::Data->name(
                "KeywordPerformanceReportColumn" => "Keyword"),
            SOAP::Data->name(
                "KeywordPerformanceReportColumn" => "TimePeriod"),
            SOAP::Data->name(
                "KeywordPerformanceReportColumn" => "Impressions"),
            SOAP::Data->name(
                "KeywordPerformanceReportColumn" => "Conversions"),
        ));
        
        # Specify the filter for the report. The report request 
        # in this example specifies only the search ads that were
        # displayed in the United States.
        my $filter = SOAP::Data->name("Filter" => \SOAP::Data->value
        (
            SOAP::Data->name("AdDistribution" => "Search"),
            #SOAP::Data->name("DeliveredMatchType" => ""),
            #SOAP::Data->name("Keywords" => ""),
            SOAP::Data->name("LanguageAndRegion" => "UnitedStates")
        ));
        
        # Create the report request object.
        my $request = SOAP::Data->name("ReportRequest" =>
            \SOAP::Data->value
        (
            $format,
            $language,
            $reportName,
            $returnOnlyCompleteData,
            $aggregation,
            $columns,
            $filter,
            $scope,
            $time
        ));
    
        # Set the request attributes.
        $request->attr
        ({
            'i:type' => 'KeywordPerformanceReportRequest',
            'xmlns:i' => 'http://www.w3.org/2001/XMLSchema-instance'
        });
        
        return $request;
    }
    
    
    # This subroutine calls the PollGenerateReport service operation.
    sub GetReportStatus
    {
        my $reportRequestId=$_[0];
        
        my @header = CreateV8Header(
            $username,
            $password,
            $devToken,
            $appToken,
            $customerAccountId,
            $customerId);
        
        # This is important because the on_action property of the Web
        # service uses a reference to this global variable. If you
        # don't change the global variable, the wrong service operation
        # might be called.
        $action = "PollGenerateReport";
        
        my @params =
        (
            @header,
            SOAP::Data->name("ReportRequestId" => $reportRequestId)
        );
        
        my $methodGetReportStatus = SOAP::Data->name(
            $action.'Request')->attr({xmlns => $xmlns});
        my $response = $reportingService->call(
            $methodGetReportStatus => @params);
    
        if ($response->fault) 
        {
            print "$action failed.\n";
            
            # Display the fault code and the fault string.
            print $response->faultcode,
                " ",
                $response->faultstring, "\n";
        
            # Display the tracking ID.
            my $trackingId =
                $response->valueof("//ApiFaultDetail/TrackingId");
            print "TrackingId: $trackingId\n";
            
            # Display operation errors.
            my @operationErrors = $response->valueof(
                "//ApiFaultDetail/OperationErrors/OperationError");
            foreach my $operationError (@operationErrors)
            {
                print
                "Operation error ($operationError->{Code}) encountered. ";
                
                print "$operationError->{Message}\n";        
            }
        }
        else
        {
            print "Successful call to $action.\n";
        }
    
        return $response;
    }
    
    # This subroutine retrieves a requested report. This subroutine
    # will work for any type of report. The only parameter needed for
    # the subroutine is the report request identifier.
    sub RetrieveReport
    {
        my ($reportRequestId, $zipFileName) = @_;
        my $polling = 1;
        my $waitMinutes = 1;
        my $content = "";
    
        while ($polling)
        {
            my $response = GetReportStatus($reportRequestId);
            my $status = $response->valueof('//Status');
            print "Status: $status \n\r";
            
            if ($status =~ /Success/)
            {
                # Get the URL of the report to download.
                my $downloadUrl = $response->valueof(
                    '//ReportDownloadUrl');
                print "Downloading From : $downloadUrl\n\r";
    
                # Download the content of the zipped report.
                unless (defined ($content = get($downloadUrl)))
                {
                    die;
                }
    
                # Make sure that the .zip file destination directory
                # exists.
                my $dirname = dirname($zipFileName);
                mkdir($dirname);
                
                # Open the .zip file for writing and in binary mode.
                open(ZIPFILE, ">", $zipFileName);
                binmode(ZIPFILE);
                
                # Write the report contents to the .zip file.
                print(ZIPFILE $content);
                close(ZIPFILE);
                
                $polling = 0;
            }
            
            if (!($status =~ /Pending/))
            {
                $polling = 0;
            }
    
            if($polling)
            {
                # Wait a while before getting the status again.
                sleep($waitMinutes * 60);
            }
        }
    
        return $content;
    }
    
};
warn $@ if $@;
