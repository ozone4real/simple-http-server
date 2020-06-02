require 'socket'                 # Get sockets from stdlib

class Request
  def initialize(request)
    @request = request
  end
  def parse
     method, path = @request.lines[0].split
     {
       method: method,
       path: path,
       headers: parse_headers
     }
  end

  def parse_headers
    @request.lines[1..-1].each_with_object({}) do |line, obj|
      key, val = line.split(': ')
      obj[key] = val
      obj
    end
  end
end

class Response
  def initialize(client)
    @client = client
  end
  def send(code:, data: "")
    response = "HTTP/1.1 #{code}\r\n" +
    "Content-Length: #{data.size}\r\n" +
    "\r\n" +
    "#{data}\r\n"
    @client.write(response)
  end
end

class Server
  PUBLIC_PATH = "/Users/ezenwaogbonna/Desktop/SEND-IT-APP/UI"
  def self.start
    server = TCPServer.open(2000)    # Socket to listen on port 2000
    puts "Listening on port 2000...."
    loop do
      client = server.accept        # Wait for a client to connect                 # Servers run forever
      Thread.new do
        begin
          request = Request.new(client.readpartial(1000)).parse
          request_path = request[:path]
          response = Response.new(client)
          response_data = prepare_response(request_path)
          response.send(response_data)
        rescue EOFError
          client.close                # Disconnect from the client
        end
      end
    end
  end

  def self.prepare_response(url)
    unless File.exist? path(url)
      return { code: 404, data: "<h1>Page Not Found</h1>"}
    end
    { code: 200, data: File.read(path(url)) }
  end

  def self.path(url)
    return "#{PUBLIC_PATH}/index.html" if url == '/'
    "#{PUBLIC_PATH}/#{url}.html"
  end

  def stop
    
  end
end

Server.start
