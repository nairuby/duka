class Avo::Resources::User < Avo::BaseResource
  self.title = :email
  
  self.search = {
    query: -> { query.where("email ILIKE ?", "%#{q}%") }
  }

  def fields
    field :id, as: :id, link_to_record: true
    field :email, as: :text, required: true, sortable: true
    field :admin, as: :boolean, help: "Grant admin access to Avo panel"
    field :created_at, as: :date_time, sortable: true, hide_on: [:new, :edit]
    field :updated_at, as: :date_time, sortable: true, hide_on: [:new, :edit]
  end
end
