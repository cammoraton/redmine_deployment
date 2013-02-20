begin
  require 'mcollective'
rescue LoadError => e
  # No mcollective, probably because the stomp gem is absent
end

module RemoteSCM
  class McollectiveSCM
    include MCollective::RPC

    def initialize(node, path)
      options =  MCollective::Util.default_options
      options[:config] = 'plugins/deployment/config/mcollective.cfg'
      @mc = rpcclient("subversion", :options => options)
      @mc.identity_filter node
      @path = path
    end
    
    def info
      reply_hash = Hash.new
      @mc.info(:path => @path) do |resp|
        begin
          reply_hash[resp[:senderid]] = Hash.new
          reply_hash[resp[:senderid]][:data] = resp[:body][:data]
          reply_hash[resp[:senderid]][:statuscode] = resp[:body][:statuscode]
          reply_hash[resp[:senderid]][:statusmsg] = resp[:body][:statusmsg]
        rescue RPCError => e
          puts e
        end
      end
      reply_hash
    end
  end
  
  class SecureShellSCM

  end  
end
