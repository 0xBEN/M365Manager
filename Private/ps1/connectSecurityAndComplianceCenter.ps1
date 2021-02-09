function connectSecurityAndComplianceCenter {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $Credential
    )

    # Check for any Exchange sessions
    $sccSession = Get-PSSession | Where-Object { $_.ComputerName -like "*.compliance.protection.outlook.com" -and $_.State -match "Opened" }
    if ($sccSession) {
        
        Write-Host "A connection to Security and Compliance Center has already been established." -ForegroundColor Yellow

    }  
    else {

        try { # Try connecting to Exchange Online admin

            Write-Host "Connecting to Security and Compliance Center..."
            Connect-IPPSSession -Credential $Credential -WarningAction SilentlyContinue -ErrorAction Stop
            $sessionModule = Get-Module tmp* | Where-Object {$_.Description -like '*.compliance.protection.outlook.com*'}
            Write-Host "        Connected! All imported commands in module: $($sessionModule.Name)" -ForegroundColor Green
            
        } 
        catch { # If the connection fails

            try {

                Write-Warning "Authentication attempt failed. Trying interactive logon. Check for logon window behind other processes."
                Connect-IPPSSession -WarningAction SilentlyContinue -ErrorAction Stop
                Write-Host "        Connected!" -ForegroundColor Green

            }
            catch {

                throw $_
                
            }
        }

    }
    
}
