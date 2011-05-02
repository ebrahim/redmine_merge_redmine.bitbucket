class SourceWiki < ActiveRecord::Base
  include SecondDatabase
  set_table_name :wikis

  def self.migrate
    all.each do |source_wiki|

      project = Project.find(RedmineMerge::Mapper.get_new_project_id(source_wiki.project_id))

      wiki = Wiki.find(:first, :conditions => {:project_id => project.id})
      if wiki.nil?
        wiki = Wiki.create(source_wiki.attributes)
        wiki.project = project
      end
      wiki.start_page = source_wiki.start_page
      wiki.save()

      RedmineMerge::Mapper.add_wiki(source_wiki.id, wiki.id)
    end
  end
end
