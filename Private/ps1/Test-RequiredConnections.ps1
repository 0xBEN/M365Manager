function Test-RequiredConnections {

    [CmdletBinding()]
    Param()
    process {

        try {

            Get-MsolCompanyInformation -ErrorAction Stop | Out-Null
            $msolReady = $true

        }
        catch {

            $msolReady = $false

        }

        try {

            Get-AzureADCurrentSessionInfo -ErrorAction Stop | Out-Null
            $azureAdReady = $true

        }
        catch {

            $azureAdReady = $false

        }

        try {

            # If no command, the PS remoting session was not imported
            Get-Command Get-DistributionGroup -ErrorAction Stop | Out-Null
            $exchangeOnlineReady = $true

        }
        catch {

            $exchangeOnlineReady = $false

        }
        
        if ((-not $msolReady) -or (-not $azureAdReady) -or (-not $exchangeOnlineReady)) {

            throw "Could not connect to required resources. Verify connections to AzureAD, ExchangeOnline, and MicrosoftOnline."

        }

    }

}