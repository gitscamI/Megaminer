﻿param(
    [Parameter(Mandatory = $true)]
    [String]$Querymode = $null,
    [Parameter(Mandatory = $false)]
    [pscustomobject]$Info
    )

#. .\..\Include.ps1

$Name = (Get-Item $script:MyInvocation.MyCommand.Path).BaseName
$ActiveOnManualMode    = $False
$ActiveOnAutomaticMode = $False
$AbbName = 'DON'
$WalletMode = "NONE"
$Result=@()


#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************


if ($Querymode -eq "info"){
    $Result =  [PSCustomObject]@{
                    Disclaimer = "No registration, Autoexchange to BTC always"
                    ActiveOnManualMode=$ActiveOnManualMode  
                    ActiveOnAutomaticMode=$ActiveOnAutomaticMode
                    ApiData = $True
                    AbbName=$AbbName
                    WalletMode=$WalletMode
                         }
    }


                        
#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************


    
if (($Querymode -eq "core" ) -or ($Querymode -eq "Menu")){

        try {
            $NH_Request = Invoke-WebRequest "https://api.nicehash.com/api?method=simplemultialgo.info" -UseBasicParsing | ConvertFrom-Json |Select-Object -expand result |Select-Object -expand simplemultialgo
            
        }
        catch {
                    WRITE-HOST 'Nicehash API NOT RESPONDING...ABORTING'
                    EXIT
                }

        

        $Locations=@()
        $Locations += [PSCustomObject]@{NhLocation ='USA';MMlocation='US'}
        $Locations += [PSCustomObject]@{NhLocation ='EU';MMlocation='EUROPE'}

        $NH_Request | ForEach-Object {


                    $NH_Algorithm = get_algo_unified_name ($_.name)
                    $NH_AlgorithmOriginal =$_.name
                    
                    $Divisor = 1000000000

                    switch ($NH_Algorithm) {
                            "Ethash" {$NH_coin="Ethereum"} #must force to allow dualmining Ethereum+?
                            "Lbry" {$NH_coin="Lbry"}
                            "Pascal" {$NH_coin="Pascal"}
                            "Blake2b" {$NH_coin="Siacoin"}
                            "Blake14r" {$NH_coin="Decred"}
                            default {$NH_coin=$NH_Algorithm}
                            }
                 
                




                    foreach ($location in $Locations) {

            

                        $Result+= [PSCustomObject]@{
                                        Algorithm     = $NH_Algorithm
                                        Info          = $NH_coin
                                        Price         = [double]($_.paying / $Divisor)
                                        Price24h      = $null
                                        Protocol      = "stratum+tcp"
                                        Host          = ($_.name)+"."+$location.NhLocation+".nicehash.com"
                                        Port          = $_.port
                                        User          = $(if ($CoinsWallets.get_item('BTC_NICE') -ne $null) {$CoinsWallets.get_item('BTC_NICE')} else {$CoinsWallets.get_item('BTC')})+'.'+"#WorkerName#"
                                        Pass          = "x"
                                        Location      = $location.MMLocation
                                        SSL           = $false
                                        Symbol        = $null
                                        AbbName       = $AbbName
                                        ActiveOnManualMode    = $ActiveOnManualMode
                                        ActiveOnAutomaticMode = $ActiveOnAutomaticMode
                                        PoolName = $Name
                                        WalletMode      = $WalletMode
                                        WalletSymbol = "BTC"
                                        OriginalAlgorithm =  $SNH_AlgorithmOriginal
                                        OriginalCoin = $NH_coin
                                        Fee = 0.04
                                        EthStMode = 3
                                            
                                        }
                        }
                }

    Remove-variable NH_Request
    }


#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************
#****************************************************************************************************************************************************************************************


$Result |ConvertTo-Json | Set-Content $info.SharedFile
Remove-variable Result


