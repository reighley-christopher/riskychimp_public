require 'rexml/document'

class ArticlesController < ApplicationController
  before_filter :admin_required, :except => [:index]
  before_filter :load_article, :only => [:edit, :update, :destroy]

  def index
    @articles = Article.order("id desc").paginate(page: current_page, per_page: 5)
  end

  def new
    @article = Article.new
  end

  def edit
  end

  def create
    @article = Article.new(params[:article])
    if @article.save
      redirect_to articles_path, notice: t("articles.created")
    else
      render 'new'
    end
  end

  def update
    if @article.update_attributes(params[:article])
      redirect_to articles_path, notice: t("articles.updated")
    else
      render 'edit'
    end
  end

  def destroy
    @article.destroy
    redirect_to articles_path
  end

  def feed
    @article = Article.build_from_params(params[:article])
    respond_to do |format|
      format.js
    end
  end

  private
  def load_article
    @article = Article.where(id: params[:id]).first
    unless @article
      flash[:error] = t("articles.access.denied")
      redirect_to_with_js articles_path
    end
  end
end
