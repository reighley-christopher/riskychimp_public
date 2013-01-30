require 'spec_helper'

describe ArticlesController do
  context "unauthenticated" do
    it "should redirect to root path" do
      get :feed
      response.should redirect_to('/')
      flash[:notice].should == I18n.t("users.access.denied")
    end

    it "should be able to access index page" do
      get :index
      response.should be_success
    end
  end

  context "authenticated" do
    let(:admin) { create(:admin) }
    let(:article) { create(:article) }
    before do
      sign_in admin
    end

    describe "GET 'new'" do
      it "should be success" do
        get :new
        response.should be_success
        assigns(:article).should be_new_record
      end
    end

    describe "GET 'edit'" do
      it "should be success" do
        get :edit, id: article
        response.should be_success
        assigns(:article).should == article
      end
    end

    describe "PUT 'update'" do
      context "with valid param" do
        it "should be success" do
          put :update, id: article, article: { title: "updated article" }
          response.should redirect_to(articles_path)
        end
      end

      context "with invalid param" do
        it "should not update user" do
          put :update, id: article, article: { title: ''}
          response.should be_success
          response.should render_template('edit')
        end
      end
    end


    describe "POST 'create'" do
      context 'with valid params' do
        it "should be success" do
          post :create, article: { title: "New Article", url: "http://test.host" }
          Article.find_by_title("New Article")
          response.should redirect_to(articles_path)
          flash[:notice].should == I18n.t("articles.created")
        end
      end

      context "with invalid params" do
        it "should not create user" do
          lambda {
            post :create, article: {}
            response.should render_template('new')
          }.should_not change(Article, :count)
        end
      end
    end

    describe "DELETE 'destroy'" do
      it "should be success" do
        delete :destroy, id: article
        response.should redirect_to(articles_path)
        Article.should_not be_exists(article)
      end
    end

    describe "GET 'feed'" do
      it "should be success" do
        Article.should_receive(:build_from_params).with({ "url" => 'http://test.host' }).and_return(Article.new)
        get :feed, article: { url: 'http://test.host' }, format: :js
        response.should be_success
      end
    end
  end
end
