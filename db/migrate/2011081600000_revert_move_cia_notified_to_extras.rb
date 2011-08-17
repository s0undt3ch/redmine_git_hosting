class RevertMoveCiaNotifiedToExtras < ActiveRecord::Migration
	def self.up

		add_column :changesets, :notified_cia, :integer, :default=>0

		Project.find(:all).each {|project|
			if project.repository.is_a?(Repository::Git)
				project.repository.changesets.each { |revision|
					if !project.repository.extra.notified_cia.nil? && project.repository.extra.notified_cia.include?(revision.scmid)
						revision.notified_cia = 1
					else
						revision.notified_cia = 0
					end
					revision.save
				}
			end
		}

		remove_column :git_repository_extras, :notified_cia
	end

	def self.down
		remove_column :changesets, :notified_cia
		add_column :git_repository_extras, :notified_cia, :text, :default=>[]
	end

	def self.table_exists?(name)
		ActiveRecord::Base.connection.tables.include?(name)
	end
end
