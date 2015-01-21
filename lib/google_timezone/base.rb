require 'json'
require 'open-uri'

module GoogleTimezone

  class Error < StandardError; end

  class Base
    ALLOWED_PARAMS = [:language, :sensor, :timestamp, :client, :signature, :key]

    def initialize(*args)
      @lat, @lon = if args.first.is_a? Array
                     args.first
                   else
                     args[0..1]
                   end

      @options = extract_options!(args)
      @options.reject! { |key, _| !ALLOWED_PARAMS.include?(key) }
    end

    def fetch
      location = [@lat, @lon].join(',')
      params = { :location=> location, :sensor => false, :timestamp => Time.now.to_i }.merge(@options)
      result = get_result(params)
      Result.new(result)
    end

    def fetch!
      result = fetch
      raise(GoogleTimezone::Error.new(result.result)) unless result.success?
      result
    end

    private

    def hash_to_query(hash)
      hash.collect { |key, val| "#{key}=#{val}" }.join('&')
    end

    def url(params)
      "https://maps.googleapis.com/maps/api/timezone/json?#{hash_to_query(params)}"
    end

    def extract_options!(args)
      args.last.is_a?(::Hash) ? args.pop : {}
    end

    def get_result(params)
      open(url(params)) { |r| JSON.parse(r.read) }
    end
  end
end
