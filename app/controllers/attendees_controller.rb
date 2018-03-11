class AttendeesController < ApplicationController
  before_action :set_attendee, only: [:show, :edit, :update, :destroy]
  load_and_authorize_resource


  # GET /attendees
  # GET /attendees.json
  def index
    @event= Event.find(params[:event_id])
    if current_user.id.to_i===@event.user_id.to_i
      @attendees = @event.attendees.paginate(:page => params[:page],:per_page =>9 ).order('created_at DESC')
    else
      redirect_back(fallback_location: root_path, status: 403)
    end
  end

  # GET /attendees/1
  # GET /attendees/1.json
  def show
    begin
      @qr = RQRCode::QRCode.new( attendee_url(@attendee.id), :size => 5, :level => :h )
    rescue RQRCode::QRCodeRunTimeError => e
      logger.info "Manage qr error show #{e.inspect}"
    end
    respond_to do |format|
      format.html  { render :layout => 'no_header' }
      format.js
      format.json
    end
  end

  # GET /attendees/new
  def new
    if current_user.has_role? :admin
      logger.info 'loaded'
      @attendee = Attendee.new
    else
      logger.info 'not loaded'
      redirect_back(fallback_location: root_path, status: 403)
    end
  end

  # GET /attendees/1/edit
  def edit
    unless current_user.has_role? :admin
      redirect_back(fallback_location: root_path, status: 403)
    end
  end

  # POST /attendees
  # POST /attendees.json
  def create
    @attendee = current_user.attendees.new(attendee_params)

    respond_to do |format|
      if @attendee.save
        begin
          @qr = RQRCode::QRCode.new( attendee_url(@attendee.id), :size => 5, :level => :h )
        rescue RQRCode::QRCodeRunTimeError => e
          logger.info "Manage qr error in create #{e.inspect}"
        end
        format.html { redirect_to @attendee, notice: 'Attendee was successfully created.' }
        format.json { render :show, status: :created, location: @attendee }
        format.js
      else
        logger.info @attendee.inspect
        format.html { render :new }
        format.json { render json: @attendee.errors, status: :unprocessable_entity }
        format.js 
      end
    end
  end

  # PATCH/PUT /attendees/1
  # PATCH/PUT /attendees/1.json
  def update
    respond_to do |format|
      if @attendee.update(attendee_params)
        format.html { redirect_to @attendee, notice: 'Attendee was successfully updated.' }
        format.json { render :show, status: :ok, location: @attendee }
      else
        format.html { render :edit }
        format.json { render json: @attendee.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /attendees/1
  # DELETE /attendees/1.json
  def destroy
    @attendee.destroy
    respond_to do |format|
      format.html { redirect_to attendees_url, notice: 'Attendee was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_attendee
      @attendee = Attendee.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def attendee_params
      params.require(:attendee).permit(:ticket_id, :user_id)
    end
end
