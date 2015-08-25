require_relative '../models/cat'
require_relative '../controller_logic/controller_base'

class CatsController < ControllerBase
  def create
    @cat = Cat.new(cat_params)
    @cat.save
    redirect_to("/cats")
  end

  def index
    @cats = Cat.all
    render :index
  end

  def new
    @cat = Cat.new
    render :new
  end

  def show
    @cat = Cat.find(params["id"].to_i)
    render :show
  end

  def edit
    @cat = Cat.find(params["id"].to_i)
    render :edit
  end

  def update
    @cat = Cat.find(params["id"].to_i)
    cat_params.keys.each do |key|
      @cat.send("#{key}=", cat_params[key])
    end
    @cat.update
    redirect_to("/cats/#{@cat.id}")
  end

  private

  def cat_params
    params["cat"]
  end
end
