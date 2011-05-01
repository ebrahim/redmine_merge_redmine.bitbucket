class SourceVersion < ActiveRecord::Base
  include SecondDatabase
  set_table_name :versions

  def self.migrate
    all.each do |source_version|

      version = Version.find_by_name(source_version.name)
      if version.nil?
        version = Version.create(source_version.attributes)
        version.project = Project.find(RedmineMerge::Mapper.get_new_project_id(source_version.project_id))
        version.save()
      end

      RedmineMerge::Mapper.add_version(source_version.id, version.id)
    end
  end
end
