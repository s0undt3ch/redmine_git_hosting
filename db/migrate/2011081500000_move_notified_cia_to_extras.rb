class MoveNotifiedCiaToExtras < ActiveRecord::Migration
	def self.up

		# Need this migration step for my production environment which is already running this code
		begin
			add_column :git_repository_extras, :notify_cia, :integer, :default => 1
		rescue
		end
		begin
			add_column :git_repository_extras, :notified_cia, :text, :default => []
		rescue
		end

		Project.find(:all).each {|project|
			if project.repository.is_a?(Repository::Git)
				extra = GitRepositoryExtra.find(:first, :conditions => ["repository_id = ?", project.repository.id])
				if extra.nil?
					extra = GitRepositoryExtra.new
					extra.repository = project.repository
					extra.save
				end
				if extra.notified_cia.nil?
					extra.notified_cia = []
				end
				extra.notify_cia = project.repository.notify_cia || 0
				project.repository.changesets.each {|changeset|
					if not changeset.notified_cia.nil? && changeset.notified_cia==1
						extra.notified_cia.push changeset.scmid
					end
				}
				extra.save
			end
		}
		remove_column :changesets, :notified_cia
		remove_column :repositories, :notify_cia
	end

	def self.down
		remove_column :git_repository_extras, :notified_cia
	end
end
