class PagesController < ApplicationController
  def home
  	if !user_signed_in?
  		redirect_to new_user_session_path, notice: 'You must be logged in'
  	end
  end

  def new
  	if !user_signed_in?
  		redirect_to new_user_session_path, notice: 'You must be logged in'
  	end
  end

  def delete
  		if !user_signed_in?
	  		redirect_to new_user_session_path, notice: 'You must be logged in'
	  	end
	  	Spawnling.new do
	  		siteID = params[:dropletid]
	  		siteName = params[:dropletname]
	  		snapshotName = siteName + " PreDestroy"
		  	poweroff = Digitalocean::Droplet.power_off(siteID)
		  	if poweroff.status == "OK" then
		  		server = Digitalocean::Droplet.find(siteID)
		  		while server.droplet.status != "off" do
		  			sleep(5)
		  			server = Digitalocean::Droplet.find(siteID)
		  		end
		  		snapshot = Digitalocean::Droplet.snapshot(siteID, {name: snapshotName})
	  			if snapshot.status == "OK" then
		  			server = Digitalocean::Droplet.find(siteID)
			  		while server.droplet.status != "active" do
			  			sleep(5)
			  			server = Digitalocean::Droplet.find(siteID)
			  		end

			  		serverDelete = Digitalocean::Droplet.destroy(siteID)
			  	end
	  		end
	  	end

	  	redirect_to root_path, notice: "Dev Server Delete Initiated. Please wait a few minutes for it to finish."
  end

  
end
