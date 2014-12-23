Negotiator = require('negotiator')

exports.register = (plugin, options, next) ->
  unless options.exclude? then options.exclude = []

  plugin.route
    method: 'GET',
    path: '/public/{path*}',
    handler:
      directory:
        path: "./public"
        listing: false
        index: true

  plugin.ext 'onRequest', (request, reply) ->
    negotiator = new Negotiator(request.raw.req)

    # Matches a path we're excluding, pass on.
    if (options.exclude.some (path) -> new RegExp(path).test(request.path))
      reply.continue()
    # Accept: */* generally means the browser is looking for a JS file.
    else if negotiator.mediaType() is "*/*"
      request.setUrl("/public#{request.path}")
      reply.continue()
    # If they're expecting json, pass on the request unmodified as there should
    # be a route ready to handle this.
    else if negotiator.mediaType() is "application/json"
      reply.continue()
    # They're asking for html, redirect to public to return our
    # static index.html.
    else if negotiator.mediaType() is "text/html"
      request.setUrl('/public/')
      reply.continue()
    # They're not requesting html so probably looking for css/images. Redirect
    # to the public directory.
    else
      request.setUrl("/public#{request.path}")
      reply.continue()

    return

  next()

exports.register.attributes =
  pkg: require '../package.json'
