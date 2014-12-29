#
# item model
# @author Chris Tate <test@test.com>
#

require 'net/http'

module Sinatra
	module App
		module Routing
			module item
				module Delete
					def self.registered(app)
						
						# set uri for item
						uri = '/items'
						
						# DELETE /items/(0-9)
						app.delete %r{/items/([a-zA-Z0-9]*)} do
							# guest not allowed
							if !session[:user]
								halt 401
							end
							
							# get "admin"
							user = Model::User.first(:username => 'admin')
							
							# invalid user
							if session[:user] != user.id
								halt 401
							end
							
							# get all items
							document = Model::item.find(params[:captures].first)
							
							# document not found
							if !document
								halt 404
							end
							
							# delete document
							document.delete
							
							# return success response
							response = {
								:status => 'success'
							}
							
							# send response
							respond response
						end
						
					end
				end
				
				module Get
					def self.registered(app)
						
						# set uri for item
						uri = '/items'
						
						# GET /items
						app.get uri do
							# get all items
							if @request_payload[:web_enabled]
								items = Model::item.where(:logo.ne => nil, :web_enabled => true).sort(:name.asc)
							else
								items = Model::item.sort(:name.asc)
							end
							
							# prepare data
							data = {
								:status => 'success',
								:data => items
							}
							
							# send data to response
							respond data
						end
						
						# GET /items/search
						app.get %r{/items/search} do
							# get all items
							items = Model::item.where(:name => { :$regex => /#{@request_payload[:name]}/i }).sort(:name.asc)
							
							# prepare data
							data = {
								:status => 'success',
								:data => items
							}
							
							# send data to response
							respond data
						end
						
						# GET /items/wiki
						app.get %r{/items/wiki} do
							url = URI.parse("http://en.wikipedia.org/w/api.php?action=parse&page=#{@request_payload[:name]}&prop=text&format=json")
							req = Net::HTTP::Get.new(url.to_s)
							res = Net::HTTP.start(url.host, url.port) {|http|
								http.request(req)
							}
							
							# get all items
							items = Model::item.where(:name => { :$regex => /#{@request_payload[:name]}/i }).sort(:name.asc)
							
							# get data
							data = JSON.parse res.body
							
							# prepare data
							data = {
								:status => 'success',
								:data => data
							}
							
							# send data to response
							respond data
						end
						
						# GET /items/(0-9)
						app.get %r{/items/([\-_a-zA-Z0-9]*)} do
							# get document
							document = Model::item.first(:id => params[:captures].first)
							if !document
								document = Model::item.first(:url => params[:captures].first)
							end
							
							if !document
								halt 404
							end
							
							data = {
								:status => 'success',
								:document => document
							}
							
							# send data to response
							respond data
						end
						
					end
				end
				
				module Patch
					def self.registered(app)
						
						# set uri for item
						uri = '/items'
						
						# PATCH /items/(0-9)
						app.patch %r{/items/([a-zA-Z0-9]*)} do
							# guest not allowed
							if !session[:user]
								halt 401
							end
							
							# get "admin"
							user = Model::User.first(:username => 'admin')
							
							# invalid user
							if session[:user] != user.id
								halt 401
							end
							
							# get document
							document = Model::item.find(params[:captures].first)
							
							if !document
								halt 404
							end
							
							document.icon = @request_payload['icon']
							document.logo = @request_payload['logo']
							document.name = @request_payload['name']
							document.url = @request_payload['url']
							document.web_enabled = @request_payload['web_enabled']
							document.website = @request_payload['website']
							document.wiki = @request_payload['wiki']
							document.save
							
							data = {
								:status => 'success',
								:data => document
							}
							
							# send data to response
							respond data
						end
						
					end
				end
				
				module Post
					def self.registered(app)
						
						# set uri for item
						uri = '/items'
						
						# POST /items
						app.post uri do
							# guest not allowed
							if !session[:user]
								halt 401
							end
							
							# get "admin"
							user = Model::User.first(:username => 'admin')
							
							# invalid user
							if session[:user] != user.id
								halt 401
							end
							
							# create new document
							document = Model::item.new(
							:created_at => Time.new,
							:name => @request_payload['name'],
							:url => @request_payload['url'],
							:web_enabled => @request_payload['web_enabled'],
							:website => @request_payload['website'],
							:wiki => @request_payload['wiki']
							)
							document.save
							
							# set Created status
							status 201
							
							# prepare data
							data = {
								:status => 'success',
								:data => document
							}
							
							# send data to response
							respond data
						end
						
					end
				end
				
			end
		end
	end
end
