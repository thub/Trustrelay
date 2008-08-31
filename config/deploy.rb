set :application, "net"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/var/www/apps/#{application}"
set :user, "thub"
set :runner,nil
set :use_sudo, true

# If you aren't using Subversion to manage your source code, specify
# your SCM below:

set :scm, :cvs
set :repository, "/home/cvs"
set :scm_module, "net"
set :revision, :head

role :app, "trustrelay.com"
role :web, "trustrelay.com"
role :db,  "trustrelay.com", :primary => true


after "deploy:update_code", :fix_script_perms
after "deploy:setup", :fix_directory_perms


  task :fix_script_perms do
    run "chmod 755 #{latest_release}/script/spin"
    run "chmod 755 #{latest_release}/script/process/reaper"
    run "chmod 755 #{latest_release}/script/process/spawner"  

  end

  task :fix_directory_perms do
    run "sudo chown -R  cvs /var/www/apps/net"
    run "sudo chgrp -R  cvs /var/www/apps/net"
  end