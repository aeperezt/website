json.extract! event, :id, :user_id, :title, :image, :location, :frecuency, :start_at, :end_at, :description, :keyworkds, :ticket_url, :community_id, :organizer, :publish, :created_at, :updated_at
json.url event_url(event, format: :json)
