class CompaniesController < ApplicationController
    load_and_authorize_resource
    skip_before_action :authenticate_user!, only: :get_invite
    
    def index 
        render json: {companies: current_user.companies}
    end 

    def update
        company = current_user.companies.where(id: params[:id]).first
        if company != nil
            if company.update(company_params)
                render json: {company: company}
            else 
                render json: {errors: true, company: company.errors}
            end
        else
            render json: {}, status: :forbidden
        end
    end

    def employees
        company = Company.find(current_user.company_id)
        render json: {
            employees: company.employees
        }
    end

    def switch_company 
        tagging = CompanyTagging.where(user: current_user).where(company_id: params[:id]).first
        if tagging != nil
            user = current_user.switch_company(company: tagging.company)
            render json: {company: tagging.company}
        else 
            render json: {}, status: :forbidden
        end
    end

    def create
        company = Company.create_new(name: params[:company][:name], user: current_user)
        print "\n\nerrors: #{company.errors.count}\n\n"
        render json: {
            errors: company.errors.count == 0 ? {} : company.errors,
            company: company.errors.count == 0 ? company : company.errors
        }
    end

    def send_invite 
        invite = UserInvite.create(invite_params)
        if invite.persisted?
            UserInviteMailer.with(user: current_user, token: invite.token, email: invite.email).invitation.deliver_now
            render json: {invite: invite}
        else 
            render json: {errors: invite.errors}
        end
    end

    def invite_list 
        render json: {invites: current_user.company.user_invites}
    end

    def destroy_invite 
        current_user.company.user_invites.where(id: params[:user_invite_id]).first.destroy 
        render json: {invite: nil}
    end

    def resend_invite
        invite = current_user.company.user_invites.where(id: params[:user_invite_id]).first
        UserInviteMailer.with(user: current_user, token: invite.token, email: invite.email).invitation.deliver_now
        render json: {success: true}
    end

    def claim_invite
        invite = UserInvite.where(token: params[:token]).first
        if invite == nil
            render json: {errors: true}
        end
        if params[:user] != nil 
            if params[:accepted] == true
                tag = CompanyTagging.create_from_invite(invite: invite, user: current_user)
                current_user.switch_company(company: invite.company)
                invite.destroy if (tag.errors.count == 0)
                render json: {success: true}
            else 
                invite.destroy
                render json: {success: true}
            end
        end
    end

    def get_invite
        invite = UserInvite.where(token: params[:token]).first 
        if invite == nil 
            render json: {error: true}
        else 
            user = User.where(email: invite.email.downcase).first
            sign_out(current_user) if current_user != nil
            sign_in(user) if user != nil
            render json: {invite: invite, 
                            name: invite.user.first_name, 
                            company_name: invite.user.company.name,
                            user: user,
                            companies: user.nil? ? nil : user.companies,
                            company: user.nil? ? nil : user.company}
        end
    end

    def update_permissions
        employee = User.find(params[:company_tagging][:user_id])
        company = Company.find(params[:company_tagging][:company_id])
        tag = CompanyTagging.where(user: employee).where(company: company).first
        tag.update(tag_params)
        employee.switch_company(company: company)
        render json: {
            tagging: tag
        }
    end

    def delete_employee
        employee = User.find(params[:company_tagging][:user_id])
        company = Company.find(params[:company_tagging][:company_id])
        tag = CompanyTagging.where(user: employee).where(company: company).first
        tag.destroy
        render json: {
            success: true
        }
    end

    private 
    def company_params
        params.require(:company).permit(:name)
    end

    def invite_params
        params["invite"]['token'] = SecureRandom.urlsafe_base64
        params["invite"]['company_id'] = current_user.company_id
        params["invite"]['user_id'] = current_user.id
        print "\n\n #{params} \n\n"
        params.require(:invite).permit(:email, :can_read, \
            :can_write, :can_edit, :can_invite, :token, :company_id, :user_id)
    end

    def tag_params
        params.require(:company_tagging).permit(:can_read, :can_write, :can_edit, :can_invite)
    end

end
