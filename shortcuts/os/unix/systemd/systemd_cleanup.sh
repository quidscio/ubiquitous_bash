# WARNING: End user function. Do NOT call within scripts.
# No production use.
# DANGER: Removes all 'service' files with the correct number of characters. In practice, no non-temporary service is known to meet this criteria.
_systemd_cleanup() {
	# DANGER: Obsolete, more likely to cause unintended deletion. Will be disabled eventually.
	sudo -n rm -f /etc/systemd/system/??????????????????.service
	
	# WARNING: Relies on a >72char filename.
	sudo -n rm -f /etc/systemd/system/????????????????????????????????????????????????????????????????????????.service
}
