#
# Cookbook Name :: GraphicsMagick
# Recipe :: default
#

#GraphicsMagick Recipe

include_recipe 'build-essential'

file_name   = "GraphicsMagick-#{node['graphicsmagick']['version']}"
folder_name = node['graphicsmagick']['version'].split('.')[0..1].join('.')
file_path   = "#{Chef::Config[:file_cache_path]}/#{file_name}.tar.gz"

%w(libjpeg-turbo8-dev libjasper-dev liblcms1-dev libx11-dev libwmf-dev libsm-dev libice-dev libxext-dev x11proto-core-dev libxml2-dev libfreetype6-dev libexif-dev libbz2-dev libtiff-dev zlib1g-dev libpng-dev).each do |dep|
  package dep
end

remote_file file_path  do
  source "#{node['graphicsmagick']['url']}/#{folder_name}/#{file_name}.tar.gz"
  mode   00644

  not_if "test -f #{file_path}"
end

bash 'Compiling GraphicsMagick' do
  cwd Chef::Config[:file_cache_path]
  code <<-COMMMANDS
  tar -zxf #{file_name}.tar.gz
	cd #{file_name}
	./configure
	make && make install
  COMMMANDS
  not_if do
    version = `gm version 2>&1`
    version.include?(node['graphicsmagick']['version']) && version =~ /JPEG\s+yes/ && version =~ /PNG\s+yes/
  end
end
