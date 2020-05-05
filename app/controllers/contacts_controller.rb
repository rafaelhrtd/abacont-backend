class ContactsController < ApplicationController
    respond_to :json

    def create
        contact = Contact.create(contact_params)
        if contact.persisted?
            render json: {contact: contact}
        else 
            render json: {errors: true, contact: contact.errors}
        end
    end

    def show 
        contact = Contact.find(params[:id])
        if !contact.nil?
            render json: {contact: contact, transactions: contact.latest_transactions}
        else 
            render json: {}
        end
    end

    def index 
        if !params[:category].nil?
            contacts = current_user.company.contacts.where(category: params[:category])
            render json: {objects: contacts}
        else 
            contacts = current_user.company.contacts
            render json: {objects: contacts}
        end
    end

    def update
        contact = Contact.find(params[:id])
        if contact.update(contact_params)
            render json: {contact: contact}
        else 
            render json: {errors: true, contact: contact.errors}
        end
    end

    private 

    def contact_params
        params[:contact][:company_id] = current_user.company_id
        params.require(:contact).permit(:name, :email, :phone, :category, :company_id)
    end
end
