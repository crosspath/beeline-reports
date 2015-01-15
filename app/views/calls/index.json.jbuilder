json.array!(@calls) do |call|
  json.extract! call, :id, :subscriber, :call_date, :length, :length_r, :cost, :caller, :receiver, :action, :service, :service_type, :volume
  json.url call_url(call, format: :json)
end
