#####Installation

#Verifies the timeout and sleep commands work properly, with subsecond specifications.
_timetest() {
	
	iterations=0
	while [[ "$iterations" -lt 10 ]]
	do
		dateA=$(date +%s)
		
		sleep 0.1
		sleep 0.1
		sleep 0.1
		sleep 0.1
		sleep 0.1
		sleep 0.1
		
		_timeout 0.1 sleep 10
		_timeout 0.1 sleep 10
		_timeout 0.1 sleep 10
		_timeout 0.1 sleep 10
		_timeout 0.1 sleep 10
		_timeout 0.1 sleep 10
		
		dateB=$(date +%s)
		
		dateDelta=$(bc <<< "$dateB - $dateA")
		
		if [[ "$dateDelta" -lt "1" ]]
		then
			_messageFAIL
			_stop 1
		fi
		
		if [[ "$dateDelta" -lt "5" ]]
		then
			_messagePASS
			return 0
		fi
		
		let iterations="$iterations + 1"
	done
	_messageFAIL
	_stop 1
}

_test_prog() {
	true
}

_test() {
	_start
	
	_messageNormal "Dependency checking..."
	
	## Check dependencies
	
	#"generic/filesystem"/permissions.sh
	_checkDep stat
	
	_getDep wget
	_getDep grep
	_getDep fgrep
	_getDep sed
	_getDep awk
	_getDep cut
	_getDep head
	_getDep tail
	
	
	_getDep realpath
	_getDep readlink
	_getDep dirname
	_getDep basename
	
	_getDep sleep
	_getDep wait
	_getDep kill
	_getDep jobs
	_getDep ps
	_getDep exit
	
	_getDep env
	_getDep bash
	_getDep echo
	_getDep cat
	_getDep type
	_getDep mkdir
	_getDep trap
	_getDep return
	_getDep set
	
	_getDep dd
	
	_getDep rm
	
	_getDep find
	_getDep ln
	_getDep ls
	
	_getDep id
	
	_getDep test
	
	_getDep true
	_getDep false
	
	_getDep diff
	
	_tryExec "_test_daemon"
	
	_tryExec "_testFindPort"
	_tryExec "_test_waitport"
	
	_tryExec "_testProxySSH"
	
	_tryExec "_testAutoSSH"
	
	_tryExec "_testTor"
	
	_tryExec "_testProxyRouter"
	
	#_tryExec "_test_build"
	
	_tryExec "_testGosu"
	
	_tryExec "_testMountChecks"
	_tryExec "_testBindMountManager"
	_tryExec "_testDistro"
	_tryExec "_test_fetchDebian"
	
	_tryExec "_test_image"
	_tryExec "_test_transferimage"
	
	_tryExec "_testCreatePartition"
	_tryExec "_testCreateFS"
	
	_tryExec "_test_mkboot"
	
	_tryExec "_test_fakehome"
	_tryExec "_testChRoot"
	_tryExec "_testQEMU"
	_tryExec "_testQEMU_x64-x64"
	_tryExec "_testQEMU_x64-raspi"
	_tryExec "_testQEMU_raspi-raspi"
	_tryExec "_testVBox"
	
	_tryExec "_test_vboxconvert"
	
	_tryExec "_test_dosbox"
	
	_tryExec "_testWINE"
	
	_tryExec "_test_docker"
	
	_tryExec "_test_docker_mkimage"
	
	_tryExec "_testVirtBootdisc"
	
	_tryExec "_testExtra"
	
	_tryExec "_testGit"
	_tryExec "_testX11"
	
	_tryExec "_test_virtLocal_X11"
	
	_tryExec "_test_gparted"
	
	_tryExec "_test_devemacs"
	
	_tryExec "_test_ethereum"
	_tryExec "_test_ethereum_parity"
	
	[[ -e /dev/urandom ]] || echo /dev/urandom missing _stop
	
	_messagePASS
	
	echo -n -e '\E[1;32;46m Timing...		\E[0m'
	_timetest
	
	_test_prog
	
	_stop
	
}

_testBuilt_prog() {
	true
}

_testBuilt() {
	_start
	
	_messageProcess "Binary checking"
	
	_tryExec "_testBuiltIdle"
	_tryExec "_testBuiltGosu"	#Note, requires sudo, not necessary for docker .
	
	_tryExec "_test_ethereum_built"
	_tryExec "_test_ethereum_parity_built"
	
	_tryExec "_testBuiltChRoot"
	_tryExec "_testBuiltQEMU"
	
	_tryExec "_testBuiltExtra"
	
	_testBuilt_prog
	
	_messagePASS
	
	_stop
}

#Creates symlink in ~/bin, to the executable at "$1", named according to its residing directory and file name.
_setupCommand() {
	local clientScriptLocation
	clientScriptLocation=$(_getAbsoluteLocation "$1")
	
	local clientScriptFolder
	clientScriptFolder=$(_getAbsoluteFolder "$1")
	
	local commandName
	commandName=$(basename "$1")
	
	local clientName
	clientName=$(basename "$clientScriptFolder")
	
	_relink_relative "$clientScriptLocation" ~/bin/"$commandName""-""$clientName"
	
	
}

#Consider placing files like ' _vnc-machine-"$netName" ' in an "_index" folder for automatic installation.
_setupCommands() {
	#find . -name '_command' -exec "$scriptAbsoluteLocation" _setupCommand {} \;
	find . -name '_vnc' -exec "$scriptAbsoluteLocation" _setupCommand {} \;
	find . -name '_ssh' -exec "$scriptAbsoluteLocation" _setupCommand {} \;
	find . -name '_wake' -exec "$scriptAbsoluteLocation" _setupCommand {} \;
	find . -name '_fs' -exec "$scriptAbsoluteLocation" _setupCommand {} \;
}

_setup_pre() {
	true
}

_setup_prog() {
	true
}

_setup() {
	_start
	
	_setup_pre
	
	"$scriptAbsoluteLocation" _test || _stop 1
	
	"$scriptAbsoluteLocation" _test_build || _stop 1
	
	if ! "$scriptAbsoluteLocation" _testBuilt
	then
		"$scriptAbsoluteLocation" _build "$@" || _stop 1
		"$scriptAbsoluteLocation" _testBuilt || _stop 1
	fi
	
	_setupCommands
	
	_setup_pre
	
	_tryExec "_setup_ssh"
	
	_setup_prog
	
	_stop
}
