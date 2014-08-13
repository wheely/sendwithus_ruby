require "base64"

module SendWithUs
  class ApiNilEmailId < StandardError; end

  class Api
    attr_reader :configuration

    # ------------------------------ Class Methods ------------------------------

    def self.configuration
      @configuration ||= SendWithUs::Config.new
    end

    def self.configure
      yield self.configuration if block_given?
    end

    # ------------------------------ Instance Methods ------------------------------

    def initialize(options = {})
      settings = SendWithUs::Api.configuration.settings.merge(options)
      @configuration = SendWithUs::Config.new(settings)
    end

    def send_with(email_id, to, data = {}, from = {}, cc={}, bcc={}, files=[], esp_account='')

      if email_id.nil?
        raise SendWithUs::ApiNilEmailId, 'email_id cannot be nil'
      end

      payload = { email_id: email_id, recipient: to,
        email_data: data }

      if from.any?
        payload[:sender] = from
      end
      if cc.any?
        payload[:cc] = cc
      end
      if bcc.any?
        payload[:bcc] = bcc
      end
      if esp_account
        payload[:esp_account] = esp_account
      end

      files.each do |path|
        file = open(path).read
        id = File.basename(path)
        data = Base64.encode64(file)
        if payload[:files].nil?
          payload[:files] = []
        end
        payload[:files] << {id: id, data: data}
      end

      payload = payload.to_json
      SendWithUs::ApiRequest.new(@configuration).post(:send, payload)
    end

    def drips_unsubscribe(email_address)

      if email_address.nil?
        raise SendWithUs::ApiNilEmailId, 'email_address cannot be nil'
      end

      payload = { email_address: email_address }
      payload = payload.to_json

      SendWithUs::ApiRequest.new(@configuration).post(:'drips/unsubscribe', payload)
    end

    def emails()
      SendWithUs::ApiRequest.new(@configuration).get(:emails)
    end

    def create_template(name, subject, html, text)
      payload = {
        name: name,
        subject: subject,
        html: html,
        text: text
      }.to_json

      SendWithUs::ApiRequest.new(@configuration).post(:emails, payload)
    end

    def list_drip_campaigns()
        SendWithUs::ApiRequest.new(@configuration).get(:drip_campaigns)
    end

    def start_on_drip_campaign(recipient_address, drip_campaign_id)
        payload = {
            recipient_address: recipient_address
        }.to_json

        SendWithUs::ApiRequest.new(@configuration).post('drip_campaigns/#{drip_campaign_id}/activate'.to_sym, payload)
    end

    def remove_from_drip_campaign(recipient_address, drip_campaign_id)
        payload = {
            recipient_address: recipient_address
        }.to_json

        SendWithUs::ApiRequest.new(@configuration).post('drip_campaigns/#{drip_campaign_id}/deactivate'.to_sym, payload)
    end

    def list_drip_campaign_steps(drip_campaign_id)
        SendWithUs::ApiRequest.new(@configuration).get('drip_campaigns/#{drip_campaign_id}/steps'.to_sym)
    end

  end

end
