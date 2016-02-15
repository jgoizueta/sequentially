# sequentially

#### Declare asynchronous operations sequentially in CooffeeScript

[![NPM](https://nodei.co/npm/sequentially.png)](https://nodei.co/npm/sequentially/)

This module allows writing deeply-nested asynchronous
code in CoffeeScript in a sequential manner.

This is similar to [step](https://www.npmjs.com/package/step)
or [async-queue](https://www.npmjs.com/package/async-queue),
but designed to be used with CoffeeScript.

Steps to be executed sequentially are defined in a declarative manner:

```coffeescript
sequentially = require 'sequentially'
sequentially ->
  @step ->
    console.log "FIRST"
    @next 1
  @step (value) ->
    console.log "SECOND: ", value
    @next value + 1
  @step (value) ->
    console.log "THIRD", value
    setTimeout @next, 2000
  @step (value) ->
    console.log "FOURTH", value
  @error (err) ->
    console.log "ERROR", err
```

Note the optional `error` function that will handle errors
that occur at any point in the sequence.

Each step in the sequence should use `@next`
(i.e. `this.next`) to execute and pass arguments to the next step.
Note that the functions passed to `step` and `error` are executed
with `this` pointing to an object that controls the sequential
execution, so if you need to access the outer `this` you should
assign it to a local variable:

```coffeescript
sequentially = require 'sequentially'
self = this
sequentially ->
  @step ->
    console.log "FIRST"
    self.f()
    @next 1
  @step (value) ->
    console.log "SECOND: ", value
    @next value + 1
  @step (value) ->
    console.log "THIRD", value
    setTimeout @next, 2000
  @step (value) ->
    console.log "FOURTH", value
  @error (err) ->
    console.log "ERROR", err
```

Also because of this, you need to use the sequence `this`
to use the `next` function, note the use of the fat arrow here:

```coffeescript
sequentially = require 'sequentially'
sequentially ->
  @step ->
    console.log "FIRST"
    @next 1
  @step (value) ->
    console.log "SECOND: ", value
    @next value + 1
  @step (value) ->
    console.log "THIRD", value
    setTimeout (=> @next value + 1), 2000 # use a fat arrow here!
  @step (value) ->
    console.log "FOURTH", value
  @error (err) ->
    console.log "ERROR", err
```

To abort the sequence and call the error handler use the `@error`
method which is similar to `@next`

```coffeescript
sequentially = require 'sequentially'
sequentially ->
  @step ->
    console.log "FIRST"    
    @next 1
  @step (value) ->
    console.log "SECOND: ", value
    if value > 0
      @error 'bad value'
    else
      @next value + 1
  @step (value) ->
    console.log "THIRD", value
    setTimeout (=> @next value + 1), 2000 # use a fat arrow here!
  @step (value) ->
    console.log "FOURTH", value
  @error (err) ->
    console.log "ERROR", err
```
