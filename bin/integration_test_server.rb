require 'active_support'
require 'active_support/core_ext'
require 'webrick'
require_relative '../controllers/cats_controller'
require_relative '../models/cat'
require_relative '../models/human'

router = Router.new
router.draw do
  get Regexp.new("^/cats$"), CatsController, :index
  get Regexp.new("^/cats/new$"), CatsController, :new
  post Regexp.new("^/cats$"), CatsController, :create
  get Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :show
  get Regexp.new("^/cats/(?<id>\\d+)/edit$"), CatsController, :edit
  post Regexp.new("^/cats/(?<id>\\d+)$"), CatsController, :update
  get Regexp.new("^/cats/(?<id>\\d+)/destroy$"), CatsController, :destroy
end

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
