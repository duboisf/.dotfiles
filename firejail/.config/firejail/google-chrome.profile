ignore noexec ${HOME}
ignore apparmor

noblacklist ${HOME}/.local/share/firenvim/firenvim
whitelist ${HOME}/.local/share/firenvim/firenvim

include /etc/firejail/google-chrome.profile
