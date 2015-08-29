require 'active_support'
require 'active_support/core_ext'
require 'byebug'

class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern, @http_method, @controller_class, @action_name =
        pattern, http_method, controller_class, action_name
  end

  # checks if pattern matches path and method matches request method
  def matches?(req)
    hidden_method_idx = req.body ? req.body.index('_method=') : nil
    if hidden_method_idx
      end_idx = req.body[hidden_method_idx..-1].index('&')
      end_idx ? end_idx += hidden_method_idx : end_idx = req.body.length
      target_method = req.body[hidden_method_idx + 8...end_idx]
    else
      target_method = req.request_method
    end
    target_method.downcase.to_sym == http_method && pattern =~ req.path
  end

  # use pattern to pull out route params (save for later?)
  # instantiate controller and call controller action
  def run(req, res)
    match_data = pattern.match(req.path)
    route_params = match_data.names.each_with_object({}) do |key, hash|
      hash[key] = match_data[key]
    end
    controller = controller_class.new(req, res, route_params)
    controller.protect_from_forgery unless [:get, :delete].include? http_method
    controller.invoke_action(action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  # simply adds a new route to the list of routes
  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  # evaluate the proc in the context of the instance
  # for syntactic sugar :)
  # proc is { get url, class, action etc.... }
  def draw(&proc)
    instance_eval &proc
  end

  def resources(things, options = {})
    defaults = [:index, :show, :update, :create, :destroy, :edit, :new]
    if options[:only]
      routes = options[:only]
    elsif options[:except]
      routes = defaults - options[:except]
    else
      routes = defaults
    end
    ctrlr = "#{things.capitalize}Controller".constantize
    draw do
      if routes.include?(:index)
        get Regexp.new("^/#{things}$"), ctrlr, :index
      end
      if routes.include?(:new)
        get Regexp.new("^/#{things}/new$"), ctrlr, :new
      end
      if routes.include?(:create)
        post Regexp.new("^/#{things}$"), ctrlr, :create
      end
      if routes.include?(:show)
        get Regexp.new("^/#{things}/(?<id>\\d+)$"), ctrlr, :show
      end
      if routes.include?(:edit)
        get Regexp.new("^/#{things}/(?<id>\\d+)/edit$"), ctrlr, :edit
      end
      if routes.include?(:update)
        put Regexp.new("^/#{things}/(?<id>\\d+)$"), ctrlr, :update
      end
      if routes.include?(:destroy)
        delete Regexp.new("^/#{things}/(?<id>\\d+)$"), ctrlr, :destroy
      end
    end
  end

  # make each of these methods that add route when called
  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end

  # should return the route that matches this request
  def match(req)
    routes.each { |route| return route if route.matches?(req) }
    nil
  end

  # either throw 404 or call run on a matched route
  def run(req, res)
    matching_route = match(req)
    matching_route ? matching_route.run(req, res) : res.status = 404
  end
end
