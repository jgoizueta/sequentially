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

  it "should be able to define the scope", (done) ->
    @_outer_value = 123
    data  = []
    sequentially scope: this, ->
      @step (done) ->
        assert.equal @_outer_value, 123
        done null
      @step (done) ->
        assert.equal @_outer_value, 123
        done 'error'
      @on_error (err) ->
        assert.equal @_outer_value, 123
        done()

  it "should pass a block parameter", (done) ->
    data  = []
    sequentially (block) ->
      block.step (done) ->
        v = 1
        data.push v
        setTimeout (-> done null, v), 50
      block.step (v, done) ->
        v += 1
        data.push v
        setTimeout done, 50, null, v
      block.step (v, done) ->
        v = data.length + 1
        data.push v
        done null, v
      block.step (v, done) ->
        v += 1
        data.push 4
        done null, v
      block.step (v) ->
        assert.equal v, 4
        assert.deepEqual data, [1, 2, 3, 4]
        done()

  it "should pass a block parameter", (done) ->
      data  = []
      sequentially (block) ->
        block.step (done) ->
          v = 1
          data.push v
          setTimeout (-> done null, v), 50
        block.step (v, done) ->
          v += 1
          data.push v
          done 'error'
        block.step  (done) ->
          v = data.length
          data.push v
          assert.ok false
          done null, v
        block.step (v, done) ->
          v += 1
          data.push 4
          assert.ok false
          done null, v
        block.step (v) ->
          assert.ok false
          done()
        block.on_error (err) ->
          assert.equal err, 'error'
          assert.deepEqual data, [1, 2]
          done()

  it "should pass a step and error parameters", (done) ->
      data  = []
      sequentially (step, on_error) ->
        step (done) ->
          v = 1
          data.push v
          setTimeout (-> done null, v), 50
        step (v, done) ->
          v += 1
          data.push v
          done 'error'
        step  (done) ->
          v = data.length
          data.push v
          assert.ok false
          done null, v
        step (v, done) ->
          v += 1
          data.push 4
          assert.ok false
          done null, v
        step (v) ->
          assert.ok false
          done()
        on_error (err) ->
          assert.equal err, 'error'
          assert.deepEqual data, [1, 2]
          done()
