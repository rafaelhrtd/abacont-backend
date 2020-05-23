class CompaniesController < ApplicationController
    load_and_authorize_resource
    
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

    def switch_company 
        tagging = CompanyTagging.where(user: current_user).where(company_id: params[:id]).first
        if tagging != nil
            current_user.update(company: tagging.company, role: tagging.role)
            render json: {company: tagging.company}
        else 
            render json: {}, status: :forbidden
        end
    end

    def create_invite 

    end

    private 
    def company_params
        params.require(:company).permit(:name)
    end

end
