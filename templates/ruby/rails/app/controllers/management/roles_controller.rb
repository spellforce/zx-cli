#encoding: utf-8
class Management::RolesController < ApplicationController
  before_action :authenticate_api!
  before_action :track_before_action
  after_action :track_after_action

  # api
  def create
    role_params = get_role_params
    role = Role.new({name: role_params[:name], code: role_params[:code]})
    role.permissions = Permission.where(id: role_params[:selected_permissions])
    if role.save
      success!(nil, "Create Successfully. ")
    else
      error!(role.errors.full_messages.join("\n"))
    end
  end

   # datatable api
   def get_records
    schema = {
      type: "object",
      required: [],
      properties: {
        pagination: { type: "object", properties: {
          current: { type: "integer" },
          pageSize: { type: "integer", maximum: 500 },
        }},
        sortField: { type: "string" },
        sortDirection: { type: "string", enum: ["ASC", "DESC", nil] }
      }
    }

    error!("Parameters are invalid.") and return unless JSON::Validator.validate(schema, params.to_h) 

    result = Role.pageTable(params)

    success!(result)
  end

  # api
  def update
    role = Role.find(params[:id])
    role_params = get_role_params
    role.name = role_params[:name]
    role.code = role_params[:code]
    role.permissions = Permission.where(id: role_params[:selected_permissions])
    if role.save
      success!(nil, "Update Successfully. ")
    else
      error!(role.errors.full_messages.join("\n"))
    end
  end

  def all
    success!(Role.all)
  end

  # api+
  def destroy
    role = Role.find(params[:id])
    @record = role.as_json
    if role.destroy
      success!(nil, "Destroy Successfully. ")
    else
      error!(role.errors.full_messages.join("\n"))
    end
  end

  # api
  def get_related_permission
    success!(Role.get_related_permissions(params))
  end

  private

  def get_role_params
    params.permit(:name, :code, {selected_permissions: []})
  end

  def track_before_action
    case params[:action]
      when 'create'
        ahoy.track "Create System Role", ActiveSupport::JSON.encode(params)
      when 'update'
        ahoy.track "Update System Role", ActiveSupport::JSON.encode(params)
    end
  end

  def track_after_action
    case params[:action]
      when 'destroy'
        ahoy.track "[Track] Destroy System Role", ActiveSupport::JSON.encode(@record)
    end
  end
end
