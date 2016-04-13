Generic CLI written in Ruby for SoftLayer. Currently only supports account reporting and system cancellation.

Supports various filtering and searching parameters, as well as multiple output formats (plain text,
 CSV, JSON).

## Examples

    $ softlayer report -s datacenter:hou02 domain:foo.mydomain.com
    +----------+---------------+--------------------------------+---------------+------------+-------+----------+---------+---------------------+
    | ID       | TYPE          | HOSTNAME                       | IP            | DATACENTER | COST  | USERNAME | NAME    | EMAIL               |
    +----------+---------------+--------------------------------+---------------+------------+-------+----------+---------+---------------------+
    | 10756577 | VirtualServer | spzabclcent1.foo.mydomain.com  | 10.193.91.62  | Houston 2  | 30.24 | joedoe   | Joe Doe | joedoe@mydomain.com |
    | 10756579 | VirtualServer | spzabclcent2.foo.mydomain.com  | 10.173.58.246 | Houston 2  | 30.24 | joedoe   | Joe Doe | joedoe@mydomain.com |
    | 10390509 | VirtualServer | spzabclrhel71.foo.mydomain.com | 10.193.67.91  | Houston 2  | 74.16 | joedoe   | Joe Doe | joedoe@mydomain.com |
    | 10390511 | VirtualServer | spzabclrhel72.foo.mydomain.com | 10.193.67.72  | Houston 2  | 74.16 | joedoe   | Joe Doe | joedoe@mydomain.com |
    +----------+---------------+--------------------------------+---------------+------------+-------+----------+---------+---------------------+

    $ softlayer report -s datacenter:hou02 domain:foo.mydomain.com -f json | jq
    [
        {
            "cost": 30.24,
            "datacenter": "Houston 2",
            "email": "joedoe@mydomain.com",
            "hostname": "spzabclcent1.foo.mydomain.com",
            "id": 10756577,
            "ip": "173.193.91.62",
            "name": "Joe Doe",
            "type": "VirtualServer",
            "username": "joedoe"
        },
        {
            "cost": 30.24,
            "datacenter": "Houston 2",
            "email": "joedoe@mydomain.com",
            "hostname": "spzabclcent2.foo.mydomain.com",
            "id": 10756579,
            "ip": "184.173.58.246",
            "name": "Joe Doe",
            "type": "VirtualServer",
            "username": "joedoe"
        },
        {
            "cost": 74.16,
            "datacenter": "Houston 2",
            "email": "joedoe@mydomain.com",
            "hostname": "spzabclrhel71.foo.mydomain.com",
            "id": 10390509,
            "ip": "173.193.67.91",
            "name": "Joe Doe",
            "type": "VirtualServer",
            "username": "joedoe"
        },
        {
            "cost": 74.16,
            "datacenter": "Houston 2",
            "email": "joedoe@mydomain.com",
            "hostname": "spzabclrhel72.foo.mydomain.com",
            "id": 10390511,
            "ip": "173.193.67.72",
            "name": "Joe Doe",
            "type": "VirtualServer",
            "username": "joedoe"
        }
    ]

    $ softlayer report -s datacenter:hou02 domain:foo.mydomain.com -f csv
    ID,TYPE,HOSTNAME,IP,DATACENTER,COST,USERNAME,NAME,EMAIL
    10756577,VirtualServer,spzabclcent1.foo.mydomain.com,173.193.91.62,Houston 2,30.24,joedoe,Joe Doe,joedoe@mydomain.com
    10756579,VirtualServer,spzabclcent2.foo.mydomain.com,184.173.58.246,Houston 2,30.24,joedoe,Joe Doe,joedoe@mydomain.com
    10390509,VirtualServer,spzabclrhel71.foo.mydomain.com,173.193.67.91,Houston 2,74.16,joedoe,Joe Doe,joedoe@mydomain.com
    10390511,VirtualServer,spzabclrhel72.foo.mydomain.com,173.193.67.72,Houston 2,74.16,joedoe,Joe Doe,joedoe@mydomain.com

    $ softlayer report -s datacenter:hou02 domain:foo.mydomain.com -c id ip hostname name
    +----------+--------------------------------+---------------+---------+
    | ID       | IP                             | HOSTNAME      | NAME    |
    +----------+--------------------------------+---------------+---------+
    | 10756577 | spzabclcent1.foo.mydomain.com  | 10.193.91.62  | Joe Doe |
    | 10756579 | spzabclcent2.foo.mydomain.com  | 10.173.58.246 | Joe Doe |
    | 10390509 | spzabclrhel71.foo.mydomain.com | 10.193.67.91  | Joe Doe |
    | 10390511 | spzabclrhel72.foo.mydomain.com | 10.193.67.72  | Joe Doe |
    +----------+--------------------------------+---------------+---------+

## Installation

**Requires Ruby installed and the bundler gem**

Currently, this is not yet in rubygems. Follow this steps to get it installed for now:

    git clone https://github.com/renier/softlayer-report-cli.git
    cd softlayer-report-cli.git
    bundle install
    bundle exec rake build
    gem install pkg/*.gem

## Usage

    $ softlayer help
    Commands:
      softlayer cancel ID ...   # cancel a softlayer system or systems by ID
      softlayer help [COMMAND]  # Describe available commands or one specific command
      softlayer report          # print a softlayer account report

    $ softlayer help report
    Usage:
      softlayer report

    Options:
      -u, [--username=USERNAME]        # SoftLayer username
      -p, [--api-key=API_KEY]          # SoftLayer api key
      -c, [--columns=one two three]    # List of columns to display
                                       # Default: id type hostname ip datacenter cost username name email
      -s, [--search=key:value]         # Search filters (e.g. datacenter:wdc01 domain:foobar.com)
      -f, [--format=FORMAT]            # Output format
                                       # Default: plain
                                       # Possible values: plain, csv, json
      -o, [--output-file=OUTPUT_FILE]  # Path to output file (default: stdout)

    print a softlayer account report

    $ softlayer help cancel
    Usage:
      softlayer cancel ID

    cancel a softlayer system by ID

Credentials can also be provided with a configuration file at _~/.softlayer_. See [softlayer-ruby](https://github.com/softlayer/softlayer-ruby/blob/master/lib/softlayer/Config.rb#L11) for details.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

