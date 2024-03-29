# Save this file as "application.profile" (change "application" with the
# program name) in ~/.config/firejail directory. Firejail will find it
# automatically every time you sandbox your application.
#
# Run "firejail application" to test it. In the file there are
# some other commands you can try. Enable them by removing the "#".

# CUSTOM MODIFICATIONS
quiet
noblacklist ${HOME}/.aws
noblacklist ${HOME}/.kube
noblacklist /var/run/docker.sock
ignore noexec ${HOME}
noblacklist ${PATH}/bash

# Firejail profile for kubectl
# Persistent local customizations
#include kubectl.local
# Persistent global definitions
#include globals.local

### Basic Blacklisting ###
### Enable as many of them as you can! A very important one is
### "disable-exec.inc". This will make among other things your home
### and /tmp directories non-executable.
include disable-common.inc	# dangerous directories like ~/.ssh and ~/.gnupg
include disable-devel.inc	# development tools such as gcc and gdb
include disable-exec.inc	# non-executable directories such as /var, /tmp, and /home
include disable-interpreters.inc	# perl, python, lua etc.
include disable-programs.inc	# user configuration for programs such as firefox, vlc etc.
include disable-shell.inc	# sh, bash, zsh etc.
include disable-xdg.inc	# standard user directories: Documents, Pictures, Videos, Music

### Home Directory Whitelisting ###
### If something goes wrong, this section is the first one to comment out.
### Instead, you'll have to relay on the basic blacklisting above.
#private

### Filesystem Whitelisting ###
include whitelist-run-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

apparmor	# if you have AppArmor running, try this one!
#caps.drop all
#ipc-namespace
netfilter
no3d	# disable 3D acceleration
nodvd	# disable DVD and CD devices
#nogroups	# disable supplementary user groups
noinput	# disable input devices
nonewprivs
#noroot
notv	# disable DVB TV devices
nou2f	# disable U2F devices
novideo	# disable video capture devices
#net none
seccomp !chroot	# allowing chroot, just in case this is an Electron app
shell none
tracelog	# send blacklist violations to syslog

disable-mnt	# no access to /mnt, /media, /run/mount and /run/media
private-cache	# run with an empty ~/.cache directory
private-dev
private-etc group,passwd,resolv.conf
#private-lib
private-tmp

#dbus-user none
#dbus-system none

#memory-deny-write-execute

whitelist /run/docker.sock
whitelist ${HOME}/.aws/credentials
whitelist ${HOME}/.kube
whitelist ${HOME}/.local/bin/aws
whitelist ${HOME}/.local/bin/kubectl
whitelist ${HOME}/.local/bin/sonder
