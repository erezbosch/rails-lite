require_relative '../phase4/controller_base'
require_relative './params'

module Phase5
  class ControllerBase < Phase4::ControllerBase
    attr_reader :params

    # setup the controller
    def initialize(req, res, route_params = {})
      super(req, res)
      @params = Params.new(req, route_params)
    end

    def form_authenticity_token
      token = SecureRandom.urlsafe_base64
      session["authenticity_token"] = token
      token
    end

    def protect_from_forgery
      params_token = params["authenticity_token"]
      session_token = session["authenticity_token"]
      p params_token, session_token
      unless session_token && params_token == session_token
        raise "INVALID AUTHENTICITY TOKEN"
      end
    end
  end
end
