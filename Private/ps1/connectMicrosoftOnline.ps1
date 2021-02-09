function connectMicrosoftOnline {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $Credential
    )

    try { # Try this first to see if connected to Microsoft Online

        Get-MsolCompanyInformation -ErrorAction Stop | Out-Null
        Write-Host "A connection to MSOL has already been established." -ForegroundColor Yellow 

    } 
    catch {

        try { 
            
            Write-Host "Connecting to MicrosoftOnline..."
            Connect-MsolService -Credential $Credential -ErrorAction Stop | Out-Null # Login to Microsoft Online
            Write-Host "        Connected!" -ForegroundColor Green

        } 
        catch {

            try {

                Write-Warning "Authentication attempt failed. Trying interactive logon. Check for logon window behind other processes."
                Connect-MsolService -ErrorAction Stop | Out-Null
                Write-Host "        Connected!" -ForegroundColor Green

            }
            catch {

                throw $_
                
            }

        }

    }

}
