class PagesController < ApplicationController
  def home
  	if !user_signed_in?
  		redirect_to new_user_session_path, notice: 'You must be logged in'
  	end
  end

  def info
  	if !user_signed_in?
  		redirect_to new_user_session_path, notice: 'You must be logged in'
  	end
  	@siteIP = params[:dropletip]
  	@siteName = params[:dropletname]

  	if @siteIP == "" or @siteIP == nil
  		redirect_to root_path
  	end
  end

  def new
  	if !user_signed_in?
  		redirect_to new_user_session_path, notice: 'You must be logged in'
  	end
  end

  def create
  	if !user_signed_in?
  		redirect_to new_user_session_path, notice: 'You must be logged in'
  	end

  	siteName = params[:dropletname]
  	snapshotID = params[:snapshot]
  	newSite = params[:newsite]

  	regions = Digitalocean::Region.all
	sizes = Digitalocean::Size.all 
	sshs = Digitalocean::SshKey.all

	regionID = ""

	regions.regions.each do |region|
		if region.slug == "nyc3"
			regionID = region.id
		end
	end

	sizeID = ""

	sizes.sizes.each do |size|
		if size.slug == "512mb"
			sizeID = size.id
		end
	end

	sshKeys = ""

	sshs.ssh_keys.each do |ssh|
		sshKeys = sshKeys + ssh.id.to_s + ","
	end

	sshKeys.chop!

	created = Digitalocean::Droplet.create({name: siteName, size_id: sizeID, image_id: snapshotID, region_id: regionID, ssh_key_ids: sshKeys})

	if created.status == "OK"
		redirect_to root_path, notice: "Creation of " + siteName + " started."
	
	else
  		redirect_to root_path, notice: "Site creation failed"
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
