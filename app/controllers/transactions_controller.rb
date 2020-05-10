class TransactionsController < ApplicationController
    load_and_authorize_resource
    def create 
        transaction = Transaction.create(transaction_params)
        if transaction.persisted?
            render json: {transaction: transaction}
        else 
            render json: {errors: true, transaction: transaction.errors}
        end
    end

    def show 
        transaction = Transaction.find(params[:id])
        transaction.contact_name = transaction.contact.name if !transaction.contact.nil?
        transaction.project_name = transaction.project.name if !transaction.project.nil?
        children = transaction.children.order(date: :desc).first(5)
        children.each do |child|
            child.contact_name = child.contact.name if !child.contact.nil?
            child.project_name = child.project.name if !child.project.nil?
        end
        
        if !transaction.nil? 
            render json: {transaction: transaction, children: children}
        else 
            render json: {}
        end
    end

    def update
        transaction = Transaction.find(params[:id])
        if transaction.update(transaction_params)
            render json: {transaction: transaction}
        else 
            render json: {errors: true, transaction: transaction.errors}
        end
    end

    def index 
        object = Transaction.get_by_params(params: params, user: current_user)
        render json: object
    end

    def destroy 
        transaction = Transaction.find(params[:id])
        transaction = transaction.destroy_with_params(params: params, user: current_user)
        render json: transaction
    end

    private 
    def transaction_params
        params.require(:transaction).permit(:amount, :description, :category, \
            :date, :contact_id, :project_id, :bill_number, :company_id, :parent_id,\
            :payment_type, :cheque_number,\
             contact_attributes: [:name, :email, :phone, :company_id, :category],\
             project_attributes: [:name, :description, :value, :contact_id, :bill_number, :company_id, \
             contact_attributes: [:name, :email, :phone, :company_id, :category]])
    end
end
