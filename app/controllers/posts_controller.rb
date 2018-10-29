class PostsController < ApplicationController
  before_action :authenticate_admin!

    def index
      @posts = Post.all
    end

    def show
      @post = Post.find(params[:id])
    end

    def new
      @post = Post.new
    end

    def create
      @post = Post.new(posts_params)
      @post.author = "Pawnters for Life"


      if @post.save
        redirect_to admin_posts_path
      else
        render :new
      end

    end

    def edit
      @post = Post.find(params[:id])
    end

    def update
      @post = Post.find(params[:id])
      @post.update(posts_params)
      if @post.save
        redirect_to admin_posts_path
      else
        render :edit
      end
    end

    def delete
    end

    def destroy
      @post = Post.find(params[:id])
      @post.destroy
      redirect_to admin_posts_path
    end

private
  def posts_params
    params.require(:post).permit(:title, :body, :post_image)
  end

  def authenticate_admin!
    authenticate_user!
    redirect_to root_path, status: :forbidden unless current_user.admin?
  end
end
