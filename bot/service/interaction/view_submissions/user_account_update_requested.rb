
module Service
  module Interaction
    module ViewSubmission
      module UserAccountUpdateRequested
      extend self

        def call(bot_request)
          values = bot_request.data['view']['state']['values'].values
          bot_request.current = ::Request::Events::Users.account_update_requested(
            source: :interactions,
            handle: extract_from_values(values: values, extract: :handle),
            email: extract_from_values(values: values, extract: :email),
            kanbanize_username: extract_from_values(values: values, extract: :kanbanize)
          )  
          Topic::Sns.broadcast(topic: :users, request: bot_request)
        end

        def extract_from_values(values:, extract:)
          values.find do |value|
            "edit-#{extract}" == value.keys.first
          end.values.first['value']
        end
      end
    end
  end 
end
