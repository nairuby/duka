class Avo::Resources::ContactMessage < Avo::BaseResource
  self.title = :name

  self.search = {
    query: -> { query.where("name ILIKE ? OR email ILIKE ? OR subject ILIKE ?", "%#{q}%", "%#{q}%", "%#{q}%") }
  }

  def fields
    field :id, as: :id, link_to_record: true
    field :name, as: :text, required: true, sortable: true
    field :email, as: :text, required: true, sortable: true
    field :subject, as: :text
    field :message, as: :textarea
    field :status, as: :select,
      options: ContactMessage::STATUSES.map { |s| [ s.titleize, s ] }.to_h,
      filterable: true,
      sortable: true
    field :created_at, as: :date_time, sortable: true, hide_on: [ :new, :edit ]
    field :updated_at, as: :date_time, sortable: true, hide_on: [ :new, :edit ]
  end
end
