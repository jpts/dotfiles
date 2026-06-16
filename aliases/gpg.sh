function gpgexport() {
  read -s id"?Enter GPG ID: "
  gpg2 -ao export.key --export-secret-keys "$id"
  gpg2 -ao export.pub --export "$id"
}

function gpgfilename() {
  gpg2 --list-packets "$1" 2>/dev/null | awk -F'["=]' '/name/ {print $3}'
}

function gpgdecrypt() {
  gpg2 -o "$(gpgfilename $1)" -d "$1"
}

function ssh2gpgenc() {
  if [ $# -le 0 ]; then
    echo "Usage: encrypt <ssh-key-file> <gpg-identity-to-encrypt-to>"
    return
  fi

  ssh-keygen -p -N "" -f "$1"
  #gpg2 --encrypt --recipient="j.prance@gmx.com" --yes --output="${1}".gpg < "$1"
  pass insert -m "ssh/${1}" < "$1"
  #gpg2 -d "${1}.gpg" > out.tmp
  gopass show "ssh/$1" > out.tmp
  diff -q  "$1" out.tmp
  if [ "$?" -eq 0 ]; then
    shred -u out.tmp
    #shred -u "$1"
    echo "Success"
  else
    echo "Error"
  fi
}
