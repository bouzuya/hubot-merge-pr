# Description
#   merge-pr
#
# Dependencies:
#   "github": "^0.2.1",
#   "q": "^1.0.1"
#
# Configuration:
#   HUBOT_MERGE_PR_TIMEOUT
#   HUBOT_MERGE_PR_TOKEN
#
# Commands:
#   hubot merge-pr <user>/<repos> <pr> - merge a pull request
#
# Author:
#   bouzuya <m@bouzuya.net>
#
{Promise} = require 'q'
GitHub = require 'github'

module.exports = (robot) ->
  timeoutId = null

  merge = (user, repo, number) ->
    new Promise (resolve, reject) ->
      github = new GitHub version: '3.0.0'
      github.authenticate
        type: 'oauth'
        token: process.env.HUBOT_MERGE_PR_TOKEN
      github.pullRequests.merge
        user: user, repo: repo, number: parseInt(number, 10), (err, ret) ->
          if err
            reject(err)
          else
            resolve(ret)

  robot.hear /cancel/i, (res) ->
    if timeoutId?
      clearTimeout timeoutId
      res.send 'canceled'
      timeoutId = null

  robot.respond /merge-pr\s+([^\/]+)\/(\S+)\s+(\d+)$/i, (res) ->
    if timeoutId?
      res.send 'wait for the merging...'
      return
    timeout = parseInt (process.env.HUBOT_MERGE_PR_TIMEOUT ? '30000'), 10
    user = res.match[1]
    repo = res.match[2]
    number = res.match[3]
    res.send [
      'confirm the merging ' + user + '/' + repo + ' number: ' + number
      'wait ' + timeout + ' ms (if you input "cancel", cancel the merging)'
    ].join('\n')
    timeoutId = setTimeout ->
      res.send 'merge start'
      timeoutId = null
      merge(user, repo, number).then (ret) ->
        res.send ret.message
      , (err) ->
        robot.logger.error(err)
        res.send 'merge-pr error'
    , timeout
