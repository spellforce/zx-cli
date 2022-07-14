module EsLog

  def self.error(url, body)
    Rails.logger.error(body[:message])
    
    begin
      uuid = if body[:uuid].present?
        body[:uuid]
      else
        UUIDTools::UUID.timestamp_create().to_s
      end

      if Rails.env.production?
        ES_CLIENT.index  index: ENV['ES_INDEX_NAME'], type: '_doc', body: {
          user: body[:email],
          logged_at: "#{Time.now.to_i}000",
          label: ENV['ES_LOG_LABEL'],
          level: 'error',
          timestamp: Time.now.to_s,
          url: url,
          data: body[:params].to_s,
          message: "uuid: #{uuid} ---- #{body[:message].to_s}"
        }
      end

      return uuid
    rescue => ex
      Rails.logger.error("es log error -- #{ex.to_s}")
    end
  end

  def self.info(url, body)
    begin
      if Rails.env.production?
        ES_CLIENT.index  index: ENV['ES_INDEX_NAME'], type: '_doc', body: {
          user: body[:email],
          logged_at: "#{Time.now.to_i}000",
          label: ENV['ES_LOG_LABEL'],
          level: 'info',
          timestamp: Time.now.to_s,
          url: url,
          data: '[FILTERED]',
          message: body[:message].to_s
        }
      end
    rescue => ex
      Rails.logger.error("es log error -- #{ex.to_s}")
    end
  end

end
