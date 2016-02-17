class Sequentially
  constructor: ->
    @steps = []
    @error_handler = null
  step: (f) ->
    @steps.push f
  on_error: (f) ->
    @error_handler = f
  next: (args...) ->
    @steps.shift()? args...
  run: ->
    sequence = this
    done_handler = (err, args...) ->
      if err
        if sequence.error_handler
          sequence.error_handler err
        else
          throw err
      else
        args.push done_handler
        sequence.next args...
    @next done_handler

sequentially = (f) ->
  sequence = new Sequentially
  f.call sequence
  sequence.run()

module.exports = sequentially
