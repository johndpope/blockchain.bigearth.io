class UsersController < ApplicationController
  before_action :set_user, only: [:edit, :update, :destroy]
  before_action :authenticate_user!


  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.includes(:chains).find params[:id]
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    email = @user.email
    
    # Capture chain titles for final email
    chain_titles = @user.chains.map do |chain|
      chain.title
    end
    
    # Destroy all nodes belonging to this user
    @user.chains.each do |chain|
      config = {
        title: chain.title,
        email: email,
        type: 'blockchain'
      }
      # Queue up BigEarth::Blockchain::DestroyNodeJob
      BigEarth::Blockchain::DestroyNodeJob.perform_later config
      
      # Destroy the DNS A record
      BigEarth::Blockchain::DestroyDNSRecordJob.perform_later config
    end
    
    # Send a final email to the user
    BigEarth::Blockchain::UserDestroyedEmailJob.perform_later email, chain_titles
      
    # Delete the user from DB
    @user.destroy
    respond_to do |format|
      format.html { redirect_to root_url, notice: "User '#{email}' was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find params[:id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :company, :location, :phone_number, chains_attributes: [:pub_key, :title, :flavor, :node_created, :ipv4_address, :ipv6_address, :user_id])
    end
end
