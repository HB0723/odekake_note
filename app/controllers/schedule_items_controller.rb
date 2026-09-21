class ScheduleItemsController < ApplicationController
  before_action :set_outing
  before_action :set_schedule_item, only: %i[ edit update destroy ]

  def new
    @schedule_item = @outing.schedule_items.build
  end

  def edit
  end

  def create
    @schedule_item = @outing.schedule_items.build(schedule_item_params)

    if @schedule_item.save
      redirect_to @outing, notice: "予定を追加しました。"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @schedule_item.update(schedule_item_params)
      redirect_to @outing, notice: "予定を更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @schedule_item.destroy!
    redirect_to @outing, notice: "予定を削除しました。", status: :see_other
  end

  private
    # 必ずログインユーザー自身のおでかけから探す（他人のおでかけ配下は404になる）
    def set_outing
      @outing = current_user.outings.find(params.expect(:outing_id))
    end

    # そのおでかけの予定に限定する（別のおでかけの予定も404になる）
    def set_schedule_item
      @schedule_item = @outing.schedule_items.find(params.expect(:id))
    end

    def schedule_item_params
      params.expect(schedule_item: [ :day_number, :starts_at, :title, :memo ])
    end
end
