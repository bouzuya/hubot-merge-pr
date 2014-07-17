require '../helper'

describe 'merge-pr', ->
  beforeEach (done) ->
    @sampleMergeResult =
      merged: true
      message: 'Pull Request successfully merged'
    @sampleGetResult =
      html_url: 'https://github.com/hitoridokusho/hibot/pull/1'
      title: 'TITLE'
      head:
        label: 'hitoridokusho:master'
      base:
        label: 'bouzuya:add-hubot-merge-pr'
    @originalTimeout = process.env.HUBOT_MERGE_PR_TIMEOUT
    process.env.HUBOT_MERGE_PR_TIMEOUT = 80
    GitHub = require 'github'
    @sinon.stub GitHub.prototype, 'authenticate', ->
      # do nothing (stop setting the this.auth)
    @kakashi.scripts = [require '../../src/scripts/merge-pr']
    @kakashi.users = [{ id: 'bouzuya', room: 'hitoridokusho' }]
    @kakashi.start().then done, done

  afterEach (done) ->
    process.env.HUBOT_MERGE_PR_TIMEOUT = @originalTimeout
    @kakashi.stop().then done, done

  describe 'receive "@hubot merge-pr hitoridokusho/hibot 1"', ->
    beforeEach ->
      {pullRequests} = require 'github/api/v3.0.0/pullRequests'
      @sinon.stub pullRequests, 'get', (msg, block, callback) =>
        callback null, @sampleGetResult
      @sinon.stub pullRequests, 'merge', (msg, block, callback) =>
        callback null, @sampleMergeResult

    it 'works', (done) ->
      sender = id: 'bouzuya', room: 'hitoridokusho'
      message = '@hubot merge-pr hitoridokusho/hibot 1'
      @kakashi
        .timeout 1500
        .maxCallCount 2
        .receive sender, message
        .then =>
          expect(@kakashi.send.callCount).to.equal(2)
          expect(@kakashi.send.firstCall.args[1]).to
            .equal """
            "TITLE"
            hitoridokusho:master <- bouzuya:add-hubot-merge-pr
            https://github.com/hitoridokusho/hibot/pull/1

            i will start to merge after 80 ms
            (you can stop it if you type "cancel")
            """
          expect(@kakashi.send.secondCall.args[1]).to
            .equal('Pull Request successfully merged')
        .then (-> done()), done

  describe 'receive valid message (has error in get())', ->
    beforeEach ->
      {pullRequests} = require 'github/api/v3.0.0/pullRequests'
      @sinon.stub pullRequests, 'get', (msg, block, callback) ->
        callback new Error('error message'), null
      @sinon.stub pullRequests, 'merge', (msg, block, callback) =>
        callback null, @sampleMergeResult

    it 'send "merge-pr error"', (done) ->
      sender = id: 'bouzuya', room: 'hitoridokusho'
      message = '@hubot merge-pr hitoridokusho/hibot 1'
      @kakashi
        .timeout 1500
        .receive sender, message
        .then =>
          expect(@kakashi.send.callCount).to.equal(1)
          expect(@kakashi.send.firstCall.args[1]).to.equal('merge-pr error')
        .then (-> done()), done

  describe 'receive valid message (has error in merge())', ->
    beforeEach ->
      {pullRequests} = require 'github/api/v3.0.0/pullRequests'
      @sinon.stub pullRequests, 'get', (msg, block, callback) =>
        callback null, @sampleGetResult
      @sinon.stub pullRequests, 'merge', (msg, block, callback) ->
        callback new Error('error message'), null

    it 'send "merge-pr error"', (done) ->
      sender = id: 'bouzuya', room: 'hitoridokusho'
      message = '@hubot merge-pr hitoridokusho/hibot 1'
      @kakashi
        .timeout 1500
        .maxCallCount 2
        .receive sender, message
        .then =>
          expect(@kakashi.send.callCount).to.equal(2)
          expect(@kakashi.send.firstCall.args[1]).to
            .equal """
            "TITLE"
            hitoridokusho:master <- bouzuya:add-hubot-merge-pr
            https://github.com/hitoridokusho/hibot/pull/1

            i will start to merge after 80 ms
            (you can stop it if you type "cancel")
            """
          expect(@kakashi.send.secondCall.args[1]).to.equal('merge-pr error')
        .then (-> done()), done
