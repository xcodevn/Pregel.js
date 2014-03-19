
class Master
  constructor: (@name, @port) ->

class Worker
  constructor: (@id, @port) ->
    this.Outbox = []                # Buffer for going out messages
    this.AddrDic = {}               # Mapping Vertex -> IP:Port

  sendMsg: (pack) ->
    # TODO: lookup ip addr of pack.receiver to send pack.msg
    alert "sendMsg is not implemented yet"

  addQueue: (pack) ->
    this.Outbox append(pack)

  run: (server, actor) ->
    alert "Connecting to server #{server}"
    # TODO

    alert "Doing jobs ..."
    # TODO: A while loop here to travel all vertices and super steps


class Vertex
  constructor: (@id) ->

  sendMsgTo: (id, data) ->
    this.worker addQueue {receiver: id, msg: data}

  compute: (messages) ->
    alert "Override this method in your sub classes"

  setWorker: (worker) ->
    this.worker = worker

  getAdjEdges: () ->
    []  # return empty list


# export our classes to the outside world
module.exports.Master = Master
module.exports.Worker = Worker
module.exports.Vertex = Vertex
