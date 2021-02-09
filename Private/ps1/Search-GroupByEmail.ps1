function Search-GroupByEmail {

    [CmdletBinding()]
    Param (

        [System.Net.Mail.MailAddress]
        $EmailAddress

    )

    # Search Role Groups
    Write-Verbose "Searching in role groups..."
    $roleGroup = Get-RoleGroup -ResultSize Unlimited -ShowPartnerLinked | # Using my helper function here, as RoleGroups have no filterable mail property
        Where-Object { ($_ | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction SilentlyContinue) -eq $EmailAddress }

    # Search Unified Groups
    Write-Verbose "Searching in unified groups..."
    $unifiedGroup = Get-UnifiedGroup -ResultSize Unlimited -Filter "PrimarySmtpAddress -eq '$EmailAddress'"

    # Search AzureAD Groups
    Write-Verbose "Searching in AzureAD groups..."
    $azureAdDynamicGroup = try { 
        
        Get-AzureADMSGroup `
            -All:$true `
            -Filter "Mail eq '$EmailAddress'" `
            -ErrorAction Stop | 
                Where-Object { $_.GroupTypes -eq "DynamicMembership" } 
                
    } 
    catch {

        # Empty
        # ErrorAction preference is not respected on AzureAD cmdlets, so catching errors silently here

    }

    # Search Security Groups
    Write-Verbose "Searching in security groups..."
    $securityGroup = Get-MsolGroup -All:$true -GroupType Security | # Using my helper function, as Msol cmdlets do not have a filter parameter
        Where-Object { ($_ | Find-ObjectIdentifier -PrimaryEmailAddress -ErrorAction SilentlyContinue) -eq $EmailAddress }

    # Search Distribution Groups
    Write-Verbose "Searching in distribution groups..."
    $distributionGroup = Get-DistributionGroup -ResultSize Unlimited -Filter "PrimarySmtpAddress -eq '$EmailAddress'"

    # Search Dynamic Distribution Groups
    Write-Verbose "Searching in dynamic distribution groups..."
    $dynamicDistributionGroup = Get-DynamicDistributionGroup -ResultSize Unlimited -Filter "PrimarySmtpAddress -eq '$EmailAddress'"

    # Search other Exchange Groups
    Write-Verbose "Searching in Exchange groups..."
    $exchangeGroup = Get-Group -ResultSize Unlimited -Filter "WindowsEmailAddress -eq '$EmailAddress'"

    $results = @()

    Write-Verbose "Compiling sorted array of groups"
   
    # Please leave in this order
    # I have set it this way, since certain group types will be returned by different commands
    # I want to prioritize it so that certain group types get added to the array below first before others

    $results += $roleGroup | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $unifiedGroup | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $azureAdDynamicGroup | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $securityGroup | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $distributionGroup | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $dynamicDistributionGroup | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $exchangeGroup | Where-Object { $_.DisplayName -notin $results.DisplayName }

    return $results

}