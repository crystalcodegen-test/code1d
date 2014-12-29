#
# bill_line model
# @author Chris Tate <test@test.com>
#

require 'net/http'

module Sinatra
	module App
		module Routing
			module bill_line
				module Delete
					def self.registered(app)
						
						# set uri for bill_line
						uri = '/bill_lines'
						
						# DELETE /bill_lines/(0-9)
						app.delete %r{/bill_lines/([a-zA-Z0-9]*)} do
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
							
							# get all bill_lines
							document = Model::bill_line.find(params[:captures].first)
							
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
						
						# set uri for bill_line
						uri = '/bill_lines'
						
						# GET /bill_lines
						app.get uri do
							# get all bill_lines
							if @request_payload[:web_enabled]
								bill_lines = Model::bill_line.where(:logo.ne => nil, :web_enabled => true).sort(:name.asc)
							else
								bill_lines = Model::bill_line.sort(:name.asc)
							end
							
							# prepare data
							data = {
								:status => 'success',
								:data => bill_lines
							}
							
							# send data to response
							respond data
						end
						
						# GET /bill_lines/search
						app.get %r{/bill_lines/search} do
							# get all bill_lines
							bill_lines = Model::bill_line.where(:name => { :$regex => /#{@request_payload[:name]}/i }).sort(:name.asc)
							
							# prepare data
							data = {
								:status => 'success',
								:data => bill_lines
							}
							
							# send data to response
							respond data
						end
						
						# GET /bill_lines/wiki
						app.get %r{/bill_lines/wiki} do
							url = URI.parse("http://en.wikipedia.org/w/api.php?action=parse&page=#{@request_payload[:name]}&prop=text&format=json")
							req = Net::HTTP::Get.new(url.to_s)
							res = Net::HTTP.start(url.host, url.port) {|http|
								http.request(req)
							}
							
							# get all bill_lines
							bill_lines = Model::bill_line.where(:name => { :$regex => /#{@request_payload[:name]}/i }).sort(:name.asc)
							
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
						
						# GET /bill_lines/(0-9)
						app.get %r{/bill_lines/([\-_a-zA-Z0-9]*)} do
							# get document
							document = Model::bill_line.first(:id => params[:captures].first)
							if !document
								document = Model::bill_line.first(:url => params[:captures].first)
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
						
						# set uri for bill_line
						uri = '/bill_lines'
						
						# PATCH /bill_lines/(0-9)
						app.patch %r{/bill_lines/([a-zA-Z0-9]*)} do
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
							document = Model::bill_line.find(params[:captures].first)
							
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
						
						# set uri for bill_line
						uri = '/bill_lines'
						
						# POST /bill_lines
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
							document = Model::bill_line.new(
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
