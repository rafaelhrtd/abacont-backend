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
        search_contacts = Contact.get_search_results(user: current_user, params: params)
        show_contacts = Contact.where(company: current_user.company)\
            .where(category: params[:category]).order(updated_at: :desc).first(5)
        render json: {contacts: show_contacts, objects: search_contacts}
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
