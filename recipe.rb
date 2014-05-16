set :snmp_path, "#{recipes_path}/capi5k-snmp"

set :puppet_p, "https_proxy='http://proxy:3128' http_proxy='http://proxy:3128' puppet"
set :gem_p, "https_proxy='http://proxy:3128' http_proxy='http://proxy:3128' gem"
set :apt_get_p, "https_proxy='http://proxy:3128' http_proxy='http://proxy:3128' apt-get"

load "#{snmp_path}/roles.rb"
load "#{snmp_path}/roles_definitions.rb"
load "#{snmp_path}/output.rb"

before :snmp, :puppet

namespace :snmp do

  desc 'Deploy snmp on nodes'
  task :default do
    modules::install
    hiera::install
    transfer
    apply
  end

  namespace :modules do
    task :install, :roles => [:snmp] do
      set :user, "root"
      run "mkdir -p /etc/puppet/modules"
      upload("#{snmp_path}/module","/etc/puppet/modules/snmp", :via => :scp, :recursive => true)
   end

   task :uninstall, :roles => [:snmp] do
      set :user, "root"
      run "rm -rf /etc/puppet/modules/snmp"
   end

  end

  namespace :hiera do
    task :install, :roles => [:snmp] do
      set :user, "root"
      upload("#{snmp_path}/hiera","/tmp/hiera", :via => :scp, :recursive => true)
   end

   task :uninstall, :roles => [:snmp] do
      set :user, "root"
      run "rm -rf /tmp/hiera"
   end
  end

  task :transfer, :roles => [:snmp] do
    set :user, "root"
    upload("#{snmp_path}/templates/snmp.pp","/tmp/snmp.pp", :via => :scp)  
  end


  task :apply, :roles => [:snmp] do
    set :user, "root"
    run "#{puppet_p} apply /tmp/snmp.pp --hiera_config=/tmp/hiera/config.yml"
  end

end

