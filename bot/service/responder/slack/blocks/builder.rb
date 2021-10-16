module Service
  module Responder
    module Slack
      module BlockBuilder

        def text_section(text, options={})
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: text
            }
          }.tap do |section|
              section["accessory"] = options[:accessory] if options[:accessory]
            end
        end

        def image_accessory(image_url:, alt_text:)
          {
            type: "image",
            image_url: image_url,
            alt_text: alt_text
          }
        end

        def button_element(text:, value:, options: {})
          {
            "type": "button",
            "text": {
              "type": "plain_text",
              "text": text,
              "emoji": true
            },
            "value": value,
          }.tap do |element|
            element[:url] = options[:url] if options[:url]
            element[:action_id] = options[:action_id] if options[:action_d]
          end
        end

        def actions(*elements)
          {
            "type": "actions",
            "elements": elements 
          }
        end

        def divider_block
          {
            "type": "divider"
          }
        end

      end

      class Modal

        def initialize(title, private_metadata, submit="Submit")
          @title = title
          @submit = submit
          @private_metadata = private_metadata
        end

        def blocks
          @blocks ||= []
        end

        def view
          {
            "title" => title,
            "submit" => submit,
            "blocks" => blocks,
            "type" => "modal",
            "private_metadata" => @private_metadata
          }
        end

        def title
          {
		        "type" => "plain_text",
		        "text" => @title
	        }
        end

        def submit
          {
        		"type" => "plain_text",
        		"text" => @submit
         	}
        end

        def add_input(label:, initial_value:, placeholder:, action_id:)
          blocks << {
            "type" => "input",
            "element" => {
              "type" => "plain_text_input",
              "action_id" => action_id,
              "initial_value" => initial_value,
              "placeholder" => {
                "type" => "plain_text",
                "text" => placeholder
              }
            },
            "label" => {
              "type" => "plain_text",
              "text" => label 
            }
          }
        end

      end
    end
  end
end
