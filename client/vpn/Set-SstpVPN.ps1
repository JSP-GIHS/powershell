[CmdletBinding(SupportsShouldProcess=$true)]
Param()

Function Set-SstpVPN {

    <#

    .SYNOPSIS
    Idempotent configuration of an SstpVPN.

    .DESCRIPTION
    This function configures and creates an Sstp VPN based on solid configuration defaults that
    allow a decent level of safety and usability.

    Set-SstpVPN is idempotent and will correct configuration settings that do not match

    .EXAMPLE
    Set-SstpVPN -VPNName "SCHOOL VPN (Internet Link 1)" -VPNHost "link1.school.edu"

    .PARAMETER VPNName
    The human readable name of the VPN for display in Windows Networking

    .PARAMETER VPNHost
    The hostname or IP address the VPN should connect to

    #>

    [CmdletBinding(SupportsShouldProcess=$true)]
    Param (
        [Parameter(Mandatory=$True)]
        [String]$VPNName,
        [Parameter(Mandatory=$True)]
        [String]$VPNHost,
        [Parameter(Mandatory=$True)]
        [String]$DNSSuffix
    )

    $VPN = Get-VpnConnection -AllUserConnection -Name $VPNName -ErrorAction SilentlyContinue
    If ( -not $VPN ) {
        If ( $pscmdlet.ShouldProcess( $VPNName, "VPN Creation" ) ) {
            Add-VpnConnection -Name $VPNName -ServerAddress $VPNHost -TunnelType 'Sstp' -EncryptionLevel 'Required' -RememberCredential -AuthenticationMethod MSChapv2 -AllUserConnection
            Write-Output "[Configure-SstpVPN    ][VPN Connection       ] $VPNName Created"
            $VPN = Get-VpnConnection -AllUserConnection -Name $VPNName
        }
    }

    If ( $VPN.ServerAddress -ne $VPNHost ) {
        If ( $pscmdlet.ShouldProcess( $VPNName, "Set VPN Host" ) ) {
            Write-Warning -Message "[Configure-SstpVPN    ][Server Address       ] Not set to $VPNHost"
            Set-VpnConnection -AllUserConnection -Name $VPNName -ServerAddress $VPNHost
        }
    }

    If ( $VPN.TunnelType -ne 'Sstp' ) {
        If ( $pscmdlet.ShouldProcess( $VPNName, "Set Tunnel Type" ) ) {
            Write-Warning -Message "[Configure-SstpVPN    ][Tunnel Type          ] Not set to Sstp"
            Set-VpnConnection -AllUserConnection -Name $VPNName -TunnelType 'Sstp'
        }
    }

    If ( $VPN.AuthenticationMethod -ne 'MsChapv2' ) {
        If ( $pscmdlet.ShouldProcess( $VPNName, "Set Authentication Method" ) ) {
            Write-Warning -Message "[Configure-SstpVPN    ][Authentication Method] Not set to MsChapv2"
            Set-VpnConnection -AllUserConnection -Name $VPNName -AuthenticationMethod 'MSChapv2'
        }
    }

    If ( $VPN.EncryptionLevel -ne 'Required' ) {
        If ( $pscmdlet.ShouldProcess( $VPNName, "Set EncryptionLevel" ) ) {
            Write-Warning -Message "[Configure-SstpVPN    ][EncryptionLevel      ] Not set to Required"
            Set-VpnConnection -AllUserConnection -Name $VPNName -EncryptionLevel 'Required'
        }
    }

    If ( $VPN.RememberCredential -ne $True ) {
        If ( $pscmdlet.ShouldProcess( $VPNName, "Set RememberCredential" ) ) {
            Write-Warning -Message "[Configure-SstpVPN    ][RememberCredential   ] Not set to True"
            Set-VpnConnection -AllUserConnection -Name $VPNName -RememberCredential $True
        }
    }

    If ( $VPN.SplitTunneling -ne $False ) {
        If ( $pscmdlet.ShouldProcess( $VPNName, "Set SplitTunneling" ) ) {
            Write-Warning -Message "[Configure-SstpVPN    ][SplitTunneling       ] Not set to False"
            Set-VpnConnection -AllUserConnection -Name $VPNName -SplitTunneling $False
        }
    }

    If ( $VPN.IdleDisconnectSeconds -ne 1800 ) {
        If ( $pscmdlet.ShouldProcess( $VPNName, "Set IdleDisconnectTime" ) ) {
            Write-Warning -Message "[Configure-SstpVPN    ][IdleDisconnectTime   ] Not set to 1800"
            Set-VpnConnection -AllUserConnection -Name $VPNName -IdleDisconnectSeconds 1800
        }
    }

    If ( $VPN.DnsSuffix -ne $DNSSuffix ) {
        If ( $pscmdlet.ShouldProcess( $VPNName, "Set DNS Suffix" ) ) {
            Write-Warning -Message "[Configure-SstpVPN    ][DNSSuffix            ] Not set to $DNSSuffix"
            Set-VpnConnection -AllUserConnection -Name $VPNName -DnsSuffix $DNSSuffix
        }
    }
}

Set-SstpVPN -VPNName "Sample VPN Connection" -VPNHost "sstp.vpn.host" -DNSSuffix "internal.dns.domain"
