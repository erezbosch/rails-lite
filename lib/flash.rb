require 'json'
require 'webrick'

class Flash
  def initialize(req)
    req.cookies.each do |cookie|
      if cookie.name == "flash"
        @flash = cookie.value == "" ? {} : JSON.parse(cookie.value)
      elsif cookie.name == "delete"
        @delete = cookie.value == "" ? [] : JSON.parse(cookie.value)
      end
    end

    @flash ||= {}
    @delete ||= []
  end

  def [](key)
    if now[key] && @flash[key]
      [now[key], @flash[key]]
    else
      @flash[key] || now[key]
    end
  end

  def []=(key, val)
    @flash[key] = val
    @delete.delete(key)
  end

  def now
    @flash_now ||= FlashNow.new
  end

  def store_session(res)
    @flash_now = nil
    @flash = @flash.delete_if { |k, v| @delete.include?(k) }
    @delete = @flash.keys

    [
      WEBrick::Cookie.new("flash", @flash.to_json),
      WEBrick::Cookie.new("delete", @delete.to_json)
    ].each do |cookie|
      res.cookies << cookie
    end
  end
end

class FlashNow
  def initialize(hash = {})
    @flash_now = hash
  end

  def [](key)
    @flash_now[key]
  end

  def []=(key, val)
    @flash_now[key] = val
  end
end
