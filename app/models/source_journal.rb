class SourceJournal < ActiveRecord::Base
  include SecondDatabase
  set_table_name :journals

  belongs_to :journalized, :polymorphic => true
  belongs_to :issue, :class_name => 'SourceIssue', :foreign_key => :journalized_id
  
  def self.migrate
    all.each do |source_journals|

      journal = Journal.find(:first, :conditions => {:notes => source_journals.notes,
                             :journalized_type => source_journals.journalized_type})
      if journal.nil?
        journal = Journal.create(source_journals.attributes)
        journal.issue = Issue.find_by_subject(source_journals.issue.subject)
        journal.save() if journal.journalized_id
      end

      RedmineMerge::Mapper.add_journal(source_journals.id, journal.id) if journal.journalized_id
    end
  end
end
