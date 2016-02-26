# sequentially

#### Declare asynchronous operations sequentially in CooffeeScript

[![NPM](https://nodei.co/npm/sequentially.png)](https://nodei.co/npm/sequentially/)

This module allows writing deeply-nested asynchronous
code in CoffeeScript in a sequential manner.

This is intended to be used from CoffeScript, as it takes advantage
of that language's syntax. Other modules such as
[Async](https://www.npmjs.com/package/async) (`async.series`),
[Step](https://www.npmjs.com/package/step)
or [async-queue](https://www.npmjs.com/package/async-queue)
are probably a better match for JavaScript.

Steps to be executed sequentially are defined in a declarative manner:

```coffeescript
sequentially = require 'sequentially'
sequentially ->
  @step (done) ->
    console.log "FIRST"
    done null, 1
  @step (value, done) ->
    console.log "SECOND: ", value
    done null, value + 1
  @step (value, done) ->
    console.log "THIRD", value
    setTimeout done, 2000, null, value
  @step (value, done) ->
    console.log "FOURTH", value
    done null
  @on_error (err) ->
    console.log "ERROR", err
```

Note the optional `on_error` function that will handle errors
that occur at any point in the sequence.

Each step in the sequence should use its `done` parameter
to execute and pass arguments to the next step.

The first argument passed to `done` should be not null to
in indicate an error that will abort the sequence and execute
the error handler.

Note that the function passed to `sequentially` is executed
with `this` pointing to an special object. So, if you need
to access the outer `this` you should assign it to a local variable:

```coffeescript
sequentially = require 'sequentially'
self = this
sequentially ->
  @step (done) ->
    console.log "FIRST"
    self.f()
    done null, 1
  @step (value, done) ->
    console.log "SECOND: ", value
    done value + 1
  @step (value, done) ->
    console.log "THIRD", value
    setTimeout @next, 2000, null, value
  @step (value, done) ->
    console.log "FOURTH", value
    done
  @on_error (err) ->
    console.log "ERROR", err
```

Alternatively, you can use the `scope` option
that defines the `this` value with which the steps are executed:

```coffeescript
sequentially = require 'sequentially'
sequentially scope: this, ->
  @step (done) ->
    console.log "FIRST"
    @f() # 'this' has the same value as in the outer scope
    done null, 1
  @step (value, done) ->
    console.log "SECOND: ", value
    done value + 1
  @step (value, done) ->
    console.log "THIRD", value
    setTimeout @next, 2000, null, value
  @step (value, done) ->
    console.log "FOURTH", value
    done
  @on_error (err) ->
    console.log "ERROR", err
```

Instead of having the `step` and `on_error` methods
available through `this`, a *block* parameter can be
used like this:

```coffeescript
sequentially = require 'sequentially'
sequentially (block) ->
  block.step (done) ->
    console.log "FIRST"
    done null, 1
  block.step (value, done) ->
    console.log "SECOND", value
    setTimeout done, 2000, null, value
  block.step (value, done) ->
    console.log "THIRD", value
    done null
  block.on_error (err) ->
    console.log "ERROR", err
```

Separate arguments for the `step` and `on_error` methods
can be used instead, also:

```coffeescript
sequentially = require 'sequentially'
sequentially (step, on_error) ->
  step (done) ->
    console.log "FIRST"
    done null, 1
  step (value, done) ->
    console.log "SECOND", value
    setTimeout done, 2000, null, value
  step (value, done) ->
    console.log "THIRD", value
    done null
  on_error (err) ->
    console.log "ERROR", err
```

This way of avoiding fixing the `this` of the
step and error functions
allows using the fat arrow operator effectively:

```coffeescript
sequentially = require 'sequentially'
sequentially (step, on_error) =>
  step (done) =>
    console.log "FIRST"
    @f() # 'this' has the same value as in the outer scope
    done null, 1
  step (value, done) =>
    console.log "SECOND: ", value
    done value + 1
  step (value, done) =>
    console.log "THIRD", value
    setTimeout @next, 2000, null, value
  step (value, done) =>
    console.log "FOURTH", value
    done
  on_error (err) =>
    console.log "ERROR", err
```
