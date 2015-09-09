# Developer quickstart

**Table of contents**

 * [Setting up the development environment](#setting-up-the-development-environment)
 * [Development workflow](#development-workflow)
 * [Testing](#testing)
   - [Running the test suite against a specific Passenger version](#running-the-test-suite-against-a-specific-passenger-version)
   - [Running the test suite against a specific `union_station_hooks_core` installation](#running-the-test-suite-against-a-specific-union_station_hooks_core-installation)
   - [Writing tests](#writing-tests)

## Setting up the development environment

Before you can start developing `union_station_hooks_rails`, you must setup a development environment.

### Step 1: install gem bundle

    cd /path-to/union_station_hooks_rails
    bundle install
    bundle exec install_test_app_bundles

### Step 2: install Passenger

During development, the `union_station_hooks_rails` unit tests are to be run against a specific Passenger version. If you already have Passenger installed, then you don't have to do anything. But if you do not yet have Passenger, then here is how you can install it:

 1. Clone the Passenger source code:

        git clone git://github.com/phusion/passenger.git


 2. Add this Passenger installation's `bin` directory to your `$PATH`:

        export PATH=/path-to-passenger/bin:$PATH

    You also need to add this to your bashrc so that the environment variable persists in new shell sessions.

 3. Install the Passenger Standalone runtime:

        passenger-config install-standalone-runtime

## Development workflow

The development workflow is as follows:

 1. Write code (`lib` directory).
 2. Write tests (`spec` directory).
 3. Run tests. Repeat from step 1 if necessary.
 4. Commit code, send a pull request.

## Testing

Once you have set up your development environment per the above instructions, run the test suite with:

    bundle exec rake spec

The unit test suite will automatically detect your Passenger installation by scanning `$PATH` for the `passenger-config` command.

### Running the test suite against a specific Passenger version

If you have multiple Passenger versions installed, and you want to run the test suite against a specific Passenger version (e.g. to test compatibility with that version), then you can do that by setting the `PASSENGER_CONFIG` environment variable to that Passenger installation's `passenger-config` command. For example:

    export PASSENGER_CONFIG=$HOME/passenger-5.0.18/bin/passenger-config
    bundle exec rake spec

### Running the test suite against a specific `union_station_hooks_core` installation

`union_station_hooks_rails`'s test suite is locked against a specific `union_station_hooks_core` version through Gemfile.lock. If you are developing `union_station_hooks_core` at the same time, then you may want to run the `union_station_hooks_rails` test suite against that particular installation. You can do so by setting the `USH_CORE_PATH` environment variable. It is not necessary to update the Gemfile or Gemfile.lock.

For example:

    export USH_CORE_PATH=/path-to/union_station_hooks_core
    bundle exec rake spec

### Running a specific test

If you want to run a specific test, then pass the test's name through the `E` environment variable. For example:

    bundle exec rake spec E='Rails 4.1 hooks initializes the Union Station Rails hooks'

### Writing tests

Tests are written in [RSpec](http://rspec.info/). They are also run against multiple Rails versions (see the skeleton apps in `rails_test_apps`). Therefore, the tests are written using a multi-process architecture. Tests follow this pattern:

 1. Construct a temporary Rails app (with specific controller code for example) using its skeleton as a base.
 2. Start the temporary app in Passenger. Passenger is configured to start its UstRouter in development mode. The development mode will cause the UstRouter to dump any received data to files on the filesystem, instead of sending them to the Union Station service.
 3. Send a request to the temporary app and assert that its response is as expected. We expect that during this step, the app will send a bunch of data to the UstRouter.
 4. Assert that the UstRouter dump files will **eventually** contain the data that we expect. The "eventually" part is important, because the UstRouter is highly asynchronous and may not write to disk immediately.
 5. Stop Passenger, destroy temporary app.

The test suite contains a bunch of helper methods that aid you in writing tests that follow these pattern. See `spec/spec_helper.rb`. There are also helper methods which are imported from `union_station_hooks_core`; see `lib/union_station_hooks_core/spec_helper.rb` in that gem.
