# hubot-merge-pr

A Hubot script for merging a pull request

## Installation

    $ npm install git://github.com/bouzuya/hubot-merge-pr.git

or

    $ # TAG is the package version you need.
    $ npm install 'git://github.com/bouzuya/hubot-merge-pr.git#TAG'

## Configuration

    $ export HUBOT_MERGE_PR_TIMEOUT='30000'
    $ export HUBOT_MERGE_PR_TOKEN='...'

## Commands

    bouzuya> hubot help merge-pr
    hubot> hubot merge-pr <user>/<repos> <pr> - merge a pull request

    bouzuya> hubot merge-pr hitoridokusho/hibot 2
    hubot> confirm the merging hitoridokusho/hibot 2
           wait 30 sec (if you input "cancel", cancel the merging)
    hubot> merge start
    hubot> Pull Request successfully merged

## License

MIT

## Badges

[![Build Status][travis-status]][travis]

[travis]: https://travis-ci.org/bouzuya/hubot-merge-pr
[travis-status]: https://travis-ci.org/bouzuya/hubot-merge-pr.svg?branch=master
