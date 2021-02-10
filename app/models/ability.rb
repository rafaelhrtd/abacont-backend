# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user, params)
    if user.present?
      contact_id = params[:contact_id]
      project_id = params[:project_id]

      # Transaction privileges
      can :show, Transaction do |tran|
        condition = user.check_privilege(company: tran.company, symbol: :can_read)
      end

      can :create, Transaction do |tran|
        condition = user.check_privilege(company: tran.company, symbol: :can_write)
      end

      can [:update, :edit, :destroy], Transaction do |tran|
        condition = user.check_privilege(company: tran.company, symbol: :can_edit)
      end

      can :index, Transaction do |tran|
        condition = params[:contact_id] == nil || user.company.contacts.where(id: params[:contact_id]).count != 0
        condition = condition && (params[:project_id] == nil || user.company.projects.where(id: params[:project_id]).count != 0)
        condition
      end

      # Company privileges
      can [:index, :switch_company], Company do |company|
        true
      end

      can [:edit, :update, :employees], Company do |company|
        condition = (user.company == company && user.check_privilege(company: company, symbol: :can_edit))
        condition
      end

      can [:send_invite, :invite_list, :destroy_invite, :resend_invite], Company do |company|
        condition = user.check_privilege(company: company, symbol: :can_invite)
        condition 
      end

      can [:update_permissions, :delete_employee], Company do |company|
        company = Company.find(params[:company_tagging][:company_id])
        company.owner == user
      end

      can [:get_invite, :claim_invite, :create], Company do |company|
        true 
      end
      
      # Contact privileges
      can :index, Contact do |contact|
        # company corresponds to user's
        condition = contact.company == nil || contact.company == user.company
      end

      can :show, Contact do |contact|
        condition = user.check_privilege(company: contact.company, symbol: :can_read)
      end

      can :create, Contact do |contact|
        condition = user.check_privilege(company: contact.company, symbol: :can_write)
      end

      can [:update, :edit, :destroy], Contact do |contact|
        condition = user.check_privilege(company: contact.company, symbol: :can_edit)
      end


      # Project privileges
      can :index, Project do |project|
        # company corresponds to user's
        condition = project.company == nil || project.company == project.company
      end

      can :show, Project do |project|
        condition = user.check_privilege(company: project.company, symbol: :can_read)
      end

      can :create, Project do |project|
        condition = user.check_privilege(company: project.company, symbol: :can_write)
      end

      can [:update, :edit, :destroy], Project do |project|
        condition = user.check_privilege(company: project.company, symbol: :can_edit)
      end

    else 
      can [:get_invite, :claim_invite], Company do |company|
        true 
      end
    end
  end
end
