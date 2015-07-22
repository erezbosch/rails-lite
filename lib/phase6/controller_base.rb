require_relative '../phase5/controller_base'

module Phase6
  class ControllerBase < Phase5::ControllerBase
    # use this with the router to call action_name (:index, :show, :create...)
    def invoke_action(name)
      self.send(name)
    end

    def form_authenticity_token
      token = SecureRandom.urlsafe_base64
      session["authenticity_token"] = token
      token
    end

    def protect_from_forgery
      unless params["authenticity_token"] == session["authenticity_token"]
        raise "INVALID AUTHENTICITY TOKEN"
      end
    end

    #### CSRF ####
    ## IMPLEMENT HELPER METHODS?
    ## IMPLEMENT BEFORE_ACTION?
    ## form_authenticity_token function in ControllerBase
    ## (acc. in views ERB - helper method - how to implement?)
    ## This function: Places an auth token in the session cookies
    ## AND returns the auth token - ie it should be usable as
    # <input type='hidden' name='authenticity_token' value=<%= form_auth_token %>>
    # Check
    #
    ## protect_from_forgery function in ControllerBase
    ## this function:
    # Compares auth_token in PARAMS to token in COOKIES
    # (This is an automatic before_action ahead of anything that takes a form -
    # how to implement? On any POST/PATCH/DELETE action only? )
    # If not equal or if no auth token in cookies, do:
    # = Null Session
    # = Reset Session
    # = Raise Exception
    # depending on input
    # maybe just start with raising exception?
  end
end
