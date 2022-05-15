#!/bin/bash -e
#
# Copyright (c) 2022
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

system=$(uname -n)
HOST_ARCH=$(uname -m)
TIME=$(date +%Y-%m-%d)

RVB_DIR="$( cd "$(dirname "$0")" ; pwd -P )" 
DIR="$PWD"

usage () {
	echo "usage: ./riscv64-builder.sh -e de -c sid-xfce"
    echo "-e|-E|--enviroment = : "
    echo "de= desktop enviroment | wm = window manager | twm = Tilew Window Manager | con = console"
    echo "-c|-C|--config = config file to use from the de/wm/twm directory"
}

checkparm () {
	if [ "$(echo $1|grep ^'\-')" ] ; then
		echo "E: Need an argument"
		usage
	fi
}

check_project_config () {

	if [ ! -d ${DIR}/ignore ] ; then
		mkdir -p ${DIR}/ignore
	fi
	tempdir=$(mktemp -d -p ${DIR}/ignore)

	time=$(date +%Y-%m-%d)

	#/config/${project_config}.conf
	unset leading_slash
	leading_slash=$(echo ${project_config} | grep "/" || unset leading_slash)
	if [ "${leading_slash}" ] ; then
		project_config=$(echo "${leading_slash##*/}")
	fi

	#${project_config}.conf
	project_config=$(echo ${project_config} | awk -F ".conf" '{print $1}')
	if [ -f ${DIR}/dt_cfg/${env_dir}/{project_config}.cfg ] ; then
		. <(m4 -P ${DIR}/dt_cfg/${env_dir}/{project_config}.cfg)
		export_filename="${deb_distribution}-${release}-${image_type}-${deb_arch}-${time}"

		# for automation
		echo "${export_filename}" > ${DIR}/latest_version

		echo "tempdir=\"${tempdir}\"" > ${DIR}/.project
		echo "time=\"${time}\"" >> ${DIR}/.project
		echo "export_filename=\"${export_filename}\"" >> ${DIR}/.project
		echo "#" >> ${DIR}/.project
		m4 -P ${DIR}/dt_cfg/${env_dir}/{project_config}.cfg >> ${DIR}/.project
	else
		echo "Invalid *.conf"
		exit
	fi
}

check_saved_config () {

	if [ ! -d ${DIR}/ignore ] ; then
		mkdir -p ${DIR}/ignore
	fi
	tempdir=$(mktemp -d -p ${DIR}/ignore)

	if [ ! -f ${DIR}/.project ] ; then
		echo "Couldn't find .project"
		exit
	fi
}

unset need_to_compress_rootfs
# parse commandline options
while [ ! -z "$1" ] ; do
	case $1 in
	-h|--help)
		usage
		exit
		;;
    -e|-E|--enviroment)
        checkparm $2
        env_dir="$2"
        check_env_dir
        ;;
	-c|-C|--config)
		checkparm $3
		project_config="$3"
		check_project_config
		;;
	--saved-config)
		check_saved_config
		;;
	esac
	shift
done

mkdir -p ${DIR}/ignore

if [ -f ${DIR}/.project ] ; then
	. ${DIR}/.project
fi

generic_git () {
	if [ ! -f ${DIR}/git/${git_project_name}/.git/config ] ; then
		git clone ${git_clone_address} ${DIR}/git/${git_project_name} --depth=1
	fi
}

update_git () {
	if [ -f ${DIR}/git/${git_project_name}/.git/config ] ; then
		cd ${DIR}/git/${git_project_name}/
		git pull --rebase || true
		cd -
	fi
}

git_trees () {
	if [ ! -d ${DIR}/git/ ] ; then
		mkdir -p ${DIR}/git/
	fi

	git_project_name="linux-firmware"
	git_clone_address="https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git"
	generic_git
	update_git
}

run_riscv64_ng () {
	if [ ! -f ${DIR}/.project ] ; then
		echo "error: [.project] file not defined"
		exit 1
	else
		echo "Debug: .project"
		echo "-----------------------------"
		cat ${DIR}/.project
		echo "-----------------------------"
	fi

	if [ ! "${tempdir}" ] ; then
		tempdir=$(mktemp -d -p ${DIR}/ignore)
		echo "tempdir=\"${tempdir}\"" >> ${DIR}/.project
	fi

	echo "Log: stat ${tempdir}"
	sudo chown root:root ${tempdir}
	sudo chmod 755 ${tempdir}
	stat ${tempdir}

	echo 'Log: /bin/bash -e "${RVB_DIR}/scripts/debootstrap.sh"'
	/bin/bash -e "${RVB_DIR}/scripts/debootstrap.sh" || { exit 1 ; }
	echo 'Log: /bin/bash -e "${RVB_DIR}/scripts/chroot.sh"'
	/bin/bash -e "${RVB_DIR}/scripts/chroot.sh" || { exit 1 ; }
	sudo rm -rf ${tempdir}/ || true
}

git_trees

cd ${DIR}/

run_riscv64_ng

#
