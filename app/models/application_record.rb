class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  def self.get_dates(month: nil, year: nil, user:)

    print "\n\n\n wee #{month} #{year} \n\n\n"
    records = nil

    if self == Transaction
      column = "date"
      # both month and year are given
      if month != nil && year != nil
        records = self.where(company: user.company).where("extract(month from #{column}) = ?", month)
        records = records.where(company: user.company).where("extract(year from #{column}) = ?", year)
      # only year is given
      elsif month == nil && year != nil
        records = self.where(company: user.company).where("extract(year from #{column}) = ?", year)
      # none is given. return all.
      else 
        records = self.all
      end
      return records
    # contact or project
    else 
      if self == Contact 
        column = "updated_at"
      else 
        column = "created_at"
      end 
      # both month and year are given
      if month != nil && year != nil
        records = self.where(company: user.company).where("extract(month from #{column}) = ?", month)
        records = records.where(company: user.company).where("extract(year from #{column}) = ?", year)
      # only year is given
      elsif month == nil && year != nil
        records = self.where(company: user.company).where("extract(year from #{column}) = ?", year)
      # none is given. return all.
      else 
        records = self.all
      end
      return records
    end
  end
end
