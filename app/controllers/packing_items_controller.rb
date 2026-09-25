class PackingItemsController < ApplicationController
  before_action :set_outing
  before_action :set_packing_item, only: %i[ edit update destroy toggle ]

  def new
    @packing_item = @outing.packing_items.build
  end

  def edit
  end

  def create
    @packing_item = @outing.packing_items.build(packing_item_params)

    if @packing_item.save
      redirect_to @outing, notice: "持ち物を追加しました。"
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @packing_item.update(packing_item_params)
      redirect_to @outing, notice: "持ち物を更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @packing_item.destroy!
    redirect_to @outing, notice: "持ち物を削除しました。", status: :see_other
  end

  # チェック状態を反転し、Turbo Stream で行とカウント表示を更新する（ページ遷移なし）
  def toggle
    @packing_item.toggle!(:checked)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @outing, status: :see_other } # Turbo を通らない送信時のフォールバック
    end
  end

  private
    # 必ずログインユーザー自身のおでかけから探す（他人のおでかけ配下は404になる）
    def set_outing
      @outing = current_user.outings.find(params.expect(:outing_id))
    end

    # そのおでかけの持ち物に限定する（別のおでかけの持ち物も404になる）
    def set_packing_item
      @packing_item = @outing.packing_items.find(params.expect(:id))
    end

    def packing_item_params
      params.expect(packing_item: [ :title ])
    end
end
