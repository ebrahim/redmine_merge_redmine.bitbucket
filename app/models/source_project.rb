class SourceProject < ActiveRecord::Base
  include SecondDatabase
  set_table_name :projects

  has_many :enabled_modules, :class_name => 'SourceEnabledModule', :foreign_key => 'project_id'
  has_and_belongs_to_many :trackers, :class_name => 'SourceTracker', :join_table => 'projects_trackers', :foreign_key => 'project_id', :association_foreign_key => 'tracker_id'
  
  def self.migrate
    all(:order => 'lft ASC').each do |source_project|
      project = Project.find_by_identifier(source_project.identifier)
      if !project.nil?
        RedmineMerge::Mapper.add_project(source_project.id, project.id)
        next
      end
      project = Project.find_by_name(source_project.name)
      if !project.nil?
        RedmineMerge::Mapper.add_project(source_project.id, project.id)
        next
      end
      
      project = Project.create!(source_project.attributes)
      project.status = source_project.status
      if source_project.enabled_modules
        project.enabled_module_names = source_project.enabled_modules.collect(&:name)
      end

      if source_project.trackers
        source_project.trackers.each do |source_tracker|
          merged_tracker = Tracker.find_by_name(source_tracker.name)
          # XXX: The following line makes some troubles at times
          project.trackers << merged_tracker if merged_tracker
        end
      end
      
      # Parent/child projects
      if source_project.parent_id
        project.set_parent!(Project.find_by_id(RedmineMerge::Mapper.get_new_project_id(source_project.parent_id)))
      end
      RedmineMerge::Mapper.add_project(source_project.id, project.id)
    end
  end
end
