package :init do
  description "Initial Ubuntu configuration"
  requires :no_apache
  requires :no_exim
  requires :build_essential
  requires :imagemagick
  requires :wkhtmltopdf
end

package :no_apache do
  run "/etc/init.d/apache2 stop"
  run "apt-get remove apache2*"
end

package :no_exim do
  run "apt-get remove exim4*"
end

package :build_essential do
  description 'Build tools'
  apt 'build-essential' do
    pre :install, 'apt-get update'
  end
end

package :imagemagick do
  description "Image Magick"
  apt 'imagemagick librmagick-ruby'
  verify do
    has_executable "convert"
  end
end

package :wkhtmltopdf do
  description "PDFKit requires wkhtmltopdf"
  apt 'build-essential openssl xorg libssl-dev' do
    post :install, "wget http://wkhtmltopdf.googlecode.com/files/wkhtmltopdf-0.9.9-static-amd64.tar.bz2"
    post :install, "tar xvjf wkhtmltopdf-0.9.9-static-amd64.tar.bz2"
    post :install, "mv wkhtmltopdf-amd64 /usr/local/bin/wkhtmltopdf"
    post :install, "chmod +x /usr/local/bin/wkhtmltopdf"
  end
  verify do
    has_executable "wkhtmltopdf"
  end
end
