require "uri"
require "net/http"

module GitHostingHelper

	def self.git_daemon_enabled(repository, value)
		gd = 1
		if repository && !repository.extra.nil?
			gd = repository.extra[:git_daemon] ? repository.extra[:git_daemon] : gd
		end
		gd = repository.project.is_public ? gd : 0
		return return_selected_string(gd, value)
	end

	def self.git_http_enabled(repository, value)
		gh = 1
		if repository && !repository.extra.nil?
			gh = repository.extra[:git_http] ? repository.extra[:git_http] : gh
		end
		return return_selected_string(gh, value)
	end

	def self.git_notify_cia(repository, value)
		nc = 0
		if repository
			nc = repository[:notify_cia] ? repository[:notify_cia] : nc
		end
		return return_selected_string(nc, value)
	end

	def self.return_selected_string(found_value, to_check_value)
		if found_value == to_check_value
			return "selected='selected'"
		else
			return ""
		end
	end

	@@file_actions = {
		"a" => "add",
		"m" => "modify",
		"r" => "remove",
		"d" => "remove"
	}

	@http_server = nil

	def url_for_revision(revision)
		rev = revision.respond_to?(:identifier) ? revision.identifier : revision
		shorten_url(
			url_for(:controller => 'repositories', :action => 'revision', :id => revision.project,
				:rev => rev, :only_path => false, :host => Setting['host_name'], :protocol => Setting['protocol']
			)
		)
	end

	def url_for_revision_path(revision, path)
		rev = revision.respond_to?(:identifier) ? revision.identifier : revision
		shorten_url(
			url_for(:controller => 'repositories', :action => 'entry', :id => revision.project,
				:rev => rev, :path => path, :only_path => false, :host => Setting['host_name'],
				:protocol => Setting['protocol']
			)
		)
	end

	def map_file_action(action)
		@@file_actions.fetch(action.downcase, action)
	end

	def shorten_url(url)
		if @http_server.nil?
			@uri = URI.parse("http://tinyurl.com/api-create.php")
			@http_server = Net::HTTP.new(@uri.host, @uri.port)
			@http_server.open_timeout = 1 # in seconds
			@http_server.read_timeout = 1 # in seconds
		end
		uri = @uri
		uri.query = "url=#{url}"
		request = Net::HTTP::Get.new(uri.request_uri)
		begin
			response = @http_server.request(request)
			GitHosting.logger.debug "Shortened URL is: #{response.body}"
			return response.body
		rescue Exception => e
			GitHosting.logger.warn "Failed to shorten url: #{e}"
			return url
		end
	end

end
