class Management::OperationHistoryController  < ApplicationController
  before_action :authenticate_api!

  def get_records
    schema = {
      type: "object",
      required: [],
      properties: {
        pagination: { type: "object", properties: {
          current: { type: "integer" },
          pageSize: { type: "integer", maximum: 500 },
        }},
        sortField: { enum: ['email', 'name', 'time', 'properties', nil] },
        sortDirection: { type: "string", enum: ["ASC", "DESC", nil] }
      }
    }
    error!("Parameters are invalid.") and return unless JSON::Validator.validate(schema, params.to_h)
    
    result = Ahoy::Event.pageTable(params)
    success!(result)
  end

  def get_summary
    result = Ahoy::Event.get_summary
    success!(result)
  end

end
