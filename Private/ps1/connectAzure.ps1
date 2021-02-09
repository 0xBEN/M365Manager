function connectAzure {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $Credential
    )

    try { # Try this first to see if connected to AzureRM
        
        Get-AzContext -ErrorAction Stop | Out-Null
        Write-Host "A connection to Azure has already been established." -ForegroundColor Yellow

    } 
    catch {

        try { # Try to connect to Azure RM
            
            Write-Host "Connecting to Azure..."        
            Connect-AzAccount -Credential $Credential -ErrorAction Stop | Out-Null # Login to AzureRM console
            Write-Host "          Connected" -ForegroundColor Green

        } 
        catch { 

            try {

                Write-Warning "Authentication attempt failed. Trying interactive logon. Check for logon window behind other processes."
                Connect-AzAccount -ErrorAction Stop | Out-Null
                Write-Host "        Connected!" -ForegroundColor Green

            }
            catch {

                throw $_
                
            }

        }

    }

}