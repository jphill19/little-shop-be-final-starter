class ErrorSerializer
  def self.format_errors(messages)
    {
      message: 'Your query could not be completed',
      errors: messages
    }
  end

  def self.format_invalid_search_response
    { 
      message: "your query could not be completed", 
      errors: ["invalid search params"] 
    }
  end

  #Johns Methods:
  def self.json_errors_for_not_found(error)
    error_data = [
      {
        status: 404,
        message: error
      }
    ]
    {errors: error_data}
  end

  def self.json_errors_for_invalid_request(errors)
    error_data = errors.map do | message|
      {
        status: 422,
        message: message
      }
    end
    {errors: error_data}
  end
end