ssh_host = 'localhost'
ssh_port = '49166'
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
  puts "which ruby => #{ssh.exec! 'which ruby'}"
  puts "which rvm => #{ssh.exec! 'which rvm'}"
  puts "ruby -v => #{ssh.exec! 'ruby -v'}"

  channel = ssh.open_channel do |ch|
    ch.exec "source /usr/local/rvm/scripts/rvm; echo 'path changing...';" do |ch, success|
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

    channel.wait

    ch.exec "echo $PATH; echo 'path changed';" do |ch, success|
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

    channel.wait
  end

  channel.wait
end
