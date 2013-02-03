redmine_deployment
==================

Deployment Plugin For Redmine Protoype.  See readme.rdoc for more detailed stuffs.

Installation:

1. Get a rails environment up and running.
2. Download redmine from redmine.org, git clone this into the plugins directory as deployment.
3. Configure redmine.  You just need to edit database.yml.  SQLite should be fine.
4. Do the normal rails initalization stuff (You can hard set env by editing environment.rb, there used to be a
commented out bit to default to production),
5. bundle install
6. rake generate_secret_token
7. rake db:migrate (This SHOULD set up delayed jobs)
8. rake redmine:plugins:migrate (which will run the migrations in this plugin)
9. ruby script/rails server

For the jobs to run you need to run a seperate rake task.

script/delayed_job -n <workers> start

or

rake jobs:work

The jobs at present are just update status, sleep, update status.  Will be linked in with mcollective-svn for
remote scm operations.  I'm actually good at that kind of thing, it's just glorified scripting after all.
