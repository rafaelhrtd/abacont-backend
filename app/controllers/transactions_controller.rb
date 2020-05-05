class TransactionsController < ApplicationController
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
        children = transaction.children.order(date: :desc).first(5)
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
        transaction = Transaction.get_by_params(params: params, user: current_user)
        render json: {
            transactions: transaction, 
            summary: Transaction.company_summary(user: current_user, params: params)
        }
    end

    private 
    def transaction_params
        params.require(:transaction).permit(:amount, :description, :category, \
            :date, :contact_id, :project_id, :bill_number, :company_id, :parent_id,\
             contact_attributes: [:name, :email, :phone, :company_id, :category],\
             project_attributes: [:name, :description, :value, :contact_id, :bill_number, :company_id, \
             contact_attributes: [:name, :email, :phone, :company_id, :category]])
    end
end
