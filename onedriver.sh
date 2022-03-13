#!/bin/bash

RED='\033[0;31m'
ORANGE='\033[0;33m'
NC='\033[0m'

function isRoot() {
	if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
	fi
}

function checkOS() {
	# Check OS version
	if [[ -e /etc/debian_version ]]; then
		source /etc/os-release
		OS="${ID}" # debian or ubuntu
		if [[ ${ID} == "debian" || ${ID} == "raspbian" ]]; then
			if [[ ${VERSION_ID} -lt 10 ]]; then
				echo "Your version of Debian (${VERSION_ID}) is not supported. Please use Debian 10 Buster or later"
				exit 1
			fi
			OS=debian # overwrite if raspbian
		fi
	elif [[ -e /etc/fedora-release ]]; then
		source /etc/os-release
		OS="${ID}"
	elif [[ -e /etc/centos-release ]]; then
		source /etc/os-release
		OS=centos
	elif [[ -e /etc/os-release ]]; then
		source /etc/os-release
		OS="${ID}" #openSUSE
	elif [[ -e /etc/arch-release ]]; then
		OS=arch
	else
		echo "Looks like you aren't running this installer on a Debian, Ubuntu, Fedora, CentOS, openSUSE or Arch Linux system"
		exit 1
	fi
}

function initialCheck() {
	isRoot
	checkOS
}

function installOnedriver() {
	
	# Install Onedriver
	if [[ ${OS} == 'ubuntu' ]] || [[ ${OS} == 'debian' && ${VERSION_ID} -gt 10 ]]; then
		echo 'deb http://download.opensuse.org/repositories/home:/jstaf/xUbuntu_20.04/ /' | sudo tee /etc/apt/sources.list.d/home:jstaf.list
    curl -fsSL https://download.opensuse.org/repositories/home:jstaf/xUbuntu_20.04/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_jstaf.gpg > /dev/null
    apt update
    apt install onedriver
	elif [[ ${OS} == 'debian' ]]; then
		echo 'deb http://download.opensuse.org/repositories/home:/jstaf/Debian_11/ /' | sudo tee /etc/apt/sources.list.d/home:jstaf.list
    curl -fsSL https://download.opensuse.org/repositories/home:jstaf/Debian_11/Release.key | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/home_jstaf.gpg > /dev/null
    apt update
    apt install onedriver
	elif [[ ${OS} == 'fedora' ]]; then
		if [[ ${VERSION_ID} -lt 32 ]]; then
		dnf copr enable jstaf/onedriver
    dnf install onedriver
		
	elif [[ ${OS} == 'centos' ]]; then
		dnf copr enable jstaf/onedriver
    dnf install onedriver
    
	elif [[ ${OS} == 'arch' ]]; then
		pacman -S onedriver
	elif [[ ${OS} == 'opensuse-tumbleweed' ]]; then
		zypper addrepo -g -r https://copr.fedorainfracloud.org/coprs/jstaf/onedriver/repo/opensuse-tumbleweed/jstaf-onedriver-opensuse-tumbleweed.repo onedriver
    zypper --gpg-auto-import-keys refresh
    zypper install onedriver
	elif [[ ${OS} == 'opensuse-leap' ]]; then
		zypper addrepo -g -r https://copr.fedorainfracloud.org/coprs/jstaf/onedriver/repo/opensuse-leap-15.3/jstaf-onedriver-opensuse-leap-15.3.repo onedriver
    zypper --gpg-auto-import-keys refresh
    zypper install onedriver
	fi
	
}

# Check for root, virt, OS...
initialCheck
# Check if WireGuard is already installed and load params
if [[ -e /etc/wireguard/params ]]; then
	source /etc/wireguard/params
	manageMenu
else
	installOnedriver
fi
