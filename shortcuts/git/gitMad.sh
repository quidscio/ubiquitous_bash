
_self_gitMad_procedure() {
	local functionEntryPWD
	functionEntryPWD="$PWD"

	cd "$scriptAbsoluteFolder"
	_gitMad
	
	cd "$functionEntryPWD"
}
_self_gitMad() {
	"$scriptAbsoluteLocation" _self_gitMad_procedure "$@"
}
# https://stackoverflow.com/questions/1580596/how-do-i-make-git-ignore-file-mode-chmod-changes
_gitMad() {
	git config core.fileMode false
	git submodule foreach git config core.fileMode false
	git submodule foreach git submodule foreach git config core.fileMode false
	git submodule foreach git submodule foreach git submodule foreach git config core.fileMode false
	git submodule foreach git submodule foreach git submodule foreach git submodule foreach git config core.fileMode false
	git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git config core.fileMode false
	git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git config core.fileMode false
	git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git config core.fileMode false
	git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git config core.fileMode false
	git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git config core.fileMode false
	git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git submodule foreach git config core.fileMode false
}
