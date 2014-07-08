# http://tobyho.com/2011/10/15/getting-terminal-size-in-node/

{spawn} = require 'child_process'

module.exports = (cb) ->
  spawn('resize').stdout.on 'data', (data) ->
    resizeOutput = String(data).split '\n'
    cols = Number(resizeOutput[0].match(/^COLUMNS=([0-9]+);$/)[1])
    lines = Number(resizeOutput[1].match(/^LINES=([0-9]+);$/)[1])
    cb cols, lines if cb
