#True if daemon is running.
_daemonStatus() {
	if [[ -e "$pidFile" ]]
	then
		export daemonPID=$(cat "$pidFile")
	fi
	
	ps -p "$daemonPID" >/dev/null 2>&1 && return 0
	return 1
}

_waitForTermination() {
	_daemonStatus && sleep 0.1
	_daemonStatus && sleep 0.3
	_daemonStatus && sleep 1
	_daemonStatus && sleep 2
}
alias _waitForDaemon=_waitForTermination

#Kills background process using PID file.
_killDaemon() {
	_daemonStatus && kill -TERM "$daemonPID" >/dev/null 2>&1
	
	_waitForTermination
	
	_daemonStatus && kill -KILL "$daemonPID" >/dev/null 2>&1
	
	_waitForTermination
	
	rm "$pidFile" >/dev/null 2>&1
}

#Executes self in background (ie. as daemon).
_execDaemon() {
	"$scriptAbsoluteLocation" >/dev/null 2>&1 &
	echo "$!" > "$pidFile"
}
