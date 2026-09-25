# ゲストユーザーのデモデータ。ゲストログインのたびに作り直し、誰が試しても同じ状態から始められるようにする
module GuestDemoData
  # 日付はログイン日からの相対値にして、常に「これからのおでかけ」に見えるようにする
  OUTINGS = [
    {
      title: "鎌倉日帰り散歩", days_from_now: 7, day_count: 1, place: "鎌倉",
      memo: "歩きやすい靴で行く",
      schedule_items: [
        { day_number: 1, starts_at: "09:00", title: "鎌倉駅に集合", memo: "東口改札前" },
        { day_number: 1, starts_at: "11:00", title: "鶴岡八幡宮" },
        { day_number: 1, starts_at: "12:30", title: "しらす丼ランチ" },
        { day_number: 1, starts_at: "15:00", title: "江ノ電で長谷へ" }
      ],
      packing_items: [
        { title: "財布", checked: true },
        { title: "交通系IC", checked: true },
        { title: "日焼け止め" },
        { title: "折りたたみ傘" }
      ]
    },
    {
      title: "北海道 2泊3日", days_from_now: 30, day_count: 3, place: "札幌・小樽",
      memo: "朝晩は冷えるので上着を忘れずに",
      schedule_items: [
        { day_number: 1, starts_at: "10:00", title: "新千歳空港から札幌へ" },
        { day_number: 2, starts_at: "10:00", title: "小樽運河を散策" },
        { day_number: 3, starts_at: "08:00", title: "二条市場で朝ごはん" },
        { day_number: 3, starts_at: "15:00", title: "帰路へ" }
      ],
      packing_items: [
        { title: "着替え3日分", checked: true },
        { title: "充電器" },
        { title: "上着" },
        { title: "常備薬" }
      ]
    },
    {
      title: "動物園ピクニック", days_from_now: 14, day_count: 1, place: "上野",
      memo: "お弁当を持っていく",
      schedule_items: [
        { day_number: 1, starts_at: "10:00", title: "動物園に入園" },
        { day_number: 1, starts_at: "12:00", title: "芝生でお弁当" },
        { day_number: 1, title: "おみやげを買う" }
      ],
      packing_items: [
        { title: "お弁当", checked: true },
        { title: "レジャーシート" }
      ]
    }
  ].freeze

  # ユーザーのおでかけ（スケジュール・持ち物ごと）を削除し、デモデータを作り直す
  def self.reset!(user)
    user.transaction do
      user.outings.destroy_all

      OUTINGS.each do |attrs|
        start_on = Date.current + attrs[:days_from_now]
        end_on = attrs[:day_count] > 1 ? start_on + (attrs[:day_count] - 1) : nil

        outing = user.outings.create!(
          title: attrs[:title], start_on: start_on, end_on: end_on,
          place: attrs[:place], memo: attrs[:memo]
        )
        attrs[:schedule_items].each { |item| outing.schedule_items.create!(item) }
        attrs[:packing_items].each { |item| outing.packing_items.create!(item) }
      end
    end
  end
end
