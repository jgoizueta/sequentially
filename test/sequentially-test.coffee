assert = require "assert"

describe 'sequentially', ->
  sequentially = require '../lib/sequentially'

  it "should execute synchronous operations sequentially", (done) ->
    data  = []
    sequentially ->
      @step ->
        v = 1
        data.push v
        @next v
      @step (v) ->
        v += 1
        data.push v
        @next v
      @step (v) ->
        v += 1
        data.push v
        @next v
      @step (v) ->
        v += 1
        data.push v
        @next v
      @step (v) ->
        assert.equal v, 4
        assert.deepEqual data, [1, 2, 3, 4]
        done()

  it "should execute asynchronous operations sequentially", (done) ->
    data  = []
    sequentially ->
      @step ->
        v = 1
        data.push v
        setTimeout (=> @next(v)), 50
        @next v
      @step (v) ->
        v += 1
        data.push v
        setTimeout @next, 50
      @step  ->
        v = data.length + 1
        data.push v
        @next v
      @step (v) ->
        v += 1
        data.push 4
        @next v
      @step (v) ->
        assert.equal v, 4
        assert.deepEqual data, [1, 2, 3, 4]
        done()

  it "should handle errors", (done) ->
    data  = []
    sequentially ->
      @step ->
        v = 1
        data.push v
        setTimeout (=> @next(v)), 50
        @next v
      @step (v) ->
        v += 1
        data.push v
        @error 'error'
        setTimeout @next, 50
      @step  ->
        v = data.length
        data.push v
        assert.ok false
        @next v
      @step (v) ->
        v += 1
        data.push 4
        assert.ok false
        @next v
      @step (v) ->
        assert.ok false
        done()
      @error (err) ->
        assert.equal err, 'error'
        assert.deepEqual data, [1, 2]
        done()
