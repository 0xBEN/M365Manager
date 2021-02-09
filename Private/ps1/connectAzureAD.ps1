function connectAzureAD {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $Credential
    )

    try { # Try this first to see if connected to AzureAD

        Get-AzureADTenantDetail -ErrorAction Stop | Out-Null
        Write-Host "A connection to AzureAD has already been established." -ForegroundColor Yellow

    } 
    catch {

        try { # Try to connect to Azure AD
            
            Write-Host "Connecting to AzureAD..."        
            Connect-AzureAD -Credential $Credential -ErrorAction Stop | Out-Null # Login to AzureAD
            Write-Host "        Connected!" -ForegroundColor Green    

        } 
        catch { # If connection fails

            try {

                Write-Warning "Authentication attempt failed. Trying interactive logon. Check for logon window behind other processes."
                Connect-AzureAD -ErrorAction Stop | Out-Null
                Write-Host "        Connected!" -ForegroundColor Green

            }
            catch {

                throw $_
                
            }
            
        }

    }

}