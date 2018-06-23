Dir.chdir("#{ENV['HOME']}/torifuku_faucet") do
  puts 'git pull'
  `git pull`

  puts 'RAILS_ENV=production bin/rails db:migrate'
  `RAILS_ENV=production bin/rails db:migrate`

  puts 'RAILS_ENV=production bin/rails assets:precompile'
  `RAILS_ENV=production bin/rails assets:precompile`

  puts "sudo cp -r #{ENV['HOME']}/torifuku_faucet/public /srv/www"
  `sudo cp -r #{ENV['HOME']}/torifuku_faucet/public /srv/www`

  puts 'sudo chown -R nginx /srv/www/public/'
  `sudo chown -R nginx /srv/www/public/`

  puts 'kill -9 pid'
  line = `ps -ef | grep puma`&.split("\n").select { |line| line =~ /puma.+tcp/ }.first&.split
  `kill -9 #{line[1]}` if line
end

puts "cd #{ENV['HOME']}/torifuku_faucet; nohup bin/rails server -e production -p 3000 &"
puts 'execute!!!'