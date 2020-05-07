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
        condition = condition && (contact_id == nil || Contact.find(contact_id).company == user.company)
        # project is of the user's company
        condition = condition && (project_id == nil || Project.find(project_id).company == user.company)
        condition
      end

      can :manage, Contact do |contact|
        # company corresponds to user's
        condition = contact.company == nil || contact.company == user.company
      end

      can :manage, Project do |project|
        # company corresponds to user's
        condition = project.company == nil || project.company == user.company
        # contact is of the user's company
        condition = condition && (contact_id == nil || Contact.find(contact_id).company == user.company)
      end

    end
  end
end
