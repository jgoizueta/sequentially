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
  @error (err) ->
    console.log "ERROR", err
```

Or, since version 2.1, you can simply use the `scope` options
that defines the `this` value with which the steps are executed:

```coffeescript
sequentially = require 'sequentially'
sequentially (scope: this) ->
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
  @error (err) ->
    console.log "ERROR", err
```
