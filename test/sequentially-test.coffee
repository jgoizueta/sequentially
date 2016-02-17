assert = require "assert"

describe 'sequentially', ->
  sequentially = require '../lib/sequentially'

  it "should execute synchronous operations sequentially", (done) ->
    data  = []
    sequentially ->
      @step (done) ->
        v = 1
        data.push v
        done null, v
      @step (v, done) ->
        v += 1
        data.push v
        done null, v
      @step (v, done) ->
        v += 1
        data.push v
        done null, v
      @step (v, done) ->
        v += 1
        data.push v
        done null, v
      @step (v) ->
        assert.equal v, 4
        assert.deepEqual data, [1, 2, 3, 4]
        done null

  it "should execute asynchronous operations sequentially", (done) ->
    data  = []
    sequentially ->
      @step (done) ->
        v = 1
        data.push v
        setTimeout (-> done null, v), 50
      @step (v, done) ->
        v += 1
        data.push v
        setTimeout done, 50, null, v
      @step (v, done) ->
        v = data.length + 1
        data.push v
        done null, v
      @step (v, done) ->
        v += 1
        data.push 4
        done null, v
      @step (v) ->
        assert.equal v, 4
        assert.deepEqual data, [1, 2, 3, 4]
        done()

  it "should handle errors", (done) ->
    data  = []
    sequentially ->
      @step (done) ->
        v = 1
        data.push v
        setTimeout (-> done null, v), 50
      @step (v, done) ->
        v += 1
        data.push v
        done 'error'
      @step  (done) ->
        v = data.length
        data.push v
        assert.ok false
        done null, v
      @step (v, done) ->
        v += 1
        data.push 4
        assert.ok false
        done null, v
      @step (v) ->
        assert.ok false
        done()
      @on_error (err) ->
        assert.equal err, 'error'
        assert.deepEqual data, [1, 2]
        done()
