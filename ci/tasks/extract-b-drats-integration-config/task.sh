#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2153

set -euo pipefail

bosh_host="$(terraform output -state terraform-state/terraform.tfstate director-internal-ip | jq -r .)"
bosh_ssh_username="$BOSH_SSH_USERNAME"
bosh_ssh_private_key="$( bosh int --path=/jumpbox_ssh/private_key "bosh-vars-store/${BOSH_VARS_STORE_PATH}" )"
timeout_in_minutes="$TIMEOUT_IN_MINUTES"
bosh_client="$BOSH_CLIENT"
bosh_client_secret="$( bosh int --path=/admin_password "bosh-vars-store/${BOSH_VARS_STORE_PATH}" )"
bosh_ca_cert="$( bosh int --path=/director_ssl/ca "bosh-vars-store/${BOSH_VARS_STORE_PATH}" )"
include_deployment_testcase="$INCLUDE_DEPLOYMENT_TESTCASE"
include_truncate_db_blobstore_testcase="$INCLUDE_TRUNCATE_DB_BLOBSTORE_TESTCASE"
include_credhub_testcase="$INCLUDE_CREDHUB_TESTCASE"
credhub_client="$CREDHUB_CLIENT"
credhub_client_secret="$( bosh int --path=/credhub_admin_client_secret "bosh-vars-store/${BOSH_VARS_STORE_PATH}" )"
credhub_server="$CREDHUB_SERVER"
credhub_ca_cert="$( bosh interpolate "bosh-vars-store/${BOSH_VARS_STORE_PATH}" --path=/credhub_tls/ca )
$( bosh interpolate "bosh-vars-store/${BOSH_VARS_STORE_PATH}" --path=/uaa_ssl/ca )"
stemcell_src="$( cat stemcell/url )"

integration_config="{}"

string_vars="bosh_host bosh_ssh_username bosh_ssh_private_key bosh_client bosh_client_secret bosh_ca_cert stemcell_src credhub_client_secret credhub_client credhub_ca_cert credhub_server"
for var in $string_vars
do
  integration_config=$(echo ${integration_config} | jq ".${var}=\"${!var}\"")
done

other_vars="include_deployment_testcase include_truncate_db_blobstore_testcase include_credhub_testcase timeout_in_minutes"
for var in $other_vars
do
  integration_config=$(echo "${integration_config}" | jq ".${var}=${!var}")
done

echo "$integration_config" > b-drats-integration-config/integration_config.json
