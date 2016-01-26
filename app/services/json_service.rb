class JSONService
  def self.parse_from_url(url)
    data = DataService.parse(url)

    error_ptr = Pointer.new(:object)
    json = NSJSONSerialization.JSONObjectWithData(data, options:0, error:error_ptr)
    unless json
      raise error_ptr[0]
    end
    json
  end

  def self.parse_from_object(object)
    error_ptr = Pointer.new(:object)
    auth_json = NSJSONSerialization.JSONObjectWithData(object, options:0, error:error_ptr)
    unless auth_json
      raise error_ptr[0]
    end
    auth_json
  end

end