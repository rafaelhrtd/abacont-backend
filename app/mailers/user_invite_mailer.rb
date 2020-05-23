class UserInviteMailer < ApplicationMailer
    default from: "noreply@clientapp.com"

    def invitation
        @user = params[:user]
        @token = params[:token]
        @email = params[:email]
        mail(to: @email, subject: "#{@user.name} te invita a su equipo")
    end
end
