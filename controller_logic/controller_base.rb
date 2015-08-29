require 'active_support'
require 'active_support/core_ext'
require 'active_support/inflector'
require 'erb'
require_relative './params'
require_relative './session'
require_relative './flash'
require_relative './router'

class ControllerBase
  attr_reader :req, :res, :params

  # set up the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(req, route_params)
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    file = "views/#{self.class.to_s.underscore}/#{template_name}.html.erb"
    data = File.read(file)
    template = ERB.new(data)
    result = template.result(binding)
    render_content(result, "text/html")
  end

  ## Raise an error if a response is built twice either on redirect or render
  ## Also, record the response to flash and session hashes

  # Set the response status code and header for redirect.
  def redirect_to(url)
    fail if already_built_response?
    @res["location"] = url
    @res.status = 302
    @already_built_response = true
    session.store_session(@res)
    flash.store_session(@res)
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  def render_content(content, content_type)
    fail if already_built_response?
    @res.content_type = content_type
    @res.body = content
    @already_built_response = true
    session.store_session(@res)
    flash.store_session(@res)
  end

  # expose a Session object
  def session
    @session ||= Session.new(req)
  end

  # expose a Flash object
  def flash
    @flash ||= Flash.new(req)
  end

  # create an authenticity token for this form; save it to session; return it
  def form_authenticity_token
    token = SecureRandom.urlsafe_base64
    session["authenticity_token"] = token
    puts "SET TOKEN TO #{token}"
    p session
    token
  end

  # ensure that there is an authenticity token stored in cookies AND it is
  # the same as the one passed in params
  def protect_from_forgery
    p params, session
    params_token = params["authenticity_token"]
    session_token = session["authenticity_token"]
    unless session_token && params_token == session_token
      raise "INVALID AUTHENTICITY TOKEN"
    end
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
  end
end
