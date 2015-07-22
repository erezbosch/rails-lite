require 'json'

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
    puts "@delete is #{@delete}"
    puts "#{key} #{val}"
    @flash[key] = val
    @delete.delete(key)
    puts "Deleted key #{key} from @delete which is #{@delete}"
  end

  def now
    @flash_now ||= FlashNow.new
  end

  # When an HTML request is made: add the flash to cookies and
  # empty it into flash_now; old flash_now is removed in this process
  def store_session(res)
    @flash_now = nil
    puts "Flash is #{@flash}"
    @flash = @flash.delete_if { |k, v| @delete.include?(k) }
    puts "Flash is #{@flash}"
    @delete = @flash.keys
    puts "@delete is #{@delete}"
    res.cookies << WEBrick::Cookie.new("flash", @flash.to_json)
    res.cookies <<
      WEBrick::Cookie.new("delete", @delete.to_json)
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
