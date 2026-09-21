class OutingsController < ApplicationController
  before_action :set_outing, only: %i[ show edit update destroy ]

  def index
    @outings = current_user.outings.order(start_on: :desc)
  end

  def show
  end

  def new
    @outing = current_user.outings.build
  end

  def edit
  end

  def create
    @outing = current_user.outings.build(outing_params)

    if @outing.save
      redirect_to @outing, notice: "おでかけを登録しました。"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @outing.update(outing_params)
      redirect_to @outing, notice: "おでかけを更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @outing.destroy!
    redirect_to outings_path, notice: "おでかけを削除しました。", status: :see_other
  end

  private
    # 必ずログインユーザー自身のおでかけから探す（他人のIDは404になる）
    def set_outing
      @outing = current_user.outings.find(params.expect(:id))
    end

    def outing_params
      params.expect(outing: [ :title, :start_on, :end_on, :place, :memo ])
    end
end
