#encoding: utf-8
class PermissionPolicy
  attr_reader :current_user, :permission_model, :permissions, :permission_names

  def initialize(current_user, args)
    if args.instance_of? Array
      model_class = args.last
    else
      model_class = args
    end
    @current_user = current_user
    @permission_model = model_class
    @permission_names = []
    @permissions = []
    model_class
      .select(:code, :name)
      .joins(roles: :users)
      .where(users: {email: current_user.email})
      .each do |permission|
      @permission_names << permission.name
      @permissions << permission.code
    end
    @permission_names = @permission_names.uniq
    @permissions = @permissions.uniq

    #for development mode
    if Rails.env.development?
      def @permissions.include? permission
        return true
      end
    end
  end

  def show_configuration?
    permissions.include? PermissionConstant::Permissions[:configuration][:self]
  end

  def show_configuration_write?
    permissions.include? PermissionConstant::Permissions[:configuration][:write]
  end

  def show_operation?
    permissions.include? PermissionConstant::Permissions[:operation][:self]
  end

  def show_operation_write?
    permissions.include? PermissionConstant::Permissions[:operation][:write]
  end

  def show_schedule?
    permissions.include? PermissionConstant::Permissions[:schedule][:self]
  end

  def show_schedule_write?
    permissions.include? PermissionConstant::Permissions[:schedule][:write]
  end

  def show_management?
    permissions.include? PermissionConstant::Permissions[:management][:self]
  end

  def show_task?
    permissions.include? PermissionConstant::Permissions[:task][:self]
  end

  def show_task_write?
    permissions.include? PermissionConstant::Permissions[:task][:write]
  end

  def show_ticket_task?
    permissions.include? PermissionConstant::Permissions[:ticket][:self]
  end

  def show_ticket_task_write?
    permissions.include? PermissionConstant::Permissions[:ticket][:write]
  end

  def show_release_management?
    permissions.include? PermissionConstant::Permissions[:release_management][:self]
  end

  def show_release_management_write?
    permissions.include? PermissionConstant::Permissions[:release_management][:write]
  end

  def show_option?
    permissions.include? PermissionConstant::Permissions[:option][:self]
  end

  def show_option_write?
    permissions.include? PermissionConstant::Permissions[:option][:write]
  end

  def SCE?
    permissions.include? PermissionConstant::Permissions[:utility][:sce]
  end

  def APS?
    permissions.include? PermissionConstant::Permissions[:utility][:aps]
  end

  def SMUD?
    permissions.include? PermissionConstant::Permissions[:utility][:smud]
  end

  def PGE?
    permissions.include? PermissionConstant::Permissions[:utility][:pge]
  end

  def MBCP?
    permissions.include? PermissionConstant::Permissions[:utility][:mbcp]
  end

  def CMS?
    permissions.include? PermissionConstant::Permissions[:utility][:cms]
  end

  def GRIDX?
    permissions.include? PermissionConstant::Permissions[:utility][:gridx]
  end

  def UTILITYA?
    permissions.include? PermissionConstant::Permissions[:utility][:utilitya]
  end

  def ENGIE?
    permissions.include? PermissionConstant::Permissions[:utility][:engie]
  end

  def EVERGY?
    permissions.include? PermissionConstant::Permissions[:utility][:evergy]
  end
end
