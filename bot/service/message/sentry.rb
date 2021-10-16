module Service
  module Message
    extend self

    # if the message isn't from a bot we are good to go
       
    BoundedContext.register_sentry(self)

    def pass?(bot_request)
      bot_request.data['event']['bot_id'].nil? 
    end

  end
end
