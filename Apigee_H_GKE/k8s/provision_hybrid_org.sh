#!/bin/bash
# Apigee hybrid provisioning script
set -a

PROJECT_ID=$GOOGLE_CLOUD_PROJECT
APIGEE_SERVICE=apigee.googleapis.com
AX_REGION=us-central1
ORG=

check_param(){
  local param=$1
  if [ -z "$param" ]
  then
    echo $USAGE
    exit 1
  fi
}

# wait for hybrid org create completion status
check_org_completion(){
  local lro=$1

# generate oauth access token needed to call apigee api 
  local token=$(gcloud auth print-access-token)
  if [ -z $token ]
  then
    echo "Error: could not generate OAuth access token."
    exit 1
  fi

  echo "Waiting for hybrid org to be created..."
  local state="Error"
  while [ "$state" != "FINISHED" ]
  do
    sleep 10
    local http_file=/tmp/http_response.$$.txt
    echo > $http_file
  # call apigee api to check hybrid org creation status
    local status=$(curl -s -w '%{http_code}' -H "Authorization: Bearer $token" -X GET \
      "https://${APIGEE_SERVICE}/v1/organizations/${ORG}/operations/${lro}" -o ${http_file})
  
    local response_body="$(cat $http_file)"
    rm $http_file 2>/dev/null
    if [ "$status" -ge 200 ] && [ "$status" -lt 300 ]
    then
	    local ops=$(jq -r '. | select (.| has("operations"))' <<< ${response_body})
      if [ ! -z $ops ]
      then
        state=$(jq -r ".operations.[] | select(.name==\"organizations/${ORG}/operations/${LRO}\") | .metadata.state" <<< ${ops})
      else
        state=$(jq -r '.metadata.state' <<< ${response_body})
      fi
    else
      echo ${status}:${response_body}
      echo "Error: fetching completion status for org: ${ORG}"
      exit 1
    fi
  done
  echo "${ORG}, ${state}"
}

create_hybrid_org(){
# generate oauth access token needed to call apigee api 
  local token=$(gcloud auth print-access-token)
  if [ -z $token ]
  then
    echo "Error: could not generate OAuth access token."
    exit 1
  fi

  local http_file=/tmp/http_response.$$.txt
  echo > $http_file
# call apigee api to create hybrid org 
  local status=$(curl -s -w '%{http_code}' -H "Authorization: Bearer $token" -X POST -H "content-type:application/json" \
                -d '{"name":"'"${ORG}"'", "analyticsRegion":"'"${AX_REGION}"'", "runtimeType":"'"HYBRID"'"}' \
                "https://${APIGEE_SERVICE}/v1/organizations?parent=projects/${PROJECT_ID}" -o ${http_file})
  
  local response_body="$(cat $http_file)"
  rm $http_file 2>/dev/null
  if [ "$status" -ge 200 ] && [ "$status" -lt 300 ]
  then   
	  local lro=$(jq -r '.name' <<< "${response_body}")
    lro=${lro##*/}
    local org_id=$(jq -r '.metadata.targetResourceName' <<< "${response_body}")
    org_id=${org_id##*/}
    echo "Submitted create request for hybrid org: $org_id"
    check_org_completion $lro
  elif [ "$status" -eq 409 ]
  then
    echo "Apigee hybrid organization already exists: ${ORG}"
  else
    echo ${status}:${response_body}
    echo "Error: creating Apigee hybrid org ${ORG} for project: ${PROJECT_ID}"
    exit 1
  fi
}

############################## mainline code #########################################
USAGE="${BASH_SOURCE[0]} <-o org> [-r <region>]"
while getopts "o:r:h" opt; do
	case $opt in
      o)
	      ORG=$OPTARG
	      ;;
      r)
	      AX_REGION=$OPTARG
	      ;;
	    h)
			  echo "$USAGE"
			  exit 0
			  ;;
	    \?)
	      echo "Invalid option: -${OPTARG}" >&2
	      exit 1
	      ;;
	esac
done

echo "====Starting Apigee hybrid provisioning script===="

if [ -z $PROJECT_ID ]
then
  echo "Error: project id not set. Please make sure the env variable GOOGLE_CLOUD_PROJECT is set to your Google Cloud project id."
  exit 1
fi

check_param $ORG

if [ -z "$AX_REGION" ]
then
  AX_REGION="us-central1"
fi

# create Apigee hybrid organizations for GCP project
create_hybrid_org

exit


