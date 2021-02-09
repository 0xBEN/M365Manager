function SharePointOnlinePnP {  

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCredential]
        $Credential
    )

    try { # Try this first to see if connected to SharePoint Online PnP
    
        Get-PnPWeb | Out-Null
        Write-Host "A connection to SharePointOnline PnP has already been established." -ForegroundColor Yellow

    } 
    catch {

        try { # Try connecting to SharePoint Online PnP admin

            Write-Host "Connecting to SharePointOnlinePnP..."
            Connect-PnPOnline -Url (Read-Host -Prompt "Enter the site URL to connect to") -Credentials $Credential | Out-Null
            Write-Host "        Connected!" -ForegroundColor Green

        } 
        catch {

            throw $_
            
        }

    }

}