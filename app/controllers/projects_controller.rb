class ProjectsController < ApplicationController
    load_and_authorize_resource

    def index 
        render json: {objects: current_user.company.projects}
    end

    def create 
        project = Project.create(project_params)
        if project.persisted?
            render json: {project: project}
        else 
            render json: {errors: true, project: project.errors}
        end
    end

    def destroy 
        project = Project.find(params[:id])
        project = project.destroy_with_params(params: params, user: current_user)
        render json: project
    end


    def index 
        search_projects = Project.get_search_results(user: current_user, params: params)
        show_projects = Project.where(company: current_user.company).order(updated_at: :desc).first(5)
        render json: {projects: show_projects, objects: search_projects}
    end


    def show
        project = Project.find(params[:id])
        render json: project.show
    end

    def update
        project = Project.find(params[:id])
        if project.update(project_params)
            render json: {project: project}
        else 
            render json: {errors: true, project: project.errors}
        end
    end

    private
    def project_params
        params.require(:project).permit(:name, :description, :value, \
            :bill_number, :company_id, :contact_id,\
            contact_attributes: [:name, :email, :phone, :company_id, :category])
    end
end
