json.array!(@subscribers) do |subscriber|
  json.extract! subscriber, :id, :contract, :phone
  json.url subscriber_url(subscriber, format: :json)
end
