require "socket"

class Server
  def initialize(ip, port)
    @server = TCPServer.open(ip, port)
    @connections = Hash.new
    @rooms = Hash.new
    @clients = Hash.new

    @connections[:server] = @server
    @connections[:rooms] = @rooms
    @connections[:clients] = @clients
    puts "Running the server"
    run
  end

  def run
    loop{
      #for each user connected and accepted by server, it will create a new thread object
      #and which pass the connected client as an instance to the block
      Thread.start(@server.accept) do |client|
        nick_name = client.gets.chomp.to_sym

        @connections[:clients].each do |other_name, other_client|
          if nick_name == other_name || client == other_client
            client.puts "This username already exists."
            Thread.kill self
          end
        end

        puts "#{nick_name} #{client}"
        @connections[:clients][nick_name] = client
        client.puts "Connection established, thank you for joining! Happy chatting."
        listen_user_messages(nick_name, client)
  
      end

    }.join
  end

  def listen_user_messages(username, client)
    loop{
      #gets the clients messages
      msg = client.gets.chomp
      #send a broadcast messae, a message for all connected users, but not to its self
      @connections[:clients].each do |other_name, other_client|
        unless other_name == username
          other_client.puts "#{username.to_s}:#{msg}"
        end
      end
    }
  end

end
Server.new("localhost", 3000)