#!/usr/bin/env bash
set -e
. /etc/os-release
key=/usr/share/keyrings/proxmox-archive-keyring.gpg; [[ -e $key ]] || key=/etc/apt/trusted.gpg.d/proxmox-release-$VERSION_CODENAME.gpg
rm -f /etc/apt/sources.list /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources
cat > /etc/apt/sources.list.d/debian.sources <<EOF
Types: deb
URIs: http://deb.debian.org/debian
Suites: $VERSION_CODENAME $VERSION_CODENAME-updates
Components: main non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb
URIs: http://security.debian.org/debian-security
Suites: $VERSION_CODENAME-security
Components: main non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
cat > /etc/apt/sources.list.d/proxmox.sources <<EOF
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: $VERSION_CODENAME
Components: pve-no-subscription
Signed-By: $key
EOF
chmod 644 /etc/apt/sources.list.d/*.sources
apt-get update
sed -i 's/checked_command: function (orig_cmd) {$/& orig_cmd(); return;/' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js
cat > /etc/apt/apt.conf.d/99-pve-nonag <<'EOF'
DPkg::Post-Invoke { "f=/usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; [ ! -f $f ] || sed -i 's/checked_command: function (orig_cmd) {$/& orig_cmd(); return;/' $f"; };
EOF
pveum user add terraform@pve
pveum acl modify / --users terraform@pve --roles Administrator --propagate 1
token=$(pveum user token add terraform@pve lab --privsep 1 --output-format json)
pveum acl modify / --tokens terraform@pve!lab --roles Administrator --propagate 1
printf '%s' "$token" | perl -MJSON::PP -0777 -ne 'my $j = decode_json($_); printf "export PROXMOX_VE_API_TOKEN=\x27%s=%s\x27\n", $j->{"full-tokenid"}, $j->{value}'
