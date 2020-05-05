class ProjectsController < ApplicationController
    def index 
        render json: {objects: current_user.company.projects}
    end
end
