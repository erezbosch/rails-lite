require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @params = route_params

      @params.merge!(parse_www_encoded_form(req.body)) unless req.body.nil?

      unless req.query_string.nil?
        @params.merge!(parse_www_encoded_form(req.query_string))
      end
    end

    def [](key)
      @params[key.to_sym] || @params[key.to_s]
    end

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      query_array = URI::decode_www_form(www_encoded_form)
      query_hash = Hash.new
      query_array.each do |pair|
        key, value = pair
        keys = parse_key(key)
        current_hash = query_hash
        keys[0..-2].each do |key|
          current_hash[key] = {} unless current_hash.has_key?(key)
          current_hash = current_hash[key]
        end
        current_hash[keys.last] = value
      end
      query_hash
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.delete("]").split("[")
    end
  end
end
