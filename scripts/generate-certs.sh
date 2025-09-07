#!/usr/bin/env bash

# Required: openssl

country_code=""
state_or_province=""
city=""
organization=""
organizational_unit=""
domain_name=""
folder=""

usage() { # Print the usage
  echo "Usage: $0 [ -c COUNTRY CODE ]
                  [ -s STATE OR PROVINCE ]
                  [ -l CITY ]
                  [ -o ORGANIZATION ]
                  [ -u ORGANIZATIONAL UNIT ]
                  [ -n DOMAIN NAME ]
                  [ -f FOLDER TO STORE CERTS]
                  [ -h HELP ]" 1>&2
}

exit_error() { # Function: Exit with error
  usage
  echo "-------------"
  echo "Exiting!"
  exit 1
}

while getopts "c:s:l:o:u:n:f:h" opt
do
  case ${opt} in
    c)
      country_code="${OPTARG}"
      ;;
    s)
      state_or_province="${OPTARG}"
      ;;
    l)
      city="${OPTARG}"
      ;;
    o)
      organization="${OPTARG}"
      ;;
    u)
      organizational_unit="${OPTARG}"
      ;;
    n)
      domain_name="${OPTARG}"
      ;;
    f)
      folder="${OPTARG}"
      ;;
    h)
      exit_error
      ;;
  esac
done

if [[ -z "$country_code" || -z "$state_or_province" || -z "$city" || -z "$organization" || -z "$organizational_unit" || -z "$domain_name" ]]
then
  exit_error
  exit 1
fi

if [[ "$folder" != "" ]]
then
    CERTS_FOLDER="certs/generated/$folder"
else
    CERTS_FOLDER="certs/generated"
fi

# Specify the directory to store the generated certs
mkdir -p "$CERTS_FOLDER"

openssl genrsa -out "$CERTS_FOLDER"/server.key 2048
openssl req -sha256 -new -key "$CERTS_FOLDER"/server.key -out "$CERTS_FOLDER"/server.csr -subj "/C=$country_code/ST=$state_or_province/L=$city/O=$organization/OU=$organizational_unit/CN=$domain_name"
openssl x509 -req -sha256 -days 365 -in "$CERTS_FOLDER"/server.csr -signkey "$CERTS_FOLDER"/server.key -out "$CERTS_FOLDER"/server.crt 

cat "$CERTS_FOLDER"/server.crt "$CERTS_FOLDER"/server.key > "$CERTS_FOLDER"/cert.pem