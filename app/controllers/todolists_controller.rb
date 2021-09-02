class TodolistsController < ApplicationController
  def new
    @list = List.new
  end

  def create
    list = List.new(list_params)
    list.score = Language.get_data(list_params[:body])
    list.save
    tags_en = Vision.get_image_data(list.image)
    tags_en.each do |tag|
      # APIのURL作成
      api_url = "https://translation.googleapis.com/language/translate/v2?key=#{ENV['GOOGLE_API_KEY']}"


      # APIリクエスト用のJSONパラメータ
      params = {
                "q": "#{tag}",
                "source": "en",
                "target": "ja",
                "format": "text"
              }.to_json

      # Google Cloud Vision APIにリクエスト
      uri = URI.parse(api_url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      response = https.request(request, params)
      response_body = JSON.parse(response.body)
      # APIレスポンス出力
      tag_ja = response_body["data"]["translations"][0]["translatedText"]
      list.tags.create(name: tag_ja)
    end

    redirect_to todolist_path(list.id)
  end

  def index
    @lists = List.all
  end

  def show
    @list = List.find(params[:id])

  end

  def edit
    @list = List.find(params[:id])
  end

  def update
    list = List.find(params[:id])
    list.update(list_params)
    redirect_to todolist_path(list.id)
  end

  def destroy
    list = List.find(params[:id])
    list.destroy
    redirect_to todolists_path
  end

  private

  def list_params
    params.require(:list).permit(:title, :body, :image)
  end

end
