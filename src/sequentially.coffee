class Sequentially
  constructor: (options) ->
    @steps = []
    @error_handler = null
    @scope = options.scope
  step: (f) ->
    @steps.push f
  on_error: (f) ->
    @error_handler = f
  next: (args...) ->
    @steps.shift()?.apply @scope, args
  run: ->
    sequence = this
    done_handler = (err, args...) ->
      if err
        if sequence.error_handler
          sequence.error_handler.call sequence.scope, err
        else
          throw err
      else
        args.push done_handler
        sequence.next args...
    @next done_handler

sequentially = (options, f) ->
  unless f
    f = options
    options = {}
  sequence = new Sequentially(options)
  if f.length == 0
    f.call sequence
  else if f.length == 1
    f sequence
  else
    step = (args...) -> sequence.step args...
    error = (args...) -> sequence.on_error args...
    f step, error
  sequence.run()

module.exports = sequentially
