
class Master
  constructor: (@name, @port) ->

class Worker
  constructor: (@id, @port) ->

class Vertex
  constructor: (@id) ->

  sendMsgTo: (id, data) ->
    alert "TODO: Not implemented yet!"

  compute: (messages) ->
    alert "Override this method in your sub classes"

  getAdjEdges: () ->
    []  # return empty list


module.exports.Master = Master
module.exports.Worker = Worker
module.exports.Vertex = Vertex
