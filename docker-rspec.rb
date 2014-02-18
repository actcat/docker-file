# docker import command:
# docker import URL|- [REPOSITORY[:TAG]]

tar_container = "latest.tar"
container_repository = "latest"
container_tag = "new"

# TODO: importを使うとディスクが非常に消費されるため、各ユーザ環境は既存イメージからの派生にする必要がある

if File.exist?(tar_container)
  # ローカルにファイルがある場合
  `cat #{tar_container} | sudo docker import - #{container_repository}:#{container_tag}`
else
  # ローカルにファイルがない場合
  `sudo docker import #{tar_container_url}`
end

###
# dockerコンテナに独自のssh設定を施す

# TODO: ssh設定用ファイルをinsert

# TODO: ssh設定の実行

# TODO: コンテナIDの取得

###
# dockerコンテナを起動してsshポートを立ち上げる

# コンテナの起動とsshポートの開放
running_container_id = `sudo docker run -d -p 22 #{container_repository}:#{container_tag} /usr/sbin/sshd -D`
p running_container_id.chomp!

begin
  # 起動中のコンテナへのポートのバインディング
  ssh_addr_str = `sudo docker port #{running_container_id} 22`
  p ssh_addr_str.chomp!


  ssh_addr = ssh_addr_str.split ':'
  ssh_host = ssh_addr[0]
  ssh_port = ssh_addr[1]
  ssh_user = 'root'
  ssh_password = 'screencast'

  p "#{ssh_user}@#{ssh_host} -p #{ssh_port}"

  require 'net/ssh'
  Net::SSH.start(ssh_host, ssh_user, password: ssh_password, port: ssh_port) do |ssh|
    # capture all stderr and stdout output from a remote process
    exec_results = []
    puts "Welcome to #{ssh.exec! 'hostname'}"
    puts "SHELL = #{ssh.exec! 'echo $SHELL'}"
    puts "BASH = #{ssh.exec! 'echo $BASH'}"
    puts "PATH = #{ssh.exec! 'echo $PATH'}"
    puts "PATH = #{ssh.exec! 'which ruby'}"
    puts "PATH = #{ssh.exec! 'which rvm'}"
    puts "PATH = #{ssh.exec! 'ruby -v'}"

    channel = ssh.open_channel do |ch|
      ch.exec "source /usr/local/rvm/scripts/rvm" do |ch, success|
        raise "could not execute command" unless success

        # "on_data" is called when the process writes something to stdout
        ch.on_data do |c, data|
          $stdout.print data
          puts data
        end

        # "on_extended_data" is called when the process writes something to stderr
        ch.on_extended_data do |c, type, data|
          $stderr.print data
          puts data
        end

        ch.on_close { puts "done!" }
      end

      ch.exec "#{ssh.exec! 'echo $PATH'}" do |ch, success|
        raise "could not execute command" unless success

        # "on_data" is called when the process writes something to stdout
        ch.on_data do |c, data|
          $stdout.print data
          puts data
        end

        # "on_extended_data" is called when the process writes something to stderr
        ch.on_extended_data do |c, type, data|
          $stderr.print data
          puts data
        end

        ch.on_close { puts "done!" }
      end

    end

    channel.wait

    puts "PATH = #{ssh.exec! 'echo $PATH'}"
  end

  Net::SSH.start(ssh_host, ssh_user, password: ssh_password, port: ssh_port) do |ssh|
    # run multiple processes in parallel to completion
    # 実行スクリプトの作成
    puts "PATH = #{ssh.exec! 'echo $PATH'}"

    dir_name = "/var/tmp/popcode"

    p 0
    script = "
cd #{dir_name}
echo hi
bundle check --path=vendor/bundle || bundle install --path=vendor/bundle  --clean
"

# スクリプトの実行
result = ssh.exec! "#{script}"
p result
p 1

#
script = "
cd #{dir_name}
mkdir -p config
echo 'test:
  host: localhost
  username: ubuntu
  adapter: sqlite3
  database: circle_ruby_test
  pool: 5
  timeout: 5000
' > config/database.yml
"
# スクリプトの実行
ssh.exec! "#{script}"

# 実行スクリプトの作成
script = "
cd #{dir_name}
export RAILS_ENV='test'
export RACK_ENV='test'
bundle exec rake db:create db:schema:load --trace
"

# スクリプトの実行
result = ssh.exec! "#{script}"
p result

p 3

# 実行スクリプトの作成
script = "
cd #{dir_name}
export RAILS_ENV='test'
export RACK_ENV='test'
bundle exec rspec spec --format progress
"

# スクリプトの実行
result = ssh.exec! "#{script}"
p result

p 4
  end
rescue => e
  p e
end

# コンテナの停止
`sudo docker stop #{running_container_id}`

# コンテナの破棄
`sudo docker rm #{running_container_id}`
