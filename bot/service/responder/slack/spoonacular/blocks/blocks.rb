module Service
  module Responder
    module Slack
      module Spoonacular
        module Blocks
          module SlackBlocks

            def text_section(text)
              {
                type: "section",
                text: {
                  type: "mrkdwn",
                  text: text
                }
              }
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
        end
      end
    end
  end
end
