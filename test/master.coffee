P = require '..'

class Master extends P.Master
  loadGraph: () ->
    # return a graph
    [ [0, 1, 3], [2, 3] ]

try
  master = new Master('localhost', 1234)
catch err
  console.log "Exception #{err}"
