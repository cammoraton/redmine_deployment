redmine_deployment
==================

Deployment Plugin For Redmine Protoype.
See readme.rdoc for more detailed stuffs.

Installation:
Get a rails environment up and running.
Download redmine from redmine.org, git clone this into the plugins directory as deployment.
Configure redmine.  You just need to edit database.yml.  SQLite should be fine.
Do the normal rails initalization stuff (You can hard set env by editing environment.rb, there used to be a
commented out bit to default to production),
bundle install
rake generate_secret_token
rake db:migrate (This SHOULD set up delayed jobs)
rake redmine:plugins:migrate (which will run the migrations in this plugin)

And then start webbrick:
ruby script/rails server

For the jobs to run you need to run a seperate rake task.
script/delayed_job -n <workers> start
to run it as a daemon or
rake jobs:work
to be able to just ctrl-c out of it

The jobs at present are just update status, sleep, update status.  Will be linked in with mcollective-svn for
remote scm operations.  I'm actually good at that kind of thing, it's just glorified scripting after all.
