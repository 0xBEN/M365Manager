function connectExchangeOnline {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $Credential
    )

    # Check for any Exchange sessions
    $eoSession = Get-PSSession | Where-Object { $_.ComputerName -match "outlook" -and $_.State -match "Opened" }
    if ($eoSession) {
        
        Write-Host "A connection to ExchangeOnline has already been established." -ForegroundColor Yellow

    }  
    else {

        try { # Try connecting to Exchange Online admin

            Write-Host "Connecting to ExchangeOnline..."
            Connect-ExchangeOnline -Credential $Credential -ShowBanner:$false -ErrorAction Stop
            $sessionModule = Get-Module tmp* | Where-Object {$_.Description -like '*outlook.office365.com*'}
            Write-Host "        Connected! All imported commands in module: $($sessionModule.Name)" -ForegroundColor Green
            
        } 
        catch { # If the connection fails

            try {

                Write-Warning "Authentication attempt failed. Trying interactive logon. Check for logon window behind other processes."
                Connect-ExchangeOnline -ShowBanner:$false -ErrorAction Stop
                Write-Host "        Connected!" -ForegroundColor Green

            }
            catch {

                throw $_
                
            }

        }

    }
    
}
