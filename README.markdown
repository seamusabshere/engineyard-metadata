# engineyard-metadata

Presents a simple interface to get metadata about your EngineYard AppCloud instances running on Amazon EC2.

## Purpose

To define a simple interface to useful metadata (passwords, IP addresses, etc.) that is otherwise buried deep inside EngineYard's chef config files and various API calls.

## Examples

Here's the current method list:

    EY.metadata.app_master
    EY.metadata.app_name
    EY.metadata.app_servers
    EY.metadata.app_slaves
    EY.metadata.current_path
    EY.metadata.database_host
    EY.metadata.database_name
    EY.metadata.database_password       (only works from cloud instances)
    EY.metadata.database_username
    EY.metadata.db_master
    EY.metadata.db_servers
    EY.metadata.db_slaves
    EY.metadata.environment_name
    EY.metadata.mysql_command           (only works from cloud instances)
    EY.metadata.mysqldump_command       (only works from cloud instances)
    EY.metadata.present_instance_id     (only works from cloud instances)
    EY.metadata.present_instance_role   (only works from cloud instances)
    EY.metadata.present_public_hostname (only works from cloud instances)
    EY.metadata.present_security_group  (only works from cloud instances)
    EY.metadata.repository_uri
    EY.metadata.shared_path
    EY.metadata.solo
    EY.metadata.ssh_aliases
    EY.metadata.ssh_password            (only works from cloud instances)
    EY.metadata.ssh_username
    EY.metadata.stack_name
    EY.metadata.utilities

## public\_hostname, amazon\_id, etc.

Thanks to Nick Marden, you can do things like:

    ?> EY.metadata.app_servers('amazon_id')
    >> [ 'i-ff17d493', 'i-c217d423' ]

By default, you get the public hostname.

## Use

See the documentation at (the engineyard-metadata documentation}[http://rubydoc.info/gems/engineyard-metadata].

### When you're executing this gem from INSIDE the cloud

When you're executing the gem from your instances, you don't have to configure anything. Just require the gem.

If you see

    Errno::EACCES: Permission denied - /etc/chef/dna.json

then I suggest adding something like this to `deploy/before_bundle.rb`

    sudo 'chmod a+r /etc/chef/dna.json'

or find some other way to make the file readable.

The Engine Yard recipes will often reset the permissions on the file, so you can periodically fix that using
a custom chef recipe like this:

    # Only run on app server instances.
    if ['app','app_master'].include?(node[:instance_role]) then
      cron "Make /etc/chef/dna.json readable" do 
        minute "*/5" 
        command "chmod a+r /etc/chef/dna.json" 
      end 
    end

### When you're executing this gem from OUTSIDE the cloud

You must...

* have `~/.eyrc` or set `EY.metadata.ey_cloud_token=` or set `ENV['EY_CLOUD_TOKEN']`.
* execute the gem from the local copy of your application's repo or set `EY.metadata.environment_name=` or set `ENV['EY_ENVIRONMENT_NAME']`.

### Where the methods are defined

Metadata getters are defined directly on `EY.metadata` (which in turn delegates out to various adapters). Even if EngineYard changes the structure of the config files or Amazon EC2's API changes, these methods will stay the same.

    [...]
    >> require 'rubygems'
    [...]
    >> require 'engineyard-metadata'
    [...]
    >> EY.metadata.database_host
    => "external_db_master.compute-1.amazonaws.com"
    >> EY.metadata.app_servers
    => [ 'app_1.compute-1.amazonaws.com' , 'app_master.compute-1.amazonaws.com' ]
    >> EY.metadata.db_servers
    => [ 'db_master.compute-1.amazonaws.com', 'db_slave_1.compute-1.amazonaws.com' ]
    [...and many more...]

## SSH alias helper

You can put the output of `ey_ssh_aliases` into `~/.ssh/config`:

    $ EY_ENVIRONMENT_NAME=my_env ey_ssh_aliases 
    Host my_env-app_master
      Hostname ec2-11-11-111-11.compute-1.amazonaws.com
      User deploy
      StrictHostKeyChecking no

    Host my_env-db_master
      Hostname ec2-111-11-11-11.compute-1.amazonaws.com
      User deploy
      StrictHostKeyChecking no

## Known issues

* Doesn't work with multiple apps per environment. [FIXED!]
* It's not always clear what environment you're running in. For example, you say `EY.metadata.something` and you're just supposed to know what environment you're in. You can use `.environment_name=`, but you might not remember.
* There are no factory methods. If we fully fleshed this out, it might be like `my_env = EY::Environment.find('my_env')` and `my_app_master = my_env.app_master`. Not sure that complexity would add a lot of value.

## History

This is the second generation of http://rubygems.org/gems/ey_cloud_awareness.

## Sample test output

    engineyard-metadata (master) $ rake
    
    EY.metadata
      being executed on an EngineYard AppCloud (i.e. Amazon EC2) instance
        it should behave like it does in all execution environments
          by getting the database username
          by getting the database name
          by getting the database host
          by getting the ssh username
          by getting the app server hostnames
          by getting the db server hostnames
          by getting the utilities hostnames
          by getting the app master hostname
          by getting the db master hostname
          by getting the db slave hostnames
          by getting the app slave hostnames
          by getting the solo hostname
          by getting the environment name
          by getting the stack name
          by getting the repository URI
          by getting the app name
          by getting the current path
          by getting the shared path
          by getting helpful ssh aliases
        it should behave like it's executing inside the cloud
          by refusing to get the list of all environment names
          by getting the present instance ID
          by getting the present instance role (as a string)
          by getting the present public hostname
          by getting the present security group
          by getting the database password
          by getting the ssh password
          by getting the mysql command
          by getting the mysqldump command
      being executed from a developer/administrator's local machine
        controlled with environment variables
          it should behave like it does in all execution environments
            by getting the database username
            by getting the database name
            by getting the database host
            by getting the ssh username
            by getting the app server hostnames
            by getting the db server hostnames
            by getting the utilities hostnames
            by getting the app master hostname
            by getting the db master hostname
            by getting the db slave hostnames
            by getting the app slave hostnames
            by getting the solo hostname
            by getting the environment name
            by getting the stack name
            by getting the repository URI
            by getting the app name
            by getting the current path
            by getting the shared path
            by getting helpful ssh aliases
          it should behave like it's executing outside the cloud
            by getting the list of all environment names
            by refusing to get the present instance ID
            by refusing to get the present instance role (as a string)
            by refusing to get the present public hostname
            by refusing to get the present security group
            by refusing to get the database password
            by refusing to get the ssh password
            by refusing to get the mysql command
            by refusing to get the mysqldump command
        controlled with attr writers
          it should behave like it does in all execution environments
            by getting the database username
            by getting the database name
            by getting the database host
            by getting the ssh username
            by getting the app server hostnames
            by getting the db server hostnames
            by getting the utilities hostnames
            by getting the app master hostname
            by getting the db master hostname
            by getting the db slave hostnames
            by getting the app slave hostnames
            by getting the solo hostname
            by getting the environment name
            by getting the stack name
            by getting the repository URI
            by getting the app name
            by getting the current path
            by getting the shared path
            by getting helpful ssh aliases
          it should behave like it's executing outside the cloud
            by getting the list of all environment names
            by refusing to get the present instance ID
            by refusing to get the present instance role (as a string)
            by refusing to get the present public hostname
            by refusing to get the present security group
            by refusing to get the database password
            by refusing to get the ssh password
            by refusing to get the mysql command
            by refusing to get the mysqldump command
        depending on .eyrc
          it should behave like it does in all execution environments
            by getting the database username
            by getting the database name
            by getting the database host
            by getting the ssh username
            by getting the app server hostnames
            by getting the db server hostnames
            by getting the utilities hostnames
            by getting the app master hostname
            by getting the db master hostname
            by getting the db slave hostnames
            by getting the app slave hostnames
            by getting the solo hostname
            by getting the environment name
            by getting the stack name
            by getting the repository URI
            by getting the app name
            by getting the current path
            by getting the shared path
            by getting helpful ssh aliases
          it should behave like it's executing outside the cloud
            by getting the list of all environment names
            by refusing to get the present instance ID
            by refusing to get the present instance role (as a string)
            by refusing to get the present public hostname
            by refusing to get the present security group
            by refusing to get the database password
            by refusing to get the ssh password
            by refusing to get the mysql command
            by refusing to get the mysqldump command

    Finished in 0.95816 seconds
    112 examples, 0 failures

## Copyright

Copyright (c) 2012 Seamus Abshere. See LICENSE for details.
