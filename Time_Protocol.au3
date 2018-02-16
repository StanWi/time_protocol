#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Outfile=Time Protocol.exe
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Date.au3>
#include <File.au3>

If @YEAR > 2018 Then
	MsgBox(0,'Time Protocol','Time is up.',5)
Else
	OnAutoItExitRegister('_Exit')
	Local $file = @ScriptDir & '\Event.log'
	Local $ip = '0.0.0.0'
	Local $tz = _Date_Time_GetTimeZoneInformation()
	_FileWriteLog($file,'Server start (v.1.0)')
	UDPStartup()
	$server = UDPBind($ip,37)
	_FileWriteLog($file,'UDP listening on: ' & $ip & ':37')
	If @error Then
		_FileWriteLog($file,'Could not bind. Error code: ' & @error)
		_Exit()
	EndIf
	While 1
		$rx = UDPRecv($server,512,2)
		If $rx = '' Then
			Sleep(100)
		Else
			;_FileWriteLog($file,'UDP Request "' & $rx[0] & '" from ' & $rx[1] & ':' & $rx[2])
			$client = UDPOpen($rx[1],$rx[2])
			If @error Then
				_FileWriteLog($file,'Could not connect. Error code: ' & @error)
			Else
				UDPSend($client,Binary('0x' & Hex(Number((_DateDiff('s','1900/01/01 00:00:00',_NowCalc()) + $tz[1] * 60),1),8)))
				UDPCloseSocket($client)
			EndIf
		EndIf
	WEnd
EndIf

Func _Exit()
	UDPCloseSocket($server)
	UDPShutdown()
	_FileWriteLog($file,'UDP socket closed')
	_FileWriteLog($file,'Server stopped')
EndFunc
