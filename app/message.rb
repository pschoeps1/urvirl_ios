class Message
  attr_reader :message, :userId, :name, :messageId, :timestamp, :type

  def initialize(dict)
    @userId = dict['userId']
    @message = dict['message']
    @name = dict['name']
  end

end