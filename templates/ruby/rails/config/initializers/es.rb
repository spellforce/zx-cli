
unless Rails.env.development?
  ES_CLIENT = Elasticsearch::Client.new host: ENV['ES_HOST'], log: false

  begin
    unless ES_CLIENT.indices.exists? index: ENV['ES_INDEX_NAME']
      ES_CLIENT.indices.create index: ENV['ES_INDEX_NAME'],
        body: {
          mappings: {
            # if es version > 1.7 ,remove doc: {}
            properties: {
              timestamp: {
                type: 'text',
                fielddata: true
              },
              logged_at:{
                type: 'text',
                fielddata: true
              },
              message: {
                type: 'text',
                "index": true
              }
            }
          }
        }
    end
  rescue => ex
    Rails.logger.error("init es client error -- #{ex.to_s}")
  end
end
