class AdminController < ApplicationController
  def admin
  end

  def create
  
  end

  def insert 
     @strTitle = params[:txt_title]
     @strContent = params[:txt_content]
     @nAmount = params[:txt_amount]
     @dtBirthday = params[:dt_birthday]

     session[:strTitle] = @strTitle
     session[:strContent] = @strContent
     session[:nAmount] = @nAmount
     session[:dtBirthday] = @dtBirthday
  end

  def getImage

    @oPhotos = params[:strImage] 
    logger.info {@oFile }
    session[:oPhotos] = @oPhotos
  end
  end
  