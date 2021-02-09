function Set-StrongAuthentication {
    
    <#
    .SYNOPSIS

    Sets an Office 365 user's multifactor authentication options

    .DESCRIPTION
    
    Turns on strong authentication for an Office 365 user.
    You can use the SetDefaultMethod parameter to specify a default type.
    You should use caution when specifying a default type, as some of them have prerequisites.
    For example, the type of PhoneAppNotification would require that the user has already:
        -- Installed the Microsoft Authenticator app on his or her mobile device
        -- Configured their account in the mobile app and connected it by scanning the QR code in the web browser

    You can leave the SetDefaultMethod parameter blank, to allow the user to choose a method his or herself.

    .PARAMETER  MsolUserObject

    This must be a full MsolUser object and cannot be of type string, int, or otherwise
    You can pass this parameter down the pipeline.
    
    .PARAMETER SetDefaultOption

    This parameter will validate that you have chosen one of the following:
        -- "OneWaySMS","PhoneAppNotification","PhoneAppOTP","TwoWayVoiceMobile"
    This parameter can be left blank if you do not wish to set a default on the user's behalf    

    .EXAMPLE

    PS> Get-MsolUser -SearchString "John Doe" | Set-StrongAuthentication

    This will enable strong authentication options on the user's account.

    .EXAMPLE

    PS> Set-StrongAuthentication -MsolUserObject $msolUserObject -SetDefaultOption "OneWaySMS"

    This will enable strong authentication options on the user's account and will set SMS as the default option.

    .INPUTS
       
    Microsoft.Online.Administration.User
    System.Object

    .OUTPUTS
    
    None
    #>

    [CmdletBinding()]
    [Alias("Set-MfaOptions")]
    Param (

        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true    
        )]
        [psobject]
        $UserObject,

        [Parameter()]
        [ValidateSet("OneWaySMS","PhoneAppNotification","PhoneAppOTP","TwoWayVoiceMobile")]
        [string]
        $SetDefaultMethod

    )
    begin {

        try {

            Test-RequiredConnections

        }
        catch {

            throw $_

        }

        # If none set, default to Phone Call
        if (-not $PSBoundParameters['SetDefaultMethod']) { $SetDefaultMethod = 'TwoWayVoiceMobile' }

    }
    process {

        $UserObject | ForEach-Object {

            $oneWaySMS = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod
            $phoneAppNotification = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod
            $phoneAppOTP = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod
            $twoWayVoiceMobile = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationMethod

            $oneWaySMS.MethodType = "OneWaySMS"
            $phoneAppNotification.MethodType = "PhoneAppNotification"
            $phoneAppOTP.MethodType = "PhoneAppOTP"
            $twoWayVoiceMobile.MethodType = "TwoWayVoiceMobile"

            $defaultStrongAuthenticationMethodSchema = @($oneWaySMS,$phoneAppNotification,$phoneAppOTP,$twoWayVoiceMobile)
            $defaultStrongAuthenticationMethodSchema[$defaultStrongAuthenticationMethodSchema.MethodType.IndexOf($SetDefaultMethod)].IsDefault = $true
    
            # Set the strong authentication methods
            try {
                
                $objectId = $_ | Find-ObjectIdentifier -ObjectId -ErrorAction Stop
            
                Set-MsolUser `
                -ObjectId $objectId `
                -StrongAuthenticationMethods $defaultStrongAuthenticationMethodSchema `
                -ErrorAction Stop

            } catch {

                Write-Error -Exception $_.Exception

            }

        }

    }

}