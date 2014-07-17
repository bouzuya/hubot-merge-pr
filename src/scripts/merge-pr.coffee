# Description
#   merge-pr
#
# Dependencies:
#   "github": "^0.2.1",
#   "q": "^1.0.1"
#
# Configuration:
#   HUBOT_MERGE_PR_DEFAULT_USERNAME
#   HUBOT_MERGE_PR_TIMEOUT
#   HUBOT_MERGE_PR_TOKEN
#
# Commands:
#   hubot merge-pr [<user>/]<repos> <pr> - merge a pull request
#
# Author:
#   bouzuya <m@bouzuya.net>
#
{Promise} = require 'q'
GitHub = require 'github'

module.exports = (robot) ->
  github = new GitHub version: '3.0.0'
  github.authenticate
    type: 'oauth'
    token: process.env.HUBOT_MERGE_PR_TOKEN
  timeout = parseInt (process.env.HUBOT_MERGE_PR_TIMEOUT ? '30000'), 10
  timeoutId = null

  get = (user, repo, number) ->
    new Promise (resolve, reject) ->
      github.pullRequests.get
        user: user, repo: repo, number: number, (err, ret) ->
          if err
            reject(err)
          else
            resolve(ret)

  merge = (user, repo, number) ->
    new Promise (resolve, reject) ->
      github.pullRequests.merge
        user: user, repo: repo, number: number, (err, ret) ->
          if err
            reject(err)
          else
            resolve(ret)

  formatGetResult = (result) ->
    """
      "#{result.title}"
      #{result.base.label} <- #{result.head.label}
      #{result.html_url}
    """

  formatMergeResult = (result) -> result.message

  robot.hear /cancel/i, (res) ->
    if timeoutId?
      clearTimeout timeoutId
      res.send 'canceled'
      timeoutId = null

  robot.respond /merge-pr\s+(([^\/]+)\/)?(\S+)\s+(\d+)$/i, (res) ->
    if timeoutId?
      res.send 'wait for merging...'
      return
    user = res.match[2] ? process.env.HUBOT_MERGE_PR_DEFAULT_USERNAME
    return unless user?
    repo = res.match[3]
    number = parseInt(res.match[4], 10)
    Promise.resolve()
      .then -> get user, repo, number
      .then (result) ->
        res.send [
          formatGetResult(result)
          ""
          "i will start to merge after #{timeout} ms"
          "(you can stop it if you type \"cancel\")"
        ].join('\n')
        new Promise (resolve) -> timeoutId = setTimeout resolve, timeout
      .then ->
        timeoutId = null
        merge(user, repo, number)
      .then (result) ->
        res.send formatMergeResult(result)
      , (err) ->
        robot.logger.error(err)
        res.send 'merge-pr error'
