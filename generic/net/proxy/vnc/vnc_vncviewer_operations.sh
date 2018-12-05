_vncviewer_operations() {
	_messagePlain_nominal 'init: _vncviewer_operations'
	
	#Typically set in '~/.bashrc' for *unusual* machines which have problems using vncviewer under X11.
	#https://steamcommunity.com/app/382110/discussions/0/1741101364304281184/
	if [[ "$vncviewer_manual" == 'true' ]]
	then
		[[ "$vncviewer_startFull" == "true" ]] && vncviewerArgs+=(-FullScreen)
		
		mkdir -p "$HOME"/usrcmd
		
		local usrcmdUID
		usrcmdUID=$(_uid)
		
		_safeEcho_newline 'vncviewer -DotWhenNoCursor -passwd '\""$vncPasswdFile"\"' localhost:'"$vncPort"' '"${vncviewerArgs[@]}"' '"$@" > "$HOME"/usrcmd/"$usrcmdUID"
		_safeEcho_newline 'vncviewer -DotWhenNoCursor -passwd '\""$vncPasswdFile"\"' localhost:'"$vncPort"' '"${vncviewerArgs[@]}"' '"$@" > "$HOME"/usrcmd/"$usrcmdUID".sh
		chmod u+x "$HOME"/usrcmd/"$usrcmdUID".sh
		
		local msw_vncPasswdFile
		msw_vncPasswdFile=$(_slashBackToForward "$vncPasswdFile")
		msw_vncPasswdFile='C:\cygwin64'"$vncPasswdFile"
		
		if type '/cygdrive/c/Program Files/TigerVNC/vncviewer.exe' > /dev/null 2>&1 && uname -a | grep -i cygwin > /dev/null 2>&1
		then
			_safeEcho_newline '"C:\Program Files\TigerVNC\vncviewer.exe"'' -DotWhenNoCursor -passwd '\""$msw_vncPasswdFile"\"' localhost:'"$vncPort"' '"${vncviewerArgs[@]}"' '"$@" > "$HOME"/usrcmd/"$usrcmdUID"_x64.bat
			chmod u+x "$HOME"/usrcmd/"$usrcmdUID"_x64.bat
		fi
		
		if type '/cygdrive/c/Program Files (x86)/TigerVNC/vncviewer.exe' > /dev/null 2>&1 && uname -a | grep -i cygwin > /dev/null 2>&1
		then
			_safeEcho_newline '"C:\Program Files (x86)\TigerVNC\vncviewer.exe"'' -DotWhenNoCursor -passwd '\""$msw_vncPasswdFile"\"' localhost:'"$vncPort"' '"${vncviewerArgs[@]}"' '"$@" > "$HOME"/usrcmd/"$usrcmdUID"_x86.bat
			chmod u+x "$HOME"/usrcmd/"$usrcmdUID"_x86.bat
		fi
		
		_messagePlain_request 'request: manual launch: vncviewer: time 120s: instructions:' "$HOME"/usrcmd/"$usrcmdUID"
		
		_messagePlain_nominal 'wait...'
		
		# WARNING: Relies on VNC server replying "RFP" to TCP connections.
		sleep 9
		#while _checkPort localhost "$vncPort"
		while ! _timeout 6 socat - TCP:localhost:33773,connect-timeout="$netTimeout" 2> /dev/null | grep RFB >/dev/null 2>&1
		do
			sleep 3
		done
		sleep 3
		
		rm -f "$HOME"/usrcmd/"$usrcmdUID" > /dev/null 2>&1
		rm -f "$HOME"/usrcmd/"$usrcmdUID".sh > /dev/null 2>&1
		rm -f "$HOME"/usrcmd/"$usrcmdUID"_x86.bat > /dev/null 2>&1
		rm -f "$HOME"/usrcmd/"$usrcmdUID"_x64.bat > /dev/null 2>&1
		
		return 0
	fi
	
	_messagePlain_nominal 'Searching for X11 display.'
	! _detect_x11 && _messagePlain_warn 'fail: _detect_x11'
	
	export DISPLAY="$destination_DISPLAY"
	export XAUTHORITY="$destination_AUTH"
	_messagePlain_probe '_vncviewer_operations'
	_report_detect_x11
	
	_messagePlain_nominal 'Detecting and launching vncviewer.'
	#TigerVNC
	if vncviewer --help 2>&1 | grep 'PasswordFile   \- Password file for VNC authentication (default\=)' >/dev/null 2>&1
	then
		_messagePlain_good 'found: vncviewer (TigerVNC)'
		
		[[ "$vncviewer_startFull" == "true" ]] && vncviewerArgs+=(-FullScreen)
		
		if ! vncviewer -DotWhenNoCursor -passwd "$vncPasswdFile" localhost:"$vncPort" "${vncviewerArgs[@]}" "$@"
		then
			_messagePlain_bad 'fail: vncviewer'
			stty echo > /dev/null 2>&1
			return 1
		fi
		stty echo > /dev/null 2>&1
		return 0
	fi
	
	#TightVNC
	if vncviewer --help 2>&1 | grep '\-passwd' >/dev/null 2>&1
	then
		_messagePlain_good 'found: vncviewer (TightVNC)'
		
		#if ! vncviewer -encodings "copyrect tight zrle hextile" localhost:"$vncPort"
		if ! vncviewer -passwd "$vncPasswdFile" localhost:"$vncPort" "$@"
		then
			_messagePlain_bad 'fail: vncviewer'
			stty echo > /dev/null 2>&1
			return 1
		fi
		stty echo > /dev/null 2>&1
		return 0
	fi
	
	type vncviewer > /dev/null 2>&1 && _messagePlain_bad 'unsupported: vncviewer'
	! type vncviewer > /dev/null 2>&1 && _messagePlain_bad 'missing: vncviewer'
	
	return 1
}
