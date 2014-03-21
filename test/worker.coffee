P = require '..'
class Worker extends P.Worker
  compute: (msgLst) ->
    console.log "Hello world"
try
  worker = new P.Worker("127.0.0.1", 1234)
catch e
  console.log "Exception #{e}"
