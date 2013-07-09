glob = require 'glob'
fs = require 'fs'
coffee = require 'coffee-script'

task 'install', 'compile the coffee source to js', ->
    fs.mkdir 'js', ->
        glob 'src/*.coffee', (err, infiles) ->
            if err? then console.error err

            infiles.forEach (infile) ->
                outfile = infile.replace /^src\/(.*)\.coffee$/, 'js/$1.js'
                fs.readFile infile, { encoding: 'utf-8' }, (err, source) ->
                    if err?
                        console.error err
                    else
                        output = coffee.compile source, bare: true
                        fs.writeFile outfile, output, { encoding: 'utf-8' }, (err) ->
                            if err? then console.error err
