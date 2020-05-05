class CompaniesController < ApplicationController
    def test
        print headers["Authorization"]
        render json: {
            test: "this part seems okay",
            logged_in: current_user.email
        }
    end
end
