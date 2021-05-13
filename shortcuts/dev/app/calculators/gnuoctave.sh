

_octave_interactive() {
	octave --quiet --silent --no-window-system --no-gui "$@"
}
_octave() {
	_octave_interactive "$@"
}

_octave_noninteractive() {
	octave --quiet --silent --no-window-system --no-gui "$@" | _octave_filter-messages
}

# ATTENTION: EXAMPLE: echo 'solve(x == y * 2, y)' | _octave_pipe
_octave_pipe() {
	octave --quiet --silent --no-window-system --no-gui "$@" | _octave_filter-messages
}

# ATTENTION: EXAMPLE: _octave_script 'octave_script.m'
# echo 'solve(x == y * 2, y)' > octave_script.m
_octave_script() {
	octave --quiet --silent --no-window-system --no-gui "$@" | _octave_filter-messages
}











_octave_filter-messages() {
	grep -v 'Symbolic pkg .*1: Python communication link active, SymPy v' | grep -v '_____'
	#cat
}






# solve '( y  == x * 2, x)'

_octave_solve() {
	_safeEcho_newline solve"$@" | _octave_pipe
}
#_solve() {
#	_octave_solve "$@"
#}
#solve() {
#	_octave_solve() "$@"
#}
#nsolve() {
#	_safeEcho_newline nsolve"$@" | _octave_pipe
#}








_test_devgnuoctave() {
	_wantGetDep octave
	_wantGetDep octave-cli
	
	
	_wantGetDep octave-config
	_wantGetDep mkoctfile
	
	_wantGetDep 'x86_64-linux-gnu/liboctave.so'
	_wantGetDep 'x86_64-linux-gnu/liboctinterp.so'
	
	
	_wantGetDep 'x86_64-linux-gnu/octave/site/oct/x86_64-pc-linux-gnu/libsbml5/OutputSBML.mex'
	_wantGetDep 'x86_64-linux-gnu/octave/site/oct/x86_64-pc-linux-gnu/libsbml5/TranslateSBML.mex'
	
	_wantGetDep 'x86_64-linux-gnu/qt5/plugins/cantor/backends/cantor_octavebackend.so'
	
	
	#if ! _wantGetDep dh_octave_check
	#then
		#! _typeShare 'dh-octave/install-pkg.m' && _wantGetDep dh-octave/install-pkg.m
	#fi
	
	
	
	_tryExec '_test_devgnuoctave-debian-x64'
	
	
	
	return 0
}
