﻿<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2021 v5.8.195
	 Created on:   	20.10.2021 20:48
	 Created by:   	Bjorn Hofsvang
	 Organization: 	Bjorn Hofsvang
	 Filename:     	MakePasswords.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

$NumPasswords = 1
$MinLength = 10

function Parse-Commandline
{
	Param ([string]$CommandLine)
	$Arguments = New-Object System.Collections.Specialized.StringCollection
	
	#Find First Quote
	$index = $CommandLine.IndexOf('"')
	while ($index -ne -1)
	{
		#Continue as along as we find a quote
		#Find Closing Quote
		$closeIndex = $CommandLine.IndexOf('"', $index + 1)
		if ($closeIndex -eq -1)
		{
			break #Can't find a match
		}
		$value = $CommandLine.Substring($index + 1, $closeIndex - ($index + 1))
		[void]$Arguments.Add($value)
		$index = $closeIndex
		
		#Find First Quote
		$index = $CommandLine.IndexOf('"', $index + 1)
	}
	return $Arguments
}


function Convert-ArgumentsToDictionary
{
	Param ([System.Collections.Specialized.StringCollection]$Params,
		[char]$ParamIndicator)
	#$Dictionary = New-Object System.Collections.Specialized.StringDictionary
	$Dictionary = @{}
	
	for ($index = 0; $index -lt $Params.Count; $index++)
	{
		[string]$param = $Params[$index]
		#Clear the values
		$key = ""
		$value = ""
		
		if ($param.StartsWith($ParamIndicator))
		{
			#Remove the indicator
			$key = $param.Remove(0, 1)
			if ($index + 1 -lt $Params.Count)
			{
				#Check if the next Argument is a parameter 
				[string]$param = $Params[$index + 1]
				if ($param.StartsWith($ParamIndicator) -ne $true)
				{
					#If it isn't a parameter then set it as the value
					$value = $param
					$index++
				}
			}
			$Dictionary[$key] = $value
		} #else skip
	}
	return $Dictionary
}

function GenerateStrongPassword ([Parameter(Mandatory = $true)][int]$PasswordLenght)
{
	Add-Type -AssemblyName System.Web
	$PassComplexCheck = $false
	do
	{
		$newPassword = [System.Web.Security.Membership]::GeneratePassword($PasswordLenght, 1)
		If (($newPassword -cmatch "[A-Z\p{Lu}\s]") `
			-and ($newPassword -cmatch "[a-z\p{Ll}\s]") `
			-and ($newPassword -match "[\d]") `
			-and ($newPassword -match "[^\w]")
		)
		{
			$PassComplexCheck = $True
		}
	}
	While ($PassComplexCheck -eq $false)
	return $newPassword
}


# Verify that the $CommandLine variable exists
if ($CommandLine -ne $null -and $CommandLine -ne "")
{
	$Arguments = Parse-Commandline $CommandLine
	
	$Dictionary = Convert-ArgumentsToDictionary $Arguments '-'
		
	$NumPasswords = [int]$Dictionary["count"]
	$MinLength = [int]$Dictionary["length"]
	
	if (($MinLength -ne 0) -and ($MinLength -lt 4)) 
	{
		$MinLength = 4
	}
	elseif (($MinLength -ne 0) -and ($MinLength -gt 128))
	{
		$MinLength = 128
	}
	
	if ($NumPasswords -eq 0)
	{
		$NumPasswords = 1
	}
	
	
	for ($I = 0; $I -lt $NumPasswords; $I++)
	{
		GenerateStrongPassword ($MinLength)
	}
	
}
else
{
	GenerateStrongPassword ($MinLength)
}


# SIG # Begin signature block
# MIImLQYJKoZIhvcNAQcCoIImHjCCJhoCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCCdwaG1JigMNwm3
# tvrA0+Dl9IhxRDlL967HJPc80zq/oqCCIG4wggQyMIIDGqADAgECAgEBMA0GCSqG
# SIb3DQEBBQUAMHsxCzAJBgNVBAYTAkdCMRswGQYDVQQIDBJHcmVhdGVyIE1hbmNo
# ZXN0ZXIxEDAOBgNVBAcMB1NhbGZvcmQxGjAYBgNVBAoMEUNvbW9kbyBDQSBMaW1p
# dGVkMSEwHwYDVQQDDBhBQUEgQ2VydGlmaWNhdGUgU2VydmljZXMwHhcNMDQwMTAx
# MDAwMDAwWhcNMjgxMjMxMjM1OTU5WjB7MQswCQYDVQQGEwJHQjEbMBkGA1UECAwS
# R3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHDAdTYWxmb3JkMRowGAYDVQQKDBFD
# b21vZG8gQ0EgTGltaXRlZDEhMB8GA1UEAwwYQUFBIENlcnRpZmljYXRlIFNlcnZp
# Y2VzMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvkCd9G7h6naHHE1F
# RI6+RsiDBp3BKv4YH47kAvrzq11QihYxC5oG0MVwIs1JLVRjzLZuaEYLU+rLTCTA
# vHJO6vEVrvRUmhIKw3qyM2Di2olV8yJY897cz++DhqKMlE+faPKYkEaEJ8d2v+PM
# NSyLXgdkZYLASLCokflhn3YgUKiRx2a163hiA1bwihoT6jGjHqCZ/Tj29icyWG8H
# 9Wu4+xQrr7eqzNZjX3OM2gWZqDioyxd4NlGs6Z70eDqNzw/ZQuKYDKsvnw4B3u+f
# mUnxLd+sdE0bmLVHxeUp0fmQGMdinL6DxyZ7Poolx8DdneY1aBAgnY/Y3tLDhJwN
# XugvyQIDAQABo4HAMIG9MB0GA1UdDgQWBBSgEQojPpbxB+zirynvgqV/0DCktDAO
# BgNVHQ8BAf8EBAMCAQYwDwYDVR0TAQH/BAUwAwEB/zB7BgNVHR8EdDByMDigNqA0
# hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2Vz
# LmNybDA2oDSgMoYwaHR0cDovL2NybC5jb21vZG8ubmV0L0FBQUNlcnRpZmljYXRl
# U2VydmljZXMuY3JsMA0GCSqGSIb3DQEBBQUAA4IBAQAIVvwC8Jvo/6T61nvGRIDO
# T8TF9gBYzKa2vBRJaAR26ObuXewCD2DWjVAYTyZOAePmsKXuv7x0VEG//fwSuMdP
# WvSJYAV/YLcFSvP28cK/xLl0hrYtfWvM0vNG3S/G4GrDwzQDLH2W3VrCDqcKmcEF
# i6sML/NcOs9sN1UJh95TQGxY7/y2q2VuBPYb3DzgWhXGntnxWUgwIWUDbOzpIXPs
# mwOh4DetoBUYj/q6As6nLKkQEyzU5QgmqyKXYPiQXnTUoppTvfKpaOCibsLXbLGj
# D56/62jnVvKu8uMrODoJgbVrhde+Le0/GreyY+L1YiyC1GoAQVDxOYOflek2lphu
# MIIE/jCCA+agAwIBAgIQDUJK4L46iP9gQCHOFADw3TANBgkqhkiG9w0BAQsFADBy
# MQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYDVQQLExB3
# d3cuZGlnaWNlcnQuY29tMTEwLwYDVQQDEyhEaWdpQ2VydCBTSEEyIEFzc3VyZWQg
# SUQgVGltZXN0YW1waW5nIENBMB4XDTIxMDEwMTAwMDAwMFoXDTMxMDEwNjAwMDAw
# MFowSDELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDkRpZ2lDZXJ0LCBJbmMuMSAwHgYD
# VQQDExdEaWdpQ2VydCBUaW1lc3RhbXAgMjAyMTCCASIwDQYJKoZIhvcNAQEBBQAD
# ggEPADCCAQoCggEBAMLmYYRnxYr1DQikRcpja1HXOhFCvQp1dU2UtAxQtSYQ/h3I
# b5FrDJbnGlxI70Tlv5thzRWRYlq4/2cLnGP9NmqB+in43Stwhd4CGPN4bbx9+cdt
# CT2+anaH6Yq9+IRdHnbJ5MZ2djpT0dHTWjaPxqPhLxs6t2HWc+xObTOKfF1FLUux
# UOZBOjdWhtyTI433UCXoZObd048vV7WHIOsOjizVI9r0TXhG4wODMSlKXAwxikqM
# iMX3MFr5FK8VX2xDSQn9JiNT9o1j6BqrW7EdMMKbaYK02/xWVLwfoYervnpbCiAv
# SwnJlaeNsvrWY4tOpXIc7p96AXP4Gdb+DUmEvQECAwEAAaOCAbgwggG0MA4GA1Ud
# DwEB/wQEAwIHgDAMBgNVHRMBAf8EAjAAMBYGA1UdJQEB/wQMMAoGCCsGAQUFBwMI
# MEEGA1UdIAQ6MDgwNgYJYIZIAYb9bAcBMCkwJwYIKwYBBQUHAgEWG2h0dHA6Ly93
# d3cuZGlnaWNlcnQuY29tL0NQUzAfBgNVHSMEGDAWgBT0tuEgHf4prtLkYaWyoiWy
# yBc1bjAdBgNVHQ4EFgQUNkSGjqS6sGa+vCgtHUQ23eNqerwwcQYDVR0fBGowaDAy
# oDCgLoYsaHR0cDovL2NybDMuZGlnaWNlcnQuY29tL3NoYTItYXNzdXJlZC10cy5j
# cmwwMqAwoC6GLGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9zaGEyLWFzc3VyZWQt
# dHMuY3JsMIGFBggrBgEFBQcBAQR5MHcwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3Nw
# LmRpZ2ljZXJ0LmNvbTBPBggrBgEFBQcwAoZDaHR0cDovL2NhY2VydHMuZGlnaWNl
# cnQuY29tL0RpZ2lDZXJ0U0hBMkFzc3VyZWRJRFRpbWVzdGFtcGluZ0NBLmNydDAN
# BgkqhkiG9w0BAQsFAAOCAQEASBzctemaI7znGucgDo5nRv1CclF0CiNHo6uS0iXE
# cFm+FKDlJ4GlTRQVGQd58NEEw4bZO73+RAJmTe1ppA/2uHDPYuj1UUp4eTZ6J7fz
# 51Kfk6ftQ55757TdQSKJ+4eiRgNO/PT+t2R3Y18jUmmDgvoaU+2QzI2hF3MN9PNl
# OXBL85zWenvaDLw9MtAby/Vh/HUIAHa8gQ74wOFcz8QRcucbZEnYIpp1FUL1LTI4
# gdr0YKK6tFL7XOBhJCVPst/JKahzQ1HavWPWH1ub9y4bTxMd90oNcX6Xt/Q/hOvB
# 46NJofrOp79Wz7pZdmGJX36ntI5nePk2mOHLKNpbh6aKLzCCBTEwggQZoAMCAQIC
# EAqhJdbWMht+QeQF2jaXwhUwDQYJKoZIhvcNAQELBQAwZTELMAkGA1UEBhMCVVMx
# FTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNv
# bTEkMCIGA1UEAxMbRGlnaUNlcnQgQXNzdXJlZCBJRCBSb290IENBMB4XDTE2MDEw
# NzEyMDAwMFoXDTMxMDEwNzEyMDAwMFowcjELMAkGA1UEBhMCVVMxFTATBgNVBAoT
# DERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UE
# AxMoRGlnaUNlcnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQTCCASIw
# DQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL3QMu5LzY9/3am6gpnFOVQoV7Yj
# SsQOB0UzURB90Pl9TWh+57ag9I2ziOSXv2MhkJi/E7xX08PhfgjWahQAOPcuHjvu
# zKb2Mln+X2U/4Jvr40ZHBhpVfgsnfsCi9aDg3iI/Dv9+lfvzo7oiPhisEeTwmQNt
# O4V8CdPuXciaC1TjqAlxa+DPIhAPdc9xck4Krd9AOly3UeGheRTGTSQjMF287Dxg
# aqwvB8z98OpH2YhQXv1mblZhJymJhFHmgudGUP2UKiyn5HU+upgPhH+fMRTWrdXy
# ZMt7HgXQhBlyF/EXBu89zdZN7wZC/aJTKk+FHcQdPK/P2qwQ9d2srOlW/5MCAwEA
# AaOCAc4wggHKMB0GA1UdDgQWBBT0tuEgHf4prtLkYaWyoiWyyBc1bjAfBgNVHSME
# GDAWgBRF66Kv9JLLgjEtUYunpyGd823IDzASBgNVHRMBAf8ECDAGAQH/AgEAMA4G
# A1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcDCDB5BggrBgEFBQcBAQRt
# MGswJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEF
# BQcwAoY3aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJl
# ZElEUm9vdENBLmNydDCBgQYDVR0fBHoweDA6oDigNoY0aHR0cDovL2NybDQuZGln
# aWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDA6oDigNoY0aHR0
# cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNy
# bDBQBgNVHSAESTBHMDgGCmCGSAGG/WwAAgQwKjAoBggrBgEFBQcCARYcaHR0cHM6
# Ly93d3cuZGlnaWNlcnQuY29tL0NQUzALBglghkgBhv1sBwEwDQYJKoZIhvcNAQEL
# BQADggEBAHGVEulRh1Zpze/d2nyqY3qzeM8GN0CE70uEv8rPAwL9xafDDiBCLK93
# 8ysfDCFaKrcFNB1qrpn4J6JmvwmqYN92pDqTD/iy0dh8GWLoXoIlHsS6HHssIeLW
# WywUNUMEaLLbdQLgcseY1jxk5R9IEBhfiThhTWJGJIdjjJFSLK8pieV4H9YLFKWA
# 1xJHcLN11ZOFk362kmf7U2GJqPVrlsD0WGkNfMgBsbkodbeZY4UijGHKeZR+WfyM
# D+NvtQEmtmyl7odRIeRYYJu6DC0rbaLEfrvEJStHAgh8Sa4TtuF8QkIoxhhWz0E0
# tmZdtnR79VYzIi8iNrJLokqV2PWmjlIwggVvMIIEV6ADAgECAhBI/JO0YFWUjTan
# yYqJ1pQWMA0GCSqGSIb3DQEBDAUAMHsxCzAJBgNVBAYTAkdCMRswGQYDVQQIDBJH
# cmVhdGVyIE1hbmNoZXN0ZXIxEDAOBgNVBAcMB1NhbGZvcmQxGjAYBgNVBAoMEUNv
# bW9kbyBDQSBMaW1pdGVkMSEwHwYDVQQDDBhBQUEgQ2VydGlmaWNhdGUgU2Vydmlj
# ZXMwHhcNMjEwNTI1MDAwMDAwWhcNMjgxMjMxMjM1OTU5WjBWMQswCQYDVQQGEwJH
# QjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMS0wKwYDVQQDEyRTZWN0aWdvIFB1
# YmxpYyBDb2RlIFNpZ25pbmcgUm9vdCBSNDYwggIiMA0GCSqGSIb3DQEBAQUAA4IC
# DwAwggIKAoICAQCN55QSIgQkdC7/FiMCkoq2rjaFrEfUI5ErPtx94jGgUW+shJHj
# Uoq14pbe0IdjJImK/+8Skzt9u7aKvb0Ffyeba2XTpQxpsbxJOZrxbW6q5KCDJ9qa
# DStQ6Utbs7hkNqR+Sj2pcaths3OzPAsM79szV+W+NDfjlxtd/R8SPYIDdub7P2bS
# lDFp+m2zNKzBenjcklDyZMeqLQSrw2rq4C+np9xu1+j/2iGrQL+57g2extmeme/G
# 3h+pDHazJyCh1rr9gOcB0u/rgimVcI3/uxXP/tEPNqIuTzKQdEZrRzUTdwUzT2Mu
# uC3hv2WnBGsY2HH6zAjybYmZELGt2z4s5KoYsMYHAXVn3m3pY2MeNn9pib6qRT5u
# Wl+PoVvLnTCGMOgDs0DGDQ84zWeoU4j6uDBl+m/H5x2xg3RpPqzEaDux5mczmrYI
# 4IAFSEDu9oJkRqj1c7AGlfJsZZ+/VVscnFcax3hGfHCqlBuCF6yH6bbJDoEcQNYW
# Fyn8XJwYK+pF9e+91WdPKF4F7pBMeufG9ND8+s0+MkYTIDaKBOq3qgdGnA2TOglm
# mVhcKaO5DKYwODzQRjY1fJy67sPV+Qp2+n4FG0DKkjXp1XrRtX8ArqmQqsV/AZwQ
# sRb8zG4Y3G9i/qZQp7h7uJ0VP/4gDHXIIloTlRmQAOka1cKG8eOO7F/05QIDAQAB
# o4IBEjCCAQ4wHwYDVR0jBBgwFoAUoBEKIz6W8Qfs4q8p74Klf9AwpLQwHQYDVR0O
# BBYEFDLrkpr/NZZILyhAQnAgNpFcF4XmMA4GA1UdDwEB/wQEAwIBhjAPBgNVHRMB
# Af8EBTADAQH/MBMGA1UdJQQMMAoGCCsGAQUFBwMDMBsGA1UdIAQUMBIwBgYEVR0g
# ADAIBgZngQwBBAEwQwYDVR0fBDwwOjA4oDagNIYyaHR0cDovL2NybC5jb21vZG9j
# YS5jb20vQUFBQ2VydGlmaWNhdGVTZXJ2aWNlcy5jcmwwNAYIKwYBBQUHAQEEKDAm
# MCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5jb21vZG9jYS5jb20wDQYJKoZIhvcN
# AQEMBQADggEBABK/oe+LdJqYRLhpRrWrJAoMpIpnuDqBv0WKfVIHqI0fTiGFOaNr
# Xi0ghr8QuK55O1PNtPvYRL4G2VxjZ9RAFodEhnIq1jIV9RKDwvnhXRFAZ/ZCJ3LF
# I+ICOBpMIOLbAffNRk8monxmwFE2tokCVMf8WPtsAO7+mKYulaEMUykfb9gZpk+e
# 96wJ6l2CxouvgKe9gUhShDHaMuwV5KZMPWw5c9QLhTkg4IUaaOGnSDip0TYld8GN
# GRbFiExmfS9jzpjoad+sPKhdnckcW67Y8y90z7h+9teDnRGWYpquRRPaf9xH+9/D
# Up/mBlXpnYzyOmJRvOwkDynUWICE5EV7WtgwggYaMIIEAqADAgECAhBiHW0MUgGe
# O5B5FSCJIRwKMA0GCSqGSIb3DQEBDAUAMFYxCzAJBgNVBAYTAkdCMRgwFgYDVQQK
# Ew9TZWN0aWdvIExpbWl0ZWQxLTArBgNVBAMTJFNlY3RpZ28gUHVibGljIENvZGUg
# U2lnbmluZyBSb290IFI0NjAeFw0yMTAzMjIwMDAwMDBaFw0zNjAzMjEyMzU5NTla
# MFQxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxKzApBgNV
# BAMTIlNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBDQSBSMzYwggGiMA0GCSqG
# SIb3DQEBAQUAA4IBjwAwggGKAoIBgQCbK51T+jU/jmAGQ2rAz/V/9shTUxjIztNs
# fvxYB5UXeWUzCxEeAEZGbEN4QMgCsJLZUKhWThj/yPqy0iSZhXkZ6Pg2A2NVDgFi
# gOMYzB2OKhdqfWGVoYW3haT29PSTahYkwmMv0b/83nbeECbiMXhSOtbam+/36F09
# fy1tsB8je/RV0mIk8XL/tfCK6cPuYHE215wzrK0h1SWHTxPbPuYkRdkP05ZwmRmT
# nAO5/arnY83jeNzhP06ShdnRqtZlV59+8yv+KIhE5ILMqgOZYAENHNX9SJDm+qxp
# 4VqpB3MV/h53yl41aHU5pledi9lCBbH9JeIkNFICiVHNkRmq4TpxtwfvjsUedyz8
# rNyfQJy/aOs5b4s+ac7IH60B+Ja7TVM+EKv1WuTGwcLmoU3FpOFMbmPj8pz44MPZ
# 1f9+YEQIQty/NQd/2yGgW+ufflcZ/ZE9o1M7a5Jnqf2i2/uMSWymR8r2oQBMdlyh
# 2n5HirY4jKnFH/9gRvd+QOfdRrJZb1sCAwEAAaOCAWQwggFgMB8GA1UdIwQYMBaA
# FDLrkpr/NZZILyhAQnAgNpFcF4XmMB0GA1UdDgQWBBQPKssghyi47G9IritUpimq
# F6TNDDAOBgNVHQ8BAf8EBAMCAYYwEgYDVR0TAQH/BAgwBgEB/wIBADATBgNVHSUE
# DDAKBggrBgEFBQcDAzAbBgNVHSAEFDASMAYGBFUdIAAwCAYGZ4EMAQQBMEsGA1Ud
# HwREMEIwQKA+oDyGOmh0dHA6Ly9jcmwuc2VjdGlnby5jb20vU2VjdGlnb1B1Ymxp
# Y0NvZGVTaWduaW5nUm9vdFI0Ni5jcmwwewYIKwYBBQUHAQEEbzBtMEYGCCsGAQUF
# BzAChjpodHRwOi8vY3J0LnNlY3RpZ28uY29tL1NlY3RpZ29QdWJsaWNDb2RlU2ln
# bmluZ1Jvb3RSNDYucDdjMCMGCCsGAQUFBzABhhdodHRwOi8vb2NzcC5zZWN0aWdv
# LmNvbTANBgkqhkiG9w0BAQwFAAOCAgEABv+C4XdjNm57oRUgmxP/BP6YdURhw1aV
# cdGRP4Wh60BAscjW4HL9hcpkOTz5jUug2oeunbYAowbFC2AKK+cMcXIBD0ZdOaWT
# syNyBBsMLHqafvIhrCymlaS98+QpoBCyKppP0OcxYEdU0hpsaqBBIZOtBajjcw5+
# w/KeFvPYfLF/ldYpmlG+vd0xqlqd099iChnyIMvY5HexjO2AmtsbpVn0OhNcWbWD
# RF/3sBp6fWXhz7DcML4iTAWS+MVXeNLj1lJziVKEoroGs9Mlizg0bUMbOalOhOfC
# ipnx8CaLZeVme5yELg09Jlo8BMe80jO37PU8ejfkP9/uPak7VLwELKxAMcJszkye
# iaerlphwoKx1uHRzNyE6bxuSKcutisqmKL5OTunAvtONEoteSiabkPVSZ2z76mKn
# zAfZxCl/3dq3dUNw4rg3sTCggkHSRqTqlLMS7gjrhTqBmzu1L90Y1KWN/Y5JKdGv
# spbOrTfOXyXvmPL6E52z1NZJ6ctuMFBQZH3pwWvqURR8AgQdULUvrxjUYbHHj95E
# jza63zdrEcxWLDX6xWls/GDnVNueKjWUH3fTv1Y8Wdho698YADR7TNx8X8z2Bev6
# SivBBOHY+uqiirZtg0y9ShQoPzmCcn63Syatatvx157YK9hlcPmVoa1oDE5/L9Uo
# 2bC5a4CH2RwwggZsMIIE1KADAgECAhBGO8hHVg+9E7ST7UYdNrUaMA0GCSqGSIb3
# DQEBDAUAMFQxCzAJBgNVBAYTAkdCMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQx
# KzApBgNVBAMTIlNlY3RpZ28gUHVibGljIENvZGUgU2lnbmluZyBDQSBSMzYwHhcN
# MjExMDIwMDAwMDAwWhcNMjQxMDE5MjM1OTU5WjBSMQswCQYDVQQGEwJOTzERMA8G
# A1UECAwIQWtlcnNodXMxFzAVBgNVBAoMDkJqb3JuIEhvZnN2YW5nMRcwFQYDVQQD
# DA5Cam9ybiBIb2ZzdmFuZzCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIB
# AKiENzhoXOv/cCZm+P86Qorot59INbEEX6sRBv7bk6G0C0Dj83R871ydXmWen8iL
# AbPKOgKk7s6Dbdl38aAU5eXDxGZedgWCYq5IuplhYm9lp8tj9UBSyATgcHh55D4f
# rk6Vh832J7ywpqozXfvrzUIPAh6fUI+Jkrx32S/3wNvxufL8dJWtiqAmzKyckLJ2
# 5XDTm5PhG67T6ycuSA1iOQV/Tnf1TLvFGFAw80LiWhBWsY02vzQG4AxygJjXBqjA
# bW9pzAOWprQps4Ob47WZzztOEZ6U5vxDJfaPFJTSfQ4UXb7LbaXL67Dka/4p4hTe
# r2lCdo934tK65mmRIepwifcLZMlsdUWTEzgm59PuEENWRuPJvxxrDS3oQctwsC4V
# S1hk0T6cDixDP2hNy35cC3/fA5tCeylUYkySp7++Gmvvpui+BA8HD80dlHazCL6m
# P5KzkP/sKl67cXVM7cJUebNuS/fBRCEMIf/amDrbdROGOHmKyJBVwKe5QzzrOjLa
# JJAvePCP0XTEfpYs6yDCqu6kOl8E2HcUjEHP7BTc9Gnv0Du7SwerXDIci8zYyD8U
# aLvf7xWbkub8plGcNNxkjVVxfFo5G1PodO/D4onIxFdWKkGVeURXQYFQSFJZ4u1c
# 3pavCmr5P+y/ixfNwRCVbHGwO+K8kU1S87OVEXH1LrIRAgMBAAGjggG6MIIBtjAf
# BgNVHSMEGDAWgBQPKssghyi47G9IritUpimqF6TNDDAdBgNVHQ4EFgQUmRWZ1WnS
# f8lXSImavhC20sSZKTowDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwEwYD
# VR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEoGA1UdIARDMEEw
# NQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8vc2VjdGlnby5j
# b20vQ1BTMAgGBmeBDAEEATBJBgNVHR8EQjBAMD6gPKA6hjhodHRwOi8vY3JsLnNl
# Y3RpZ28uY29tL1NlY3RpZ29QdWJsaWNDb2RlU2lnbmluZ0NBUjM2LmNybDB5Bggr
# BgEFBQcBAQRtMGswRAYIKwYBBQUHMAKGOGh0dHA6Ly9jcnQuc2VjdGlnby5jb20v
# U2VjdGlnb1B1YmxpY0NvZGVTaWduaW5nQ0FSMzYuY3J0MCMGCCsGAQUFBzABhhdo
# dHRwOi8vb2NzcC5zZWN0aWdvLmNvbTAcBgNVHREEFTATgRFiam9ybkBob2ZzdmFu
# Zy5ubzANBgkqhkiG9w0BAQwFAAOCAYEAmEydU9POdnM4LCxA2OO2/ipyU409v5d9
# 9opMO1VrBLCSUIUZYSG1dJWRaY99S3nQ5XFgIHfIgcmUHegN3QUUzGz6PjHhMlZ2
# JfllpMMPwwL2ZrGwxTx/yj8tZdLb/bxeHw+l257/ofZhx3pYzNDEwuw7dApE2ZAH
# a545pdIdIQl872JhCYXLZ4ESGAKFgBq2EhQ4Ln62QqHNKDgjnR0mche6x+CZ05wg
# aWbfjU1/8okOl1BrvLfQ0AajszK8Z6lWk9qJJE73NXECvxeXztS/hNtXe8qW1asG
# GWfAFKR/W3AGohKPHbCJOqJC4j1Oa5xTyTcp47lJrEuMHHIRrObforTU2oxFv7sb
# VF1d6+j5gABuIWr/sCyU87e2RCkjLI1ussdtYc2+wpluu1f6XVGPpTx0WbMBGCoP
# yNBknIHvv/T0PU5yQ+xHgfnuh/OLkIdSq2SRZJcI5ZGXOiJK0JiFT1J8kmMbJ/5w
# tyjCQHFd2xKjXIrsBvqqoR12uenuNRFeMYIFFTCCBRECAQEwaDBUMQswCQYDVQQG
# EwJHQjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSswKQYDVQQDEyJTZWN0aWdv
# IFB1YmxpYyBDb2RlIFNpZ25pbmcgQ0EgUjM2AhBGO8hHVg+9E7ST7UYdNrUaMA0G
# CWCGSAFlAwQCAQUAoEwwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQwLwYJKoZI
# hvcNAQkEMSIEIFilIm1ghsHsTGiHNrwGp1g735RE2iqp8xjk2vgEp/OyMA0GCSqG
# SIb3DQEBAQUABIICAEfBJf3h65DSAAU+8O4eK1VQQYtnzqzibWIVY9k10nE2chPV
# HFADX+HRhb2XDPDMK7foQ+ZXbIqi899uLS6nFz4ttZJWlFP3oHr7bwjpGrVNLPp/
# aCY3+kfeDNZTVrccyLx6yhBjtztB1kOorUfeXZdxnXClrLltjtKWN4ndomVtCZ8F
# xpdIY4Zw9cxeOrY0IVqsrKnC2C21Rq8MawrHSv5LbiQ76K7O9nRZtDWP/eg4ylYg
# +YRILmEW0a1FVXOeEZz40YEvWg0oHZXST4R42rn9QjYKw40QGZkUDT/dvwX7Zr6z
# uAqq08w2kPjwxtWfJudx41vqk3XjDbwFsn9WgZrFtRSS3inhl60fpLX8TI7cGlu3
# ta1AQ3uibj5XXPJdfN9s5+SVArM4+dFD3w+nT5cOGBphi7LF57vo6TdheEDYHvl+
# 54t1xRBSStYPSnwyiiv1bO66Cvl6CEMxgUDBa2bPqFOWQhqx7uo7AYFkg77Txqb5
# MPI81ndbt1jeFA+KBGo8EvrzsmVKuMlojGrQW8kdUJrttwjgu6yEWUXtxVRIwVcH
# wBVYbLt+usX7J62FwIJ0pcu0IQvYNdGWRCjk241JbJgFL7+SYH1C99are4rgH9FY
# 42Ey+j0yMTkzREdREPSsthPNXRYfcRSN9m05t4/6DkboUuqX5tB2ovqCjg8JoYIC
# MDCCAiwGCSqGSIb3DQEJBjGCAh0wggIZAgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUw
# EwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20x
# MTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcg
# Q0ECEA1CSuC+Ooj/YEAhzhQA8N0wDQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG9w0B
# CQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0yMTEwMjYyMDM0MTJaMC8G
# CSqGSIb3DQEJBDEiBCDAI7Rw0raISzjmOOjcQJFpZukp4gyw0JOXuMZiUZX9NDAN
# BgkqhkiG9w0BAQEFAASCAQCFosXBZdfbIkiwji1QVb8DfZzGcI3ot3uP3b+DHiFE
# SICMlef8KiH/fcnmQQ/kngR/DFLUWR+p6pN7jfqxnfq0X6YY8wXVjSnVT46305tx
# 5/0tZpmDJcnH6U1Zf7fqVMI8Pd9EFuQ8nUtNMdlz7qkUiFu+ytWshHHQrvaVsQPa
# c4kBKqECjclWXQvnKiHq9MsU1jubmzwhDaVDe2Y+R6de5uzFX1UO5Zj44KTgwTpr
# Uxh67QwSL1kQ0JAUJ+LMrLJEpbS1zy0PevXH203lv9XLX48tdw8IyXKW2NMVEbsh
# CTqahOFi7ZyQcfUTspIvUWLT/5e3toVk5ySP2le/2c6V
# SIG # End signature block
