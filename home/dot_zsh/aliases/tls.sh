function pfx2ssl() {
    read -s pass"?Enter import/export passwd: "
    openssl pkcs12 -in "$1" -nocerts -out "${1:r}_pem.key" -passin "pass:$pass" -passout "pass:$pass"
    openssl pkcs12 -in "$1" -clcerts -nokeys -out "${1:r}_pem.crt" -passin "pass:$pass" -passout "pass:$pass"
    unset pass
}
