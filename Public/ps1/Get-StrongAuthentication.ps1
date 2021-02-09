function Get-StrongAuthentication {
    <#
    .SYNOPSIS

    Gets an Office 365 user's multifactor authentication options

    .DESCRIPTION
    
    Turns on strong authentication for an Office 365 user.
    You can use the SetDefaultMethod parameter to specify a default type.
    You should use caution when specifying a default type, as some of them have prerequisites.
    For example, the type of PhoneAppNotification would require that the user has already:
        -- Installed the Microsoft Authenticator app on his or her mobile device
        -- Configured their account in the mobile app and connected it by scanning the QR code in the web browser

    You can leave the SetDefaultMethod parameter blank, to allow the user to choose a method his or herself.

    .PARAMETER SearchString

    Use this parameter to search for a user

    .PARAMETER  MsolUserObject

    This must be a full MsolUser object and cannot be of type string, int, or otherwise
    You can pass this parameter down the pipeline.
    
    .PARAMETER ReturnDefaultMethodOnly

    If this parameter is set only the default MFA method will be returned.

    .EXAMPLE

    PS> Get-MsolUser -SearchString "John Doe" | Get-StrongAuthentication

    This will return all strong authentication methods on the user's account.

    .EXAMPLE

    PS> Get-StrongAuthentication -MsolUserObject $msolUserObject -ReturnDefaultMethodOnly

    This will return only the default strong authentication method on the user's account.

    .INPUTS
       
    System.String
    Microsoft.Online.Administration.User
    System.Object

    .OUTPUTS
    
    System.Object
    #>
    [CmdletBinding()]
    Param (

        [Parameter(
            ParameterSetName = "String",
            Mandatory = $true
        )]
        [string]
        $SearchString,

        [Parameter(
            ParameterSetName = "Object",
            Mandatory = $false,
            ValueFromPipeline = $true            
        )]
        [psobject]
        $MsolUserObject,

        [Parameter()]
        [switch]
        $ReturnDefaultMethodOnly

    )
    begin {

        try {

            Test-RequiredConnections

        }
        catch {

            throw $_

        }

        if ($SearchString) {

            $MsolUserObject = Get-MsolUser -SearchString $SearchString
            if (-not $MsolUserObject) { throw "Unable to find a user matching: $SearchString" }

        }

    }
    process {

        $MsolUserObject | ForEach-Object {

            $user = $_
            if ($user.psobject.Properties.Name -contains "StrongAuthenticationMethods") {

                if (-not $user.StrongAuthenticationMethods) {

                    Write-Error `
                    -Message "This user does not have any MFA methods assigned." `
                    -Category NotImplemented `
                    -Exception 'NoMFAOptionsAssignedException'

                }
                else {

                    if ($ReturnDefaultMethodOnly) {
                    
                        if ($user.StrongAuthenticationMethods.IsDefault -contains $true) {

                            $user | Select-Object -ExpandProperty StrongAuthenticationMethods | Where-Object { $_.IsDefault -eq $true }

                        } 
                        else {

                            Write-Error `
                            -Message "This user does not have a default MFA method." `
                            -Category NotEnabled `
                            -Exception 'NoDefaultMFAException'

                        }

                    }
                    else {

                        $user | Select-Object -ExpandProperty StrongAuthenticationMethods

                    }

                }

            } 
            else {

                Write-Error "You have not passed a valid MsolUser object."

            }

        }

    }

}