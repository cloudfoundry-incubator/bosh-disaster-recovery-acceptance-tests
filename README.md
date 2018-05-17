# bosh-disaster-recovery-acceptance-tests (B-DRATs)

Tests a given BOSH director can be backed up and restored using [`bbr`](https://github.com/cloudfoundry-incubator/bosh-backup-and-restore).

The test runner provides hooks around `bbr director backup` and `bbr director restore`.

## Dependencies

1. Install [Golang](https://golang.org/doc/install)
1. Install [`ginkgo` CLI](https://github.com/onsi/ginkgo#set-me-up)
1. Install [`dep` dependency management tool](https://github.com/golang/dep#installation)
1. Download [`bbr` CLI](https://github.com/cloudfoundry-incubator/bosh-backup-and-restore/releases)

## Running B-DRATs in your pipelines

We encourage you to use our [`run-b-drats` CI task](https://github.com/cloudfoundry-incubator/bosh-disaster-recovery-acceptance-tests/tree/master/ci/run-b-drats) to run B-DRATS in your Concourse pipeline.

Please refer to our b-drats [pipeline definition](https://github.com/cloudfoundry-incubator/backup-and-restore-ci/blob/master/ci/b-drats/pipeline.yml) for a working example.

## Running B-DRATs locally

1. Clone this repo
    ```bash
    $ go get github.com/cloudfoundry-incubator/disaster-recovery-acceptance-tests
    $ cd $GOPATH/src/github.com/cloudfoundry-incubator/disaster-recovery-acceptance-tests
    ```
1. Create an `integration-config.json` file, for example:
    ```json
    {
      "bosh_host": "director-address",
      "bosh_ssh_username": "ssh-username",
      "bosh_ssh_private_key": "bosh-ssh-private-key",
      "bosh_client": "bosh-client-name",
      "bosh_client_secret": "bosh-client-secret",
      "bosh_ca_cert": "bosh-ca-cert",
      "timeout_in_minutes": "eventually-timeout-in-minutes",
      "include_deployment_testcase": true
    }
    ```
1. Export `INTEGRATION_CONFIG_PATH` to be path to `integration-config.json` file you just created.
1. Export `BBR_BINARY_PATH` to the path to the BBR binary.
1. Run acceptance tests
    ```bash
    $ ./scripts/_run_acceptance_tests.sh
    ```

## Integration Config Variables

* `bosh_host` - the BOSH director hostname
* `bosh_ssh_username` - the BOSH director VM SSH username
* `bosh_ssh_private_key` - the BOSH director VM SSH private key
* `bosh_client` - the BOSH director API client
* `bosh_client_secret` - the BOSH director API client secret 
* `bosh_ca_cert` - the BOSH director API CA certificate
* `timeout_in_minutes` - default ginkgo `Eventually` timeout in minutes, defaults to `30`
* `include_<testcase-name>` - flag for whether to run a given testcase, if omitted defaults to `false`

## Contributing to B-DRATs

B-DRATS runs a collection of test cases against a bosh director.

Test cases should be used for checking that BOSH director components' data has been backed up and restored correctly. For example, if your release backs up a database during `bbr director backup`, and the database is altered after taking the backup. Then after a successful `bbr director restore`, the content of the database will be restored to its original state.

To add extra test cases, create a new test case that implements the [`TestCase` interface](https://github.com/cloudfoundry-incubator/bosh-disaster-recovery-acceptance-tests/blob/master/runner/testcase.go).

The methods that need to be implemented are:
* `Name() string` - should return name of the test case.
* `BeforeBackup(Config)` - runs before the backup is taken, and should create state in the BOSH director to be backed up.
* `AfterBackup(Config)` - runs after the backup is complete but before the restore is started.
* `AfterRestore(Config)` - runs after the restore is complete, and should assert that the state in the restored BOSH director matches that created in `BeforeBackup(Config)`.
* `Cleanup(Config)` - should clean up the state created in the BOSH director through the test.

`Config` contains the config for the BOSH Director and for the CF deployments to backup and restore.

### Creating a new test case

1. Create a new test case in the [testcases package](https://github.com/cloudfoundry-incubator/bosh-disaster-recovery-acceptance-tests/tree/master/testcases).
1. Add the newly created test case to `[]runner.TestCase` in [`acceptance_test.go`](https://github.com/cloudfoundry-incubator/bosh-disaster-recovery-acceptance-tests/blob/master/acceptance/acceptance_test.go).

