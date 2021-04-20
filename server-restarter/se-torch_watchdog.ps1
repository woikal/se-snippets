<#	
	.NOTES
	===========================================================================
	 Created with:  Windows PowerShell ISE	
	 Created in:   	2019
	 Created by:   	Alexander Woike, alexander.woike@gmail.com
	 Organization: 	Space-Engineers.de 
	 Filename:     	se-torch_watchdog.ps1
	===========================================================================
	.DESCRIPTION
		Script to scan all running processes and start instances of TorchAPI 
		(a Space Engineers Dedicated Server wrapper), if their names were not 
		found.
#>

### Config

$logfile = "D:\Gameserver\scripts\se-torch-watchdog.log"
$path = 'D:\Gameserver'
$instances = @{
#    'instance name' = 'subdirectory'
    'Galileo' = 'SEtorch-Galileo'
#    'Testserver' = 'SEtorch-preparation'
    'Newton' = 'SEtorch-Newton'
}
$exe = 'Torch.Server.exe'
$delay = 60 # seconds

### Functions

Function Has-Process {
    param (
        [array] $list,
		[string] $key
	)
	
	foreach ($server in $list) {
        if ($server.mainwindowTitle -match "$key") {
            return $true
        }
    }
	
	return $false
}

Function Log {
    param (
		[string] $level,
		[string] $msg
	)

    $datetime = Get-Date -format "yyyy-MM-dd  HH:mm:ss.fff" 

    Add-Content -path $logfile -value "$datetime  [$level]  $msg"
}

### Program

Log -level "INFO" -msg "Scanning active servers as user $(whoami)"
Write-Host "User: $(whoami)"        

$processes = Get-Process |
    Where-Object {$_.mainwindowhandle -ne 0} |
    Where {$_.name -eq 'Torch.Server'}
Log -level "INFO" -msg "Found $($processes.Length) active server instance(s)"
$processes.GetType()
$processes.Length

foreach ($id in $instances.keys) {
    $instancePath = "$path\$($instances[$id])\$exe"
	    
    if ((Has-Process -list $processes -key $id)) {
        Log -level "INFO" -msg "Instance '$id' running"
        Write-Host "Instance '$id' active"
       } else {
	    Log -level "WARN" -msg "Starting instance '$id' at $instancePath"
        Write-Host "Starting instance:   $instancePath"
		
        Start-Process -filepath $instancePath -PassThru
        
		Write-Host "Wait for $delay seconds ..."
        Start-Sleep -s $delay
    }
}
