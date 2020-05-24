# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user, params)
    if user.present?
      contact_id = params[:contact_id]
      project_id = params[:project_id]

      can :manage, Transaction do |tran|
        # company corresponds to user's
        condition = tran.company == nil || tran.company == user.company
        # contact is of the user's company
        condition = condition && (contact_id == nil || Contact.find(contact_id).company == user.company) || tran.contact_id == 0
        # project is of the user's company
        condition = condition && (project_id == nil || Project.find(project_id).company == user.company) || tran.project_id == 0
        condition
      end

      can :index, Transaction do |tran|
        condition = params[:contact_id] == nil || user.company.contacts.where(id: params[:contact_id]).count != 0
        condition = condition && (params[:project_id] == nil || user.company.projects.where(id: params[:project_id]).count != 0)
        condition
      end

      can [:index, :switch_company], Company do |company|
        true
      end

      can [:edit, :update], Company do |company|
        condition = (user.company == company && user.check_privilege(company: company, symbol: :can_edit))
        condition
      end

      can [:send_invite, :invite_list, :destroy_invite, :resend_invite], Company do |company|
        condition = user.check_privilege(company: company, symbol: :can_invite)
        condition 
      end

      can [:get_invite, :claim_invite], Company do |company|
        return true 
      end

      can :manage, Contact do |contact|
        # company corresponds to user's
        condition = contact.company == nil || contact.company == user.company
      end

      can :manage, Project do |project|
        # company corresponds to user's
        condition = project.company == nil || project.company == user.company
        # contact is of the user's company
        condition = condition && (contact_id == nil || Contact.find(contact_id).company == user.company) || project.contact_id == 0
      end

    else 
      can [:get_invite, :claim_invite], Company do |company|
        return true 
      end
    end
  end
end
