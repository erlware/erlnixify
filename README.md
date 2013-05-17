Erlnixify
=========

Erlang has the problem that it does not integrate nicely with
Unix-like systems. It can not be put under things like
deamon-tools. You can't trap signals and respond appropriately,
etc. This is a small ruby program that serves as a 'front' to an
Erlang node. It allows a system like `init.d` or `daemontools` to
manage Erlnixify and Erlnixify will in-turn manage the Erlang node
using standard OTP inputs.

For example, when Erlnixify recieves a SIGTERM signal, it will call
`init:stop()` on the Erlang node. This allows Erlang's release handler
to do an orderly shutdown of the Erlang Node.

Erlnixify ensures that the Erlang node is up and running and checks
every few seconds (a configurable value) to see if everything is
continueing to run correctly. If those checks fail, Erlnixify will
shut down the Erlang node and then shut itself down so that whatever
is managing the system can restart.

Erlnixify is designed to simply front the Erlang node. It does not
provide restarts, log rotation, or anything like that. Those things
are expected to be provided by the system (daemontools again).

Erlnixify can be configured from the command line or via a config
file. Command line configuration overrides config file
configuration. That is, if a configuration value is provided both on
the command line and in the config file, the value on the command line
is the one that will be used.

** Erlnixify is designed to manage releases. **
** For self contained releases that do not have Erlang on the system,
   you must include `erl_interface` **


## Installation

Erlnixify requires ruby 1.9. It does not work on 1.8, but may work on
2.0+ though it has not been tested.

Add this line to your application's Gemfile:

    gem 'erlnixify'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install erlnixify

## Usage

### SYNOPSIS

`erlnixify` [&lt;optional&gt;...] &lt;flags&gt;

### EXAMPLE

The following example shows how to run a bare non-otp erlang
module. This is *not* the recommended way to do this at all. You
should be using Erlang releases, however it does work and it does
illustrate the point.

    erlnixify --name example \
              --cookie fubachu \
              --command "erl -setcookie %{cookie} -name %{fullname} -noshell -s my_module start"

The above is enough to get things going with the default
values. Running a release might be a bit more complicated. Its more
complicated because you are going to want to provide a custom check
commands and perhaps custom check intervals.

    erlnixify --name example2 \
              --cookiefile /etc/example2/mycookiefile \
              --release /opt/example2 \
              --command '/opt/example2/bin/example2 -setcookie %{cookie} -name=%{fullname} +Ktrue +B -noinput -shutdown_time 5000 +W w' \
              --check "example2 check_status" \
              --checkregex '^ok$' \
              --checkinterval 100

The above assumes we have a viable OTP Release in the /opt/example2
directory. We have placed our cookie in a file in
/etc/example2/mycookiefile and we have a script to start our release
that lives in the bin directory of the release. We have provided a
module `example2` with a function `check_status` that takes no
arguments to check the status of the system. If it returns an `ok`
everything is good. We are also going to run that check command every
100 seconds.


We could, of course, have put all the above in a config file as well.

    name: example2
    cookiefile: /etc/example2/mycookiefile
    release: /opt/example2
    command: /opt/example2/bin/example2 -setcookie %{cookie} -name=%{fullname} +Ktrue +B -noinput -shutdown_time 5000 +W w
    check: example2 check_status
    checkregex: ^ok$
    checkinterval: 100

Then our Erlnixify could have been much simpler. Assuming our config
file was at `/etc/example2/erlnixify-config.yaml` or Erlnixify command
line could have been.

    erlnixify --configfile /etc/example2/erlnixify-config



### Options

* `-b`, `--release`=&lt;release-root&gt;

   The root directory of the Release that Erlnixify is
   managing. Erlnixify expects to always be managing a release. This
   is optional if the `erlang` option is provided.

* `-b`, `--erlang`=&lt;erlang-root&gt;

   The erlang root directory for the system. This only needs to be
   used if both the `release` option is not specified and the erlang
   install is in a strange place.

* `-o`, `--home`=&lt;home-dir&gt;

   The home directory that should be set for the running system. This
   is set by default to the `HOME` directory of the user running
   erlnixify. However, in instances where that should be different or
   the user has no `HOME` directory, this option can be provided.

* `-n`, `--name`=&lt;short node name&gt;

   The short node name for this system. This is not
   optional. Erlnixify uses distributed erlang to manage and control
   the Erlang system.

* `--fullnode`=&lt;full node name&gt;

  When only `name` is provided, Erlnixify takes the host name of the
  system as provided by `hostname -f` and concatinates it with the
  value provided in `name` to come up with a fully qualified host
  name. The user can use this to override that full name.

* `-m`, `--command`=&lt;node start command&gt;

  This is the command that should be used to start the node. This command may contain variables that will be filled out by the Erlnixify system. Those variables are any one of the following.

  * `release` - as described adove
  * `erlang` - as described above
  * `home` - as described above
  * `name` - as described above
  * `fullname` - The full name of the Erlang node, either as provided
    or as discovered by Erlnixify. This value will always be populated
  * `cookie` - The cookie provided. This value will always be populated
  * `startuptimeout` - as described belov
  * `checkinterval` - as described below
  * `checktimeout` - as described below

* `-k`, `check`=&lt; the command used to check the status of the system&gt;

 This is an erlang module/function call in
 [erl_call](http://www.erlang.org/doc/man/erl_call.html) format. The
 default value for this command is `erlang statistics
 [reductions]`. However, that is not tremendously useful and you
 really should provide your own.

 * `-r`, `--checkregex`=&lt;regular expression&gt;

  This is a regular expression that is used to check the output of the
  above mentioned check command. If this regular expression does not
  match the output of the check command then the command is expected
  to have failed and the node will be shut down. By default this value
  is `^{\\d+, \\d+}$`. This matches the default `check` command. If
  you change the `check` command (and you should) you must change this
  value to match your expected output otherwise the system will always
  fail on the first check.

* `-x`, `--cookiefile`=&lt;path to file that contains the cookie&gt;

  If the `cookie` option is set this option is not needed. This should
  point to a file that contains the cookie that the system should
  use. That file must contain only the cookie. Be careful that you do
  not include a trailing newline.

* `-i`, `--cookie`=&lt;cookie value&gt;

  The actual value that Erlnixify should use as a cookie. This isn't
  needed if the `cookiefile` option is provided.

* `-t`, `--startuptimeout`=&lt;seconds that the node has to startup&gt;

  This is the number of seconds that the node has to startup. If the
  node is not running in that amount of time Erlnixify will shut it
  down and exit. The default value is 60.

* `-a`, `--checkinterval`=&lt;seconds between each check&gt;

  The number of seconds between each check. The default value is 30.


* `-w`, `--checktimeout`=&lt;seconds that the check command is allowed to run&gt;

  This is the number of seconds that the check command is allowed to
  run. If the check command takes longer then this number of seconds
  then Erlnixify will kill the Erlang node and exit.

* `-c`, `--config`=&lt;path to config file&gt;

  The path to a [YAML](http://yaml.org) based config file. The keys
  are the same as described here for the long version of the
  options. A config file is optional if the command line options are
  set instead.

* `-v`, `--version`

  Print out the version of Erlnixify

* `-h`, `--help`

 Print out the help for erlnixify

## Contributing

See [Contributing](https://github.com/erlware/erlnixify/blob/master/CONTRIBUTING.md)<
