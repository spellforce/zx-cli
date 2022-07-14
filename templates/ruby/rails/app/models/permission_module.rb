module PermissionModule
  module InstanceMethodModule
    def generate_code
      max_try = 20
      try = 0
      begin
        code = SecureRandom.hex[0...8]
        try += 1
      end while self.class.exists?(code: code) && try < max_try

      if try >= 20
        errors[:code] << I18n.t("admin.system.permissions.validation.generate_code")
      else
        self.code = code
      end
    end
  end
  module ClassMethodModule
    def search(params)
      return  where(nil) if params.blank?
      query_conditions = ""
      query_hash = {}

      unless params[:kind].blank?
        query_conditions.blank? ? query_conditions << "permissions.kind like :kind" : query_conditions << " AND permissions.kind like :kind"
        query_hash[:kind] = "%#{params[:kind]}%"
      end

      unless params[:name].blank?
        query_conditions.blank? ? query_conditions << "permissions.name like :name" : query_conditions << " AND permissions.name like :name"
        query_hash[:name] = "%#{params[:name]}%"
      end

      unless params[:code].blank?
        query_conditions.blank? ? query_conditions << "permissions.code like :code" : query_conditions << " AND permissions.code like :code"
        query_hash[:code] = "%#{params[:code]}%"
      end

      unless params[:url].blank?
        query_conditions.blank? ? query_conditions << "permissions.url like :url" : query_conditions << " AND permissions.url like :url"
        query_hash[:url] = "%#{params[:url]}%"
      end

      unless params[:parent_id].blank?
        query_conditions.blank? ? query_conditions << "permissions.parent_id = :parent_id" : query_conditions << " AND permissions.parent_id = :parent_id"
        query_hash[:parent_id] = params[:parent_id]
      end

      unless params[:description].blank?
        query_conditions.blank? ? query_conditions << "permissions.description like :description" : query_conditions << " AND permissions.description like :description"
        query_hash[:description] = "%#{params[:description]}%"
      end

      where(query_conditions, query_hash)
    end

    def get_parent_permissions(name)
      permissions = where("name like ?", "%#{name}%")
      suggestions = []
      permissions.each do |permission|
        suggestions << {
          value: permission.name,
          data: permission.id
        }
      end

      return {
        suggestions: suggestions
      }
    end

    def get_permission_trees(parent_id, selected)
      records = where(parent_id: parent_id)
      results = []

      records.each do |record|
        results += self.construct_permission_tree(record.hash_tree, selected)
      end

      return results
    end

    def construct_permission_tree(permission_hash, selected)
      result = []
      permission_hash.each do |permission, children|
        result << {
          id: permission.id,
          name: permission.name,
          selected: !!selected.index(permission.id),
          children: self.construct_permission_tree(children, selected)
        }
      end
      return result
    end

    def get_js_tree_data id = nil
      #we can't return all permissions directly, perhaps it's not a valid tree
      transform_permissions = Proc.new do |p_hash|
        result = []
        p_hash.each do |parent, children|
          result << {
            id: parent.id,
            text: parent.name,
            name: parent.name,
            kind: parent.kind,
            code: parent.code,
            url: parent.url,
            description: parent.description,
            children: transform_permissions.call(children)
          }
        end
        result
      end

      if id
        data = find(id).hash_tree
      else
        data = hash_tree
      end

      transform_permissions.call data
    end

    def refresh_csr_permission(params, root)
      return true
    end

    def update_permission(params)
      #check whether code duplicated
      if where(code: params[:code]).where.not(id: params[:id]).count > 0
        return {
          success: false,
          message: 'Duplicated code'
        }
      end
      permission = find(params[:id])

      if permission.update_attributes(kind: params[:kind], name: params[:name], code: params[:code], url: params[:url], description: params[:description])

        if !refresh_csr_permission(params, permission.root)
          return {
            success: false,
            message: "Refresh CSR permission failed."
          }
        end

        return {
          success: true,
          data: {
            text: permission.name,
            kind: permission.kind,
            name: permission.name,
            code: permission.code,
            url: permission.url,
            description: permission.description
          }
        }
      else
        return {
          success: false,
          message: permission.errors.full_messages.join("\n")
        }
      end
    end

    def reparent_permission(params)
      permission = find(params[:id])
      parent = permission.parent

      if !parent
        return {
          success: false,
          message: "Can't move root permission"
        }
      end

      if parent.id == params[:parent].to_i
        return {
          success: false,
          message: "Can't move permission under same parent."
        }
      end

      permission.update parent_id: params[:parent]

      {
        success: true,
        data: true
      }
    end

    def create_permission(params)
      attrs  = params.permit(:parent_id, :name, :kind, :url, :description)
      begin
        permission = nil
        transaction do
          permission = create!(attrs)
        end

        if !refresh_csr_permission(params, permission.root)
          return {
            success: false,
            message: "Refresh CSR permission failed."
          }
        end

        return {
          success: true,
          data: {
            id: permission.id,
            text: permission.name,
            kind: permission.kind,
            code: permission.code,
            name: permission.name,
            url: permission.url,
            description: permission.description
          }
        }
      rescue Exception => error
        return {
          success: false,
          message: error.inspect
        }
      end
    end

    def delete_permission(params, ahoy)
      permission = find(params[:id])
      records = permission.as_json
      ahoy.track "[Track] Delete Permission", ActiveSupport::JSON.encode(records)
      root = permission.root
      if permission.destroy

        if !refresh_csr_permission(params, root)
          return {
            success: false,
            message: "Refresh CSR permission failed."
          }
        end

        return {
          success: true,
        }
      else
        return {
          success: false,
          message: permission.errors.full_messages.join("\n")
        }
      end
    end

    def reset_closure_tree_virtual_table
      #closure tree don't support multi database, so we add workaround code at there to change virtual table
      model_class = self
      model_class.parent.send(:remove_const, "PermissionHierarchy")
      virtual_class = model_class.parent.const_set("PermissionHierarchy", Class.new(model_class.parent.const_get("Base")))
      virtual_class.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        include ActiveModel::ForbiddenAttributesProtection
        belongs_to :ancestor, :class_name => "#{model_class}"
        belongs_to :descendant, :class_name => "#{model_class}"
        def ==(other)
          self.class == other.class && ancestor_id == other.ancestor_id && descendant_id == other.descendant_id
        end
        alias :eql? :==
        def hash
          ancestor_id.hash << 31 ^ descendant_id.hash
        end
      RUBY
      virtual_class.table_name = "permission_hierarchies"
      model_class.hierarchy_class = virtual_class
    end

  end

  def self.included(parent_module)
    parent_module.include InstanceMethodModule
    parent_module.extend ClassMethodModule
    parent_module.class_eval do
      has_many :permissions_roles, :dependent => :destroy
      has_many :roles, through: :permissions_roles

      validate :generate_code, on: :create

      has_closure_tree dependent: :destroy
    end
  end
end
