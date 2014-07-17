# hubot-merge-pr

A Hubot script for merging a pull request

## Installation

    $ npm install git://github.com/bouzuya/hubot-merge-pr.git

or

    $ # TAG is the package version you need.
    $ npm install 'git://github.com/bouzuya/hubot-merge-pr.git#TAG'

## Configuration

    $ export HUBOT_MERGE_PR_DEFAULT_USERNAME='...'
    $ export HUBOT_MERGE_PR_TIMEOUT='30000'
    $ export HUBOT_MERGE_PR_TOKEN='...'

### How to generate a token

[See GitHub help documentation][how-to-generate-a-token].

The scope required for using hubot-merge-pr is "public_repo" or "repo" (if you
want to merge a pull request to private repo).

[how-to-generate-a-token]: https://help.github.com/articles/creating-an-access-token-for-command-line-use

## Commands

    bouzuya> hubot help merge-pr
    hubot> hubot merge-pr [<user>/]<repos> <pr> - merge a pull request

    bouzuya> hubot merge-pr hitoridokusho/hibot 2
    hubot> "Test1"
           hitoridokusho:master <- bouzuya:add-hubot-merge-pr
           https://github.com/hitoridokusho/hibot/pull/3
           i will start to merge after 30000 ms
           (you can stop it if you type "cancel")
    hubot> Pull Request successfully merged

## License

MIT

## Badges

[![Build Status][travis-status]][travis]

[travis]: https://travis-ci.org/bouzuya/hubot-merge-pr
[travis-status]: https://travis-ci.org/bouzuya/hubot-merge-pr.svg?branch=master
