require 'json'

class Flash
  def initialize(req)
    req.cookies.each do |cookie|
      if cookie.name == "_rails_lite_app"
        @flash = cookie.value == "" ? {} : JSON.parse(cookie.value)
        return
      end
    end
    @flash = {}
  end

  def [](key)
    @flash[key] || now[key]
  end

  def []=(key, val)
    @flash[key] = val
  end

  def now
    @flash_now ||= FlashNow.new
  end

  # When an HTML request is made: add the flash to cookies and
  # empty it into flash_now; old flash_now is removed in this process
  def store_session(res)
    current_flash = @flash.merge(now.flash_now)
    res.cookies << WEBrick::Cookie.new("flash", current_flash.to_json)
    @flash_now = FlashNow.new(@flash)
    @flash = {}
  end
end

class FlashNow
  attr_reader :flash_now
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
