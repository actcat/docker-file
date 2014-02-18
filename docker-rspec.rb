# docker import command:
# docker import URL|- [REPOSITORY[:TAG]]

tar_container = "latest.tar"
container_repository = "latest"
container_tag = "new"

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

# 起動中のコンテナへのポートのバインディング
ssh_addr_str = `sudo docker port #{running_container_id} 22`
p ssh_addr_str.chomp!

ssh_addr = ssh_addr_str.split ':'
ssh_host = ssh_addr[0]
ssh_port = ssh_addr[1]
ssh_user = 'root'
ssh_password = 'screencast'

p "#{ssh_user}@#{ssh_host} -p #{ssh_port}"

Net::SSH.start(ssh_host, ssh_user, password: ssh_password, port: ssh_port) do |ssh|
  # capture all stderr and stdout output from a remote process
  ssh.open_channel do |channel|
    exec_results = []
    channel.exec("hostname") do |ch, success|
      abort "could not execute command" unless success
      channel.on_data do |ch, data|
        puts "got stdout: #{data}"
        exec_results << data
        channel.send_data "something for stdin\n"
      end

      channel.on_extended_data do |ch, type, data|
        puts "got stderr: #{data}"
      end

      channel.on_close do |ch|
        puts "channel is closing!"
      end
    end
    channel.exec 'echo $SHELL' do |ch, success|
      channel.on_data do |ch, data|
        exec_results << data
      end
    end


    puts "Welcome to "
    puts "SHELL = #{channel.exec 'echo $SHELL'}"
    puts "BASH = #{channel.exec 'echo $BASH'}"
    puts "PATH = #{channel.exec 'echo $PATH'}"

    # run multiple processes in parallel to completion
    # 実行スクリプトの作成
    dir_name = "/var/tmp/popcode"

    p 0
    script = "
cd #{dir_name}
echo hi
bundle check --path=vendor/bundle || bundle install --path=vendor/bundle  --clean
"

# スクリプトの実行
result = channel.exec "#{script}"
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
channel.exec "#{script}" do |ch, success|
end

# 実行スクリプトの作成
script = "
cd #{dir_name}
export RAILS_ENV='test'
export RACK_ENV='test'
bundle exec rake db:create db:schema:load --trace
"

# スクリプトの実行
result = channel.exec "#{script}"
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
result = channel.exec "#{script}"
p result

p 4

p channel
  end

  ssh.loop
end


# コンテナの停止
`sudo docker stop #{running_container_id}`

# コンテナの破棄
`sudo docker rm #{running_container_id}`
