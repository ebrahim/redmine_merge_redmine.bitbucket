class SourceIssue < ActiveRecord::Base
  include SecondDatabase
  set_table_name :issues

  belongs_to :author, :class_name => 'SourceUser', :foreign_key => 'author_id'
  belongs_to :assigned_to, :class_name => 'SourceUser', :foreign_key => 'assigned_to_id'
  belongs_to :status, :class_name => 'SourceIssueStatus', :foreign_key => 'status_id'
  belongs_to :tracker, :class_name => 'SourceTracker', :foreign_key => 'tracker_id'
  belongs_to :project, :class_name => 'SourceProject', :foreign_key => 'project_id'
  belongs_to :priority, :class_name => 'SourceEnumeration', :foreign_key => 'priority_id'
  belongs_to :category, :class_name => 'SourceIssueCategory', :foreign_key => 'category_id'
  belongs_to :fixed_version, :class_name => 'SourceVersion', :foreign_key => 'fixed_version_id'
  
  def self.migrate
    all.each do |source_issue|
      issue = Issue.find_by_subject(source_issue.subject)
      if issue.nil?
        attrs = source_issue.attributes
        attrs[:project_id] = Project.find_by_name(source_issue.project.name).id
        issue = Issue.create(attrs)
        issue.project = Project.find_by_name(source_issue.project.name)
        issue.author = User.find_by_login(source_issue.author.login)
        issue.assigned_to = User.find_by_login(source_issue.assigned_to.login) if source_issue.assigned_to
        issue.status = IssueStatus.find_by_name(source_issue.status.name)
        issue.tracker = Tracker.find_by_name(source_issue.tracker.name)
        issue.priority = IssuePriority.find_by_name(source_issue.priority.name)
        issue.category = IssueCategory.find_by_name(source_issue.category.name) if source_issue.category
        issue.fixed_version = Version.find_by_name(source_issue.fixed_version.name) if source_issue.fixed_version
        issue.save()
      end
      
      RedmineMerge::Mapper.add_issue(source_issue.id, issue.id)
    end
  end
end
