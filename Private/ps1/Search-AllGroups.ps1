function Search-AllGroups {
        
    # Get all Role Groups
    Write-Verbose "Getting all role groups..."
    $roleGroups = Get-RoleGroup -ResultSize Unlimited -ShowPartnerLinked
    # Get all Unified Groups
    Write-Verbose "Getting all unified groups..."
    $unifiedGroups = Get-UnifiedGroup -ResultSize Unlimited             
    # Get all AzureAD Groups
    Write-Verbose "Getting all AzureAD groups..."
    $azureAdDynamicGroups = Get-AzureADMSGroup -All:$true -Filter "groupTypes/any(c:c eq 'DynamicMembership')"
    # Get all Security Groups
    Write-Verbose "Getting all security groups..."
    $securityGroups = Get-MsolGroup -All -GroupType Security
    # Get all Distribution Groups
    Write-Verbose "Getting all distribution groups..."
    $distributionGroups = Get-DistributionGroup -ResultSize Unlimited
    # Get all Dynamic Distribution Groups
    Write-Verbose "Getting all dynamic distribution groups groups..."
    $dynamicDistributionGroups = Get-DynamicDistributionGroup -ResultSize Unlimited
    # Get all other Exchange Groups
    Write-Verbose "Getting all Exchange groups..."
    $exchangeGroups = Get-Group -ResultSize Unlimited

    $results = @() # Initialize the array that will hold all the groups found by different cmdlets
    
    Write-Verbose "Compiling sorted array of groups"

    # Please leave in this order
    # I have set it this way, since certain group types will be returned by different commands
    # I want to prioritize it so that certain group types get added to the array below first before others

    $results += $roleGroups | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $unifiedGroups | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $azureAdDynamicGroups | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $securityGroups | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $distributionGroups | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $dynamicDistributionGroups | Where-Object { $_.DisplayName -notin $results.DisplayName }
    $results += $exchangeGroups | Where-Object { $_.DisplayName -notin $results.DisplayName }

    return $results

}