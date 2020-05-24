class UserInviteMailer < ApplicationMailer
    default from: "noreply@clientapp.com"

    def invitation
        @user = params[:user]
        @token = params[:token]
        @email = params[:email]
        @link = ENV["FRONT_END_ADDRESS"] +"invitado?token=" + @token 
        mail(to: @email, subject: "#{@user.first_name} te invita a su equipo")
    end
end
