function connectMicrosoftTeams {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $Credential
    )

    try { # Try this first to see if connected to Teams
        
        Get-Team | Out-Null
        Write-Host "A connection to Microsoft Teams has already been established." -ForegroundColor Yellow

    } 
    catch {

        try { # Try connecting to Microsoft Teams admin

            Write-Host "Connecting to MicrosoftTeams..."
            Connect-MicrosoftTeams -Credential $Credential -ErrorAction Stop | Out-Null # Login to Microsoft Teams
            Write-Host "        Connected!" -ForegroundColor Green

        } 
        catch { # If the connection fails
            
            try {

                Write-Warning "Authentication attempt failed. Trying interactive logon. Check for logon window behind other processes."
                Connect-MicrosoftTeams -ErrorAction Stop | Out-Null
                Write-Host "        Connected!" -ForegroundColor Green

            }
            catch {

                throw $_
                
            }

        }
        
    } 

}