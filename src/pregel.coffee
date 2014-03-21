
msgpack = require 'msgpack'
net = require 'net'
colors = require 'colors'

logger = {}
logger.level = 4 # bigger is more detail, 1:error, 2: warn, 3: error, 4: info, 0: silent
logger.error = (msg) -> if logger.level > 0 then console.log "[#{"error".red}]\t#{msg}" else 1
logger.warn =  (msg) -> if logger.level > 1 then console.log "[#{"warn".yellow}]\t#{msg}" else 1
logger.debug = (msg) -> if logger.level > 2 then console.log "[#{"debug".green}]\t#{msg}" else 1
logger.info =  (msg) -> if logger.level > -1 then console.log "[#{"info".grey}]\t#{msg}" else 1

class Master
  broadcast: (msg) ->
    for sock in this.workerSockets
      try
        sock[0].write msg
      catch e
        logger.warn "Error #{e} when broadcast to #{sock.remoteAddress}"

  ping: () ->
    logger.debug "Sent ping broadcast"
    for sock in this.workerSockets
      try
        sock[0].write msgpack "PING"
        # TODO
      catch e
        logger.warn "Error #{e}"

  loadGraph: () ->
    logger.error "This method need to be implemented in subclass!"
    process.exit(1) # exit error

  partition: () ->
    size = this.graph.length
    logger.info "Graph: #{JSON.stringify this.graph} size: #{size}"
    sizePerWorker = size / this.numOfWorker
    subgraphs = (this.graph.splice(i, i + sizePerWorker) for i in [0..this.numOfWorker]) # TODO: problem here ?

    # send subgraph to workers
    logger.info "Send graph to workers"
    for el, i in this.workerSockets
      logger.debug i
      el[0].write msgpack.pack ["GRAP", subgraphs[i]]

  handler: (msg, socket) ->
    logger.debug "#{socket.remoteAddress} sent: #{JSON.stringify msg}"
    switch msg[0]
      when "JOIN"
        this.workerSockets.push [socket, msg[1]]
        if this.workerSockets.length = this.numOfWorker
          # go to the next step, partition the graph
          this.status = "RUNNING"
          this.partition()
          this.broadcast msgpack.pack ["NEXT"]   # run the first step

      when "INFO" then 0
      when "DONE" then 2
      when "EXIT" then -1
      else socket.write "UNKNOWN TYPE\n"

  constructor: (@domain, @port, @numOfWorker=1) ->
    this.workerSockets = []
    this.status = "WAITING"
    # create a new server listen to port @port
    server = net.createServer this.port, (socket) =>
      if this.status != "WAITING"
        socket.end()
      else
        logger.debug "Received a connection from #{socket.remoteAddress}"
        socket.on 'data', (data) =>
          # call the handler for this connection
          this.handler(msgpack.unpack(data), socket)

    logger.info "Listening to #{this.domain}:#{this.port}"
    server.listen this.port, this.domain                # turn on server
    this.graph = this.loadGraph()

class Worker
  master_handler: (msg) ->
    logger.debug "Master sent: #{JSON.stringify msg}"
    switch msg[0]
      when "INFO" then this.workerList = msg[1]   #
      when "GRAP"
        this.graph = msg[1]        # a subgraph from master
        for e in this.graph
          this.vertices.push new this.Vertex
      when "NEXT" then this.compute()             # go to the next step

  compute: () ->

  pong: (socket) ->
    logger.debug "Sent pong reply"
    socket.write msgpack "PONG"

  peer_handler: (msg) ->
    logger.debug "Peer sent: #{msg}"
    switch msg[0]
      when "MESS" then this.NewInbox.push msg[1]
      else logger.error "Illegal message from peer"

  constructor: (ip, port, @Vertex) ->
    this.Outbox = []                # Buffer for going out messages
    this.AddrDic = {}               # Mapping Vertex -> IP:Port
    this.NewInbox = []
    this.CurInbox = []

    # create a peer server for listening
    this.peer_port = 1235  # default port (increased when fail)
    this.peer = net.createServer this.peer_port, (socket) =>
      socket.on 'data', (data) =>
        this.peer_handler msgpack.unpack data

    this.peer.on 'error', (e) =>
      this.peer_port = this.peer_port + 1
      this.peer.listen this.peer_port #retry again, ...

    this.peer.listen this.peer_port, () =>
      logger.debug "A peer listen to :#{this.peer_port}"

      # now, we'll connect to the master
      this.client = net.connect {host: ip, port: port}, () =>
        logger.info "Connected to Master"
        # send JOIN message
        this.client.write msgpack.pack ["JOIN", this.peer_port]

      this.client.on 'data', (data) =>
        logger.debug "received: #{JSON.stringify data}"
        this.master_handler msgpack.unpack data

      this.client.on 'close', (e) ->
        logger.debug "Close the connection with Master, exiting..."
        process.exit()

  sendMsg: (pack) ->
    # TODO: lookup ip addr of pack.receiver to send pack.msg
    alert "sendMsg is not implemented yet"

  addQueue: (pack) ->
    this.Outbox push pack

  run: (server, actor) ->
    alert "Connecting to server #{server}"
    # TODO

    alert "Doing jobs ..."
    # TODO: A while loop here to travel all vertices and super steps


class Vertex
  constructor: (@id, @worker, @adjEdges) ->

  sendMsgTo: (id, data) ->
    this.worker addQueue {receiver: id, msg: data}

  compute: (messages) ->
    alert "Override this method in your sub classes"

# export our classes to the outside world
module.exports.Master = Master
module.exports.Worker = Worker
module.exports.Vertex = Vertex
