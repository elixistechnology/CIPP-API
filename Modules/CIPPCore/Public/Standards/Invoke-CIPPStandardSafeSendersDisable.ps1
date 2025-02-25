function Invoke-CIPPStandardSafeSendersDisable {
    <#
    .FUNCTIONALITY
        Internal
    .COMPONENT
        (APIName) SafeSendersDisable
    .SYNOPSIS
        (Label) Remove Safe Senders to prevent SPF bypass
    .DESCRIPTION
        (Helptext) Loops through all users and removes the Safe Senders list. This is to prevent SPF bypass attacks, as the Safe Senders list is not checked by SPF.
        (DocsDescription) Loops through all users and removes the Safe Senders list. This is to prevent SPF bypass attacks, as the Safe Senders list is not checked by SPF.
    .NOTES
        CAT
            Exchange Standards
        TAG
            "mediumimpact"
        ADDEDCOMPONENT
        DISABLEDFEATURES
            
        IMPACT
            Medium Impact
        POWERSHELLEQUIVALENT
            Set-MailboxJunkEmailConfiguration
        RECOMMENDEDBY
        UPDATECOMMENTBLOCK
            Run the Tools\Update-StandardsComments.ps1 script to update this comment block
    .LINK
        https://docs.cipp.app/user-documentation/tenant/standards/list-standards/exchange-standards#medium-impact
    #>

    param($Tenant, $Settings)
    ##$Rerun -Type Standard -Tenant $Tenant -Settings $Settings 'SafeSendersDisable'

    If ($Settings.remediate -eq $true) {
        try {
            $Mailboxes = New-ExoRequest -tenantid $Tenant -cmdlet 'Get-Mailbox' -select 'UserPrincipalName'
            $Request = $Mailboxes | ForEach-Object {
                @{
                    CmdletInput = @{
                        CmdletName = 'Set-MailboxJunkEmailConfiguration'
                        Parameters = @{
                            Identity                    = $_.UserPrincipalName
                            TrustedRecipientsAndDomains = $null
                        }
                    }
                }
            }

            $BatchResults = New-ExoBulkRequest -tenantid $tenant -cmdletArray @($Request)
            $BatchResults | ForEach-Object {
                if ($_.error) {
                    $ErrorMessage = Get-NormalizedError -Message $_.error
                    Write-Host "Failed to Disable SafeSenders for $($_.target). Error: $ErrorMessage"
                    Write-LogMessage -API 'Standards' -tenant $tenant -message "Failed to Disable SafeSenders for $($_.target). Error: $ErrorMessage" -sev Error
                }
            }
            Write-LogMessage -API 'Standards' -tenant $tenant -message 'Safe Senders disabled' -sev Info
        } catch {
            $ErrorMessage = Get-NormalizedError -Message $_.Exception.Message
            Write-LogMessage -API 'Standards' -tenant $tenant -message "Failed to disable SafeSenders. Error: $ErrorMessage" -sev Error
        }
    }

}
