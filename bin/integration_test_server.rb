require 'active_support'
require 'active_support/core_ext'
require 'webrick'
require_relative '../controllers/cats_controller'
require_relative '../models/cat'
require_relative '../models/human'

router = Router.new
router.resources :cats

server = WEBrick::HTTPServer.new(Port: 3000)
server.mount_proc('/') do |req, res|
  route = router.run(req, res)
end

trap('INT') { server.shutdown }
server.start
