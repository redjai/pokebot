module Lambda 
  module HttpResponse 
    extend self

    def plain_text_response(body, status_code=200)
      { 
              body: body,
        statusCode: status_code,
           headers: { "Content-Type" => 'text/plain' } 
      }
    end
  end
end
