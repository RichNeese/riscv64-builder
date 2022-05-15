#!/bin/bash

current_kernel () {
	if [ -f /tmp/LATEST-${var} ] ; then
		rm -rf /tmp/LATEST-${var} | true
	fi
	wget --quiet --directory-prefix=/tmp/ ${server}${var}
	unset latest_kernel
	latest_kernel=$(cat "/tmp/LATEST-${var}" | grep "ABI:1 ${ver}" | awk '{print $3}')
	#echo "latest_kernel=[${latest_kernel}]"
	unset old_kernel
	if [ "x${filter1}" = "x" ] ; then
		old_kernel=$(cat "dt_cfg/kernel.data" | grep "${var}" | grep "${ver}" | awk '{print $3}')
		#echo "old_kernel=[${old_kernel}]"
	else
		old_kernel=$(cat "dt_cfg/kernel.data" | grep -v "${filter1}" | grep -v "${filter2}" | grep "${var}" | grep "${ver}" | awk '{print $3}')
		unset filter1
		unset filter2
		#echo "old_kernel=[${old_kernel}]"
	fi
	if [ ! "x${latest_kernel}" = "x${old_kernel}" ] ; then
		echo "kernel bump: ${git_msg}: ($latest_kernel)"
		echo "[sed -i -e 's:'$old_kernel':'$latest_kernel':g']"
		sed -i -e 's:'$old_kernel':'$latest_kernel':g' dt_cfg/*.cfg
		sed -i -e 's:'$old_kernel':'$latest_kernel':g' dt_cfg/kernel.data
		git commit -a -m "kernel bump: ${git_msg}: ($latest_kernel)" -s
	else
		echo "x${latest_kernel} = x${old_kernel}"
	fi
}

if [ -f configs/kernel.data ] ; then
	server="https://rcn-ee.net/repos/latest/sid-riscv64/LATEST-"
	git_msg="5.14.x-riscv64"
	var="riscv64"    ; ver="V514X"  ; current_kernel
fi
