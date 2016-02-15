class Sequentially
  constructor: ->
    @steps = []
    @error_handler = null
    @context = new SequentialContext(this)
  step: (f) ->
    @steps.push f
  error: (f) ->
    @error_handler = f
  run: ->
    @_call_next()
  _call_next: (args) ->
    @steps.shift?().apply @context, args
  _raise_error: (err) ->
    @steps = []
    if @error_handler
      @error_handler err
    else
      throw err

  class SequentialContext
    constructor: (sequence) ->
      @sequence = sequence
    next: (args...) =>
      @sequence._call_next(args)
    error: (err) ->
      @sequence._raise_error(err)

sequentially = (f) ->
  sequence = new Sequentially
  f.call sequence
  sequence.run()

module.exports = sequentially
