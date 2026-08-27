class Avo::Resources::PaymentTransaction < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: q, m: "or").result(distinct: false) }
  # }

  def fields
    field :id, as: :id
    field :order, as: :belongs_to
    field :transaction_type, as: :text
    field :status, as: :text
    field :external_reference, as: :text
    field :amount, as: :number
    field :phone_number, as: :text
    field :raw_response, as: :code, language: "json"
    field :response_payload, as: :textarea
    field :processed_at, as: :date_time
    field :error_message, as: :textarea
  end
end
