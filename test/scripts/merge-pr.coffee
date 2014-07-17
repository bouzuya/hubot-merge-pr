require '../helper'

describe 'merge-pr', ->
  beforeEach (done) ->
    @originalTimeout = process.env.HUBOT_MERGE_PR_TIMEOUT
    process.env.HUBOT_MERGE_PR_TIMEOUT = 500
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
      @sinon.stub pullRequests, 'merge', (msg, block, callback) ->
        callback null, {
          sha: 'ec172400f77829c9f2d5399ffddda43604fe0ae0'
          merged: true
          message: 'Pull Request successfully merged'
          meta:
            'x-ratelimit-limit': '5000',
            'x-ratelimit-remaining': '4363',
            'x-ratelimit-reset': '1405523795',
            'x-oauth-scopes': 'public_repo',
            etag: '"b17cfcde842bf3c48aebc1bb27f044e6"',
            status: '200 OK'
        }

    it 'send "https://github.com/hitoridokusho/hibot/1"', (done) ->
      sender = id: 'bouzuya', room: 'hitoridokusho'
      message = '@hubot merge-pr hitoridokusho/hibot 1'
      @kakashi
        .timeout 1500
        .maxCallCount 3
        .receive sender, message
        .then =>
          expect(@kakashi.send.callCount).to.equal(3)
          expect(@kakashi.send.firstCall.args[1]).to.match(/^confirm/)
          expect(@kakashi.send.secondCall.args[1]).to.equal('merge start')
          expect(@kakashi.send.thirdCall.args[1]).to
            .equal('Pull Request successfully merged')
        .then (-> done()), done

  describe 'receive "@hubot merge-pr hitoridokusho/hibot 1" (has error)', ->
    beforeEach ->
      {pullRequests} = require 'github/api/v3.0.0/pullRequests'
      @sinon.stub pullRequests, 'merge', (msg, block, callback) ->
        callback new Error('error message'), null

    it 'send "https://github.com/hitoridokusho/hibot/1"', (done) ->
      sender = id: 'bouzuya', room: 'hitoridokusho'
      message = '@hubot merge-pr hitoridokusho/hibot 1'
      @kakashi
        .timeout 1500
        .maxCallCount 3
        .receive sender, message
        .then =>
          expect(@kakashi.send.callCount).to.equal(3)
          expect(@kakashi.send.firstCall.args[1]).to.match(/^confirm/)
          expect(@kakashi.send.secondCall.args[1]).to.equal('merge start')
          expect(@kakashi.send.thirdCall.args[1]).to.equal('merge-pr error')
        .then (-> done()), done
